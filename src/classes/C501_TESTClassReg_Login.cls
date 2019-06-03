@isTest
public class C501_TESTClassReg_Login {
    @testSetup static void setupAccount(){
        
        ID HHacctID	= [select id from Recordtype where Name='Household Account'].Id;

        Account testFamily = new Account(
            Name 								= 'Happy Household',
            C501_Class_Site_Mobile_Number__c 	= '2062222222',
            RecordTypeId						= HHacctID
        );
        insert testFamily;
        
        insert new TwilioConfig__c(Name = 'default', AuthToken__c = 'xxx', Default_Send_Number__c = '206222222', AccountSid__c = 'xxx');
        
    }
    
    /// Below this line, these tests are for testing the verification without confirmation to existing record
    @isTest static void NoAccountVerify_testSimpleEmailVerify(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.identityInput = 'test@email.com';
        
        controller.sendCodeWOacct();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = attList[0].Secret_Code__c;
        controller.remember     = false;
        
        controller.confirmLoginBySendToAddress();
    }
    
    @isTest static void NoAccountVerify_testSimpleSMSVerify(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.identityInput = '2067771077';
        
        controller.sendCodeWOacct();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = attList[0].Secret_Code__c;
        controller.remember     = true;
        
        controller.confirmLoginBySendToAddress();
    }
    
    @isTest static void NoAccountVerify_testSimpleEmailVerificationFailure(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.identityInput = 'test@email.com';
        
        controller.sendCodeWOacct();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = attList[0].Secret_Code__c;
        controller.remember     = false;
        
        delete attList;
        
        controller.confirmLoginBySendToAddress();
        
        System.assert( controller.pageStatus == 'confirm-fail' );
    }
    
    @isTest static void NoAccountVerify_testSimpleEmailVerificationFailureBCattListDeleted(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.identityInput = 'test@email.com';
        
        controller.sendCodeWOacct();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        controller.confirmation = 'doopdidoop';
        controller.remember     = false;
        
        controller.confirmLoginBySendToAddress();
        
        System.assert( controller.pageStatus == 'confirm-fail' );
    }
    
    @isTest static void NoAccountVerify_testEmailInvalid(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.identityInput = 'test@emailcom';
        
        controller.sendCodeWOacct();
        
        System.assert( controller.pageStatus == 'lookup-fail' );
    }
    
    /// Below this line, these tests are for testing the verification without confirmation to existing record
    
    @isTest static void testSimpleSuccessfulLoginDontRemember(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.phoneNumber = '(206) 222-2222';
        
        controller.lookupAccount();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = attList[0].Secret_Code__c;
        controller.remember     = false;
        
        controller.confirmLogin();
    }
    
    @isTest static void testSimpleSuccessfulLogin(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.phoneNumber = '(206) 222-2222';
        
        controller.lookupAccount();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = attList[0].Secret_Code__c;
        
        controller.confirmLogin();
    }
	@isTest static void testSimpleSuccessfulLookupConfirmFail(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.phoneNumber = '(206) 222-2222';
        
        controller.lookupAccount();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        controller.confirmation = '1111111111';
        
        controller.confirmLogin();
        
        System.assert( controller.pageStatus == 'confirm-fail' );
        
    }

    @isTest static void testSimpleSuccessfulLookupConfirmFailBecauseNoReturnedList(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.phoneNumber = '(206) 222-2222';
        
        controller.lookupAccount();
        
        System.assert( controller.pageStatus == 'confirm' );
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        
        String code = attList[0].Secret_Code__c;
        
        delete attList;
            
        controller.confirmation = code;
        
        controller.confirmLogin();
        
        System.assert( controller.pageStatus == 'confirm-fail' );
        
    }
    
    @isTest static void testSimpleLookupFail(){
        PageReference loginPage = Page.C501_ClassReg_Login;
        Test.setCurrentPage(loginPage);
        C501_CTRL_ClassReg_Login controller = new C501_CTRL_ClassReg_Login();
        System.assert( controller.pageStatus == 'start' );
        
        controller.phoneNumber = '(206) 222-0000';
        
        controller.lookupAccount();
        
        System.assert( controller.pageStatus == 'lookup-fail' );
        
    }

}