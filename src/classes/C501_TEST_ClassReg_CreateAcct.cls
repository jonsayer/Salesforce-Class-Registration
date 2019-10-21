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
    
    @isTest static void testSuccessfulGoBack(){
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        System.currentPageReference().getParameters().put('a', att.id);
        System.currentPageReference().getParameters().put('r', '1');
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
        
        controller.goBack();
        
    }
    
    @isTest static void testValidationFail(){
        insert new TwilioConfig__c(Name = 'default', AuthToken__c = 'xxx', Default_Send_Number__c = '206222222', AccountSid__c = 'xxx');
        insert new RegistrationSiteSettings__c(Name = 'default', Default_From_Email__c = 'salesforce@techbridgegirls.org');
        
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        
        Account	school = new Account(Name='TestSchool',Region__c = 'Seattle');
        insert school;
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        System.currentPageReference().getParameters().put('a', att.id);
        System.currentPageReference().getParameters().put('r', '1');
        System.currentPageReference().getParameters().put('c', 'test@test.com');
        
        Test.startTest();
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
        
        //System.assert(controller.getRegions().size() == 5);
        
        controller.schoolRegion				= 'Seattle';
        controller.refreshSchools();
        
        controller.parent.FirstName			= 'Test';
        controller.parent.LastName			= 'LastName';
        controller.parent.MobilePhone		= '9000';
        controller.parent.Email				= 'test@example.com';
        controller.parent.HomePhone			= 'bar';
        controller.parent.OtherPhone		= 'foo';
        controller.family.BillingStreet		= '123 Main St';
        controller.family.BillingCity		= 'Seattle';
        controller.family.BillingState		= 'WA';
        controller.family.BillingPostalCode	= '98101';
        
        controller.child.FirstName	= 'Child';
        controller.child.LastName	= 'Name';
        controller.child.MobilePhone = '123';
        controller.grade 			= null;
        controller.schoolName		= null;
        controller.term.Waiver__c	= false;
        
        controller.term.Student_School_ID__c 					= null;
        controller.noAllergies									= false;
        controller.child.Student_Transportation__c 				= 'Will receive a ride';
        controller.child.Authorized_Pickup_1_Name__c 			= 'Test friend';
        controller.child.Authorized_Pickup_1_Phone__c 			= 'derp';
        controller.child.Authorized_Pickup_1_Relationship__c 	= null;
        controller.child.Authorized_Pickup_2_Phone__c 			= 'huh';
        controller.child.Authorized_Pickup_3_Phone__c 			= 'NCC-1701';
        controller.child.Alternate_Contact_Phone__c 			= 'AAAH';
        controller.child.Emergency_Contact_2_Phone__c 			= '9';
        
        controller.createAccount();
                
        Test.stopTest();
        
        
    }
    
    @isTest static void testSuccessfulInsert(){
        insert new TwilioConfig__c(Name = 'default', AuthToken__c = 'xxx', Default_Send_Number__c = '206222222', AccountSid__c = 'xxx');
        insert new RegistrationSiteSettings__c(Name = 'default', Default_From_Email__c = 'salesforce@techbridgegirls.org');
        
        Class_Site_Login_Attempt__c att = createLoggedInTestUser();
        
        Account	school = new Account(Name='TestSchool',Region__c = 'Seattle');
        insert school;
        
        PageReference createAcctPage = Page.C501_ClassReg_CreateAcct;
        Test.setCurrentPage(createAcctPage);
        System.currentPageReference().getParameters().put('a', att.id);
        System.currentPageReference().getParameters().put('r', '1');
        System.currentPageReference().getParameters().put('c', 'test@test.com');
        
        Test.startTest();
        C501_CTRL_ClassReg_CreateAcct controller = new C501_CTRL_ClassReg_CreateAcct();
        System.assert(controller.pageStatus == 'new');
        
        //System.assert(controller.getRegions().size() == 5);
        
        controller.schoolRegion				= 'Seattle';
        controller.refreshSchools();
        
        controller.parent.FirstName			= 'Test';
        controller.parent.LastName			= 'LastName';
        controller.parent.MobilePhone		= '(623) 456-7890';
        controller.parent.Email				= 'test@example.com';
        controller.parent.HomePhone			= '(222) 287-1824';
        controller.parent.OtherPhone		= '(222) 287-1824';
        controller.family.BillingStreet		= '123 Main St';
        controller.family.BillingCity		= 'Seattle';
        controller.family.BillingState		= 'WA';
        controller.family.BillingPostalCode	= '98101';
        
        controller.child.FirstName	= 'Child';
        controller.child.LastName	= 'Name';
        controller.child.MobilePhone = '(222) 628-1928';
        controller.grade 			= '10';
        controller.schoolName		= school.Id;
        controller.term.Waiver__c	= true;
        controller.term.Authorization_to_treat_minor__c	= true;
        
        controller.term.Student_School_ID__c 					= 'abc123';
        controller.noAllergies									= true;
        controller.noSpecialNeeds								= true;
        controller.noMedication									= true;
        controller.child.Student_Transportation__c 				= 'Will receive a ride';
        controller.child.Authorized_Pickup_1_Name__c 			= 'Test friend';
        controller.child.Authorized_Pickup_1_Phone__c 			= '(206) 234-5678';
        controller.child.Authorized_Pickup_1_Relationship__c 	= 'BFF';
        controller.child.Authorized_Pickup_2_Phone__c 			= '(206) 234-5678';
        controller.child.Authorized_Pickup_3_Phone__c 			= '(206) 234-5678';
        controller.child.Alternate_Contact_Phone__c 			= '(206) 234-5678';
        controller.child.Emergency_Contact_2_Phone__c 			= '(206) 234-5678';
        
        controller.siteMultiPicklistReturnValues.put('Race__c',new List<String>{'White'});
        controller.siteMultiPicklistReturnValues.put('Family_Status__c',new List<String>{'Immigrant'});
        controller.siteMultiPicklistReturnValues.put('Preferred_Method_of_Contact__c',new List<String>{'Email'});
        controller.siteMultiPicklistReturnValues.put('Volunteer__c',new List<String>{'Other'});
        
        controller.createAccount();
        
        List<SelectOption> testListResult = controller.schoolList;
        
        List<SelectOption> regionList = C501_CTRL_ClassReg_CreateAcct.getRegions();
        
        Test.stopTest();
        
        List<School_Term__c> lookupTest = [
            SELECT	id,
            		Parent__c,
            		Parent__r.FirstName,
            		Student__c,
            		School__c,
            		School__r.Name
            FROM	School_Term__c
        ];
        
        System.assert( lookupTest.size() == 1 );
        System.assert( lookupTest[0].Parent__r.FirstName == 'Test' );
        System.assert( lookupTest[0].School__r.Name == 'TestSchool' );
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