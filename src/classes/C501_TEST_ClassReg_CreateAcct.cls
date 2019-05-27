@isTest
public class C501_TEST_ClassReg_CreateAcct {
    
    // This is a temporary stand-in test for C501_CTRL_ClassReg_Home, which in current version has no use but which will become the main family management page. 
    @isTest static void tempTestHome(){
        C501_CTRL_ClassReg_Home controller = new C501_CTRL_ClassReg_Home();
    }
    
	@isTest static void testSuccessfulLogin(){
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        System.currentPageReference().getParameters().put('a', att.id);
        System.currentPageReference().getParameters().put('r', '1');
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
        
    }
    
    @isTest static void testSuccessfulExistingCookie(){
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        Cookie aIdTest = new cookie('LoginIdClassRegSite', att.Id, null, -1, false);
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        ApexPages.currentPage().setCookies(new Cookie[] {aIdTest});
        
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
    }
    
    @isTest static void testLoginFail(){
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'fail');
    }
    
    @isTest static void testSuccessfulFamilyInsert(){
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        System.currentPageReference().getParameters().put('a', att.id);
        System.currentPageReference().getParameters().put('r', '1');
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
        
        
    }
    
    public static Class_Site_Login_Attempt__c createLoggedInTestUser(){
        Class_Site_Login_Attempt__c att	= new Class_Site_Login_Attempt__c(
            Account__c 			= null,
            Login_Attempts__c	= 0,
            Secret_Code__c		= C501_UTIL_ClassRegUtilities.generateRandomString(6,true,false,false),
            SMS_Timestamp__c	= datetime.now(),
            Code_Sent_To__c     = 'test@email.com'
        );
        insert att;
        return att;
    }
}