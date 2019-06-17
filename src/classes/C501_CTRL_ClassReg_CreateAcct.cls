public class C501_CTRL_ClassReg_CreateAcct {
    
    public Contact 	parent   		{get; set;}
    public Contact 	child   		{get; set;}
    public Account 	family   		{get; set;}
    public String  	pageStatus   	{get; set;}
    public ID		loginID			{get; set;}
    public String	schoolName		{get; set;}
    public String	schoolRegion	{get; set;}
    public School_Term__c term		{get; set;}
    public String	grade			{get; set;}
    private String  RegType         {get; set;}
    
    public List<SelectOption> schoolList 	{
        get {
            if(schoolList == null ){
                if(String.isBlank(schoolRegion)){
                    schoolList = getSelectOptionsActiveSchools( '' );
                    System.debug('List<SelectOption> schoolList run: schoolRegion is null');
                } else {
                    schoolList = getSelectOptionsActiveSchools(schoolRegion);
                    System.debug('List<SelectOption> schoolList run: schoolRegion is: ' + schoolRegion);
                }
            } 
            System.debug('List<SelectOption> schoolList run: ' + schoolList);
            return schoolList;
    	} set;
	}
    public List<SelectOption> gradeList 	{get; set;}
    
    public List<Schema.FieldSetMember>	hhFieldSet		{get; set;}
    public List<Schema.FieldSetMember>	parentFieldSet	{get; set;}
    public List<Schema.FieldSetMember>	childFieldSet	{get; set;}
    
    public C501_CTRL_ClassReg_CreateAcct(){
        Boolean loggedIn = false;
        loginID	= null;
        RegType = null;
        
        Cookie aId = ApexPages.currentPage().getCookies().get('LoginIdClassRegSite');
        if (aId != null){
            loginID 	= aId.getValue();
            loggedIn 	= C501_UTIL_ClassRegUtilities.confirmLoggedIn(loginID,false);
            pageStatus	= 'new';
        } else {
            String	attID 		= ApexPages.currentPage().getParameters().get('a');
            String 	remember 	= ApexPages.currentPage().getParameters().get('r');
            loggedIn 			= C501_UTIL_ClassRegUtilities.confirmLoggedIn(attID,true);
            if(loggedIn){
            	Integer remberInt = 86400;
                if(remember != null && remember == '1'){
                    remberInt = -1;
                }
                aId = new cookie('LoginIdClassRegSite', attID, null, remberInt, false);
                ApexPages.currentPage().setCookies(new Cookie[] {aId});
                pageStatus	= 'new';
            } else {
                pageStatus	= 'fail';
            }
        }
        
        parent 	= new Contact(
        	RecordTypeId 	= [select id from Recordtype where Name='Parent'].Id
        );
        child  	= new Contact(
        	RecordTypeId 	= [select id from Recordtype where Name='Student'].Id
        );
		
		term	= new School_Term__c();
        
        String 	confirmMeth 	= ApexPages.currentPage().getParameters().get('c');
        
        family = new Account(
            RecordTypeId 	= [select id from Recordtype where Name='Household Account'].Id,
            Name			= 'Website Generated Account'
        );
        if(confirmMeth != null && confirmMeth.contains('@')){
            parent.Email 		= confirmMeth;
            RegType             = 'byEmail';
        } else {
            parent.MobilePhone 	= confirmMeth;
            RegType             = 'byText';
        }
        
        schoolRegion 	= '';
        gradeList 		= C501_UTIL_ClassRegUtilities.listOfGrades();
        schoolName 		= '';
        
        Map<String, Schema.FieldSet> FsAcctMap = Schema.SObjectType.Account.fieldSets.getMap();
        Map<String, Schema.FieldSet> FsContMap = Schema.SObjectType.Contact.fieldSets.getMap();

        try{
            hhFieldSet = FsAcctMap.get('C501_ClassReg_Site_HH_Acct_Custom').getFields();
        } catch(Exception e){
            hhFieldSet = FsAcctMap.get('C501_Class_Registration_Site_HH_Acct').getFields();
        }
        try{
            parentFieldSet = FsContMap.get('C501_ClassReg_Site_Parent_Custom').getFields();
        } catch(Exception e){
            parentFieldSet = FsContMap.get('C501_Class_Registration_Site_Parent').getFields();
        }
        try{
            childFieldSet = FsContMap.get('C501_ClassReg_Site_Child_Custom').getFields();
        } catch(Exception e){
            childFieldSet = FsContMap.get('C501_Class_Registration_Site_Child').getFields();
        }       
    }
    
    /*public PageReference confirmLogin(){
        PageReference nextPage = C501_UTIL_ClassRegUtilities.confirmLogin(confirmation,acctID,remember);
        if(nextPage == null){
            pageStatus = 'confirm-fail';
            return null;
        } else {
            // Verified login, so update the Account with details provided.
            insert family;
            insert parent;
            //C501_UTIL_ClassRegUtilities.
            
            return nextPage;
        }
    }*/
    
    public Pagereference refreshSchools(){
        schoolList = null;
        System.debug('refreshSchools() run');
        return null;
    }
    
    public Pagereference goBack(){
        return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Login',null,null);
    }
    
    public Pagereference createAccount(){
        
        /*family.C501_Class_Site_Mobile_Number__c = C501_UTIL_ClassRegUtilities.cleanInputPhone(family.C501_Class_Site_Mobile_Number__c);
        
        // next, we need to check if there is already an account with that phone number. If it is them, send a confirmation text and pair them with that account
        acctID = C501_UTIL_ClassRegUtilities.lookupAccountByPhone(family.C501_Class_Site_Mobile_Number__c);
        
        if(acctID != null ){
            // send the sms
            C501_UTIL_ClassRegUtilities.sendSMS(acctID,family.C501_Class_Site_Mobile_Number__c);
            //family.Id = acctID;
            parent.AccountId = acctID;
        	// present user with a code screen
        	pageStatus	= 'confirm';
        	return null;
        } else {
            insert family;
            parent.AccountId 	= family.id;
            insert parent;
            
            Cookie aId 			= new cookie('AccountIdClassRegSite', family.id, null, 86400, false);
            ApexPages.currentPage().setCookies(new Cookie[] {aId});
            
            return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Home',null,null);
        }*/
        
        Boolean passValidation = true;
        
        if(schoolName == null || schoolName == '' ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select a School')  );
            passValidation = false;
        }
        if(grade == null || grade == '' ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select a Grade')  );
            passValidation = false;
        }
        if(passValidation == false){
            return null;
        }
        
        insert family;
        
        parent.npe01__Preferred_Email__c 	= 'Personal';
        parent.npe01__HomeEmail__c			= parent.Email;
        parent.AccountId 	= family.id;
        child.AccountId		= family.id;
        
        child.Graduation_Year__c = C501_UTIL_ClassRegUtilities.getGraduatingYearFromCurrentGrade( Integer.valueOf(grade) );
        
        insert parent;
        insert child; 
        
        term.Student__c 	= child.Id;
        term.Parent__c 		= parent.Id;
        term.School__c 		= schoolName;
        
        // future version, need to make this dynamic
        term.School_Year__c	= C501_UTIL_ClassRegUtilities.currentSchoolYear( Date.today() );
        term.C501_Sign_Up_Source__c = 'Online';
        
        insert term;
        
        return null;
    }
    
    public static List<SelectOption> getRegions(){
        List<SelectOption> regions = new List<SelectOption>();
        
        regions.add(new SelectOption( '', 'Select One' ) ); 
        regions.add(new SelectOption( 'East Bay', Label.C501_ClassReg_eastBay ) ); 
        regions.add(new SelectOption( 'South Bay', Label.C501_ClassReg_southBay ) ); 
        regions.add(new SelectOption( 'Seattle', Label.C501_ClassReg_seattleArea ) ); 
        regions.add(new SelectOption( 'DC', Label.C501_ClassReg_dcArea ) ); 
        return regions;
    }
    
    public static List<Account> getListOfActiveSchools(String regionFilter){
        Id schoolRecordType = [select id from Recordtype where Name='School'].Id;
        List<Account> schoolList = new List<Account>();
        schoolList = [
            SELECT	id,
            		Name,
            		School_District_Lookup__c,
            		School_District_Lookup__r.Name,
            		Region__c
            FROM	Account
            WHERE	RecordTypeId 	= :schoolRecordType
            AND		Region__c 		= :regionFilter
            ORDER BY School_District_Lookup__r.Name, Name
        ];
        if(schoolList.size() == 0){
            schoolList = [
                SELECT	id,
                        Name,
                        School_District_Lookup__c,
                        School_District_Lookup__r.Name,
                        Region__c
                FROM	Account
                WHERE	RecordTypeId 	= :schoolRecordType
                ORDER BY School_District_Lookup__r.Name, Name
            ];
        }
        return schoolList;
    }
    
    public static List<SelectOption> getSelectOptionsActiveSchools(String regionFilter){
        List<Account> schoolList 			= getListOfActiveSchools(regionFilter);
        List<SelectOption> schoolOptions 	= new List<SelectOption>();
        schoolOptions.add(new SelectOption( '', 'Select One: ') ); 
        for(Account school : schoolList ){
            schoolOptions.add(new SelectOption( school.Id, school.School_District_Lookup__r.Name+': '+school.Name ) ); 
        }
        
        return schoolOptions;
    }

}