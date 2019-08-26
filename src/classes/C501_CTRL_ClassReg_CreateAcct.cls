public class C501_CTRL_ClassReg_CreateAcct {
    
    public String 	language		{get; set;}
    
    public Contact 	parent   		{get; set;}
    public Contact 	child   		{get; set;}
    public Account 	family   		{get; set;}
    public String  	pageStatus   	{get; set;}
    public ID		loginID			{get; set;}
    public Account	schoolNameText	{get; set;}
    public Boolean  dontKnowId		{get; set;}
    public Boolean 	noAllergies		{get; set;}
    
    public Map<String,List<SelectOption> > 	fieldSetPicklistOptions			{get; set;}
    public Map<String,String[]> 			siteMultiPicklistReturnValues 	{get; set;}
    public Map<String,Boolean> 				siteMultiPicklistErrorStatus 	{get; set;}
	public String 							errorClassesForPicklists		{get; set;}
    
    public String	schoolName		{
        get{
            if(schoolName 	== null){
                //system.debug('rerunning schoolName get line 18');
                schoolName = '';
            }
            //system.debug('returning school name');
            return schoolName;
        } 
        set;
    }
    
    public String	schoolRegion	{
        get{
            if(schoolRegion 	== null){
                //system.debug('rerunning schoolRegion get line 30');
                schoolRegion = '';
            }
            //system.debug('returning school region');
            return schoolRegion;
        } 
        set;
    }
    
    public School_Term__c term		{get; set;}
    public String	grade			{get; set;}
    public Boolean 	noState			{get; set;}
    public Boolean 	needPickup		{get; set;}
    public Boolean 	noSchool		{get; set;}
    public Boolean 	noGrade			{get; set;}
    public Boolean  noWaiver		{get; set;}
    public Boolean  noStuID			{get; set;}
    public Boolean  noAllergyResp 	{get; set;}
    private String  RegType         {get; set;}
    
    public List<SelectOption> schoolList 	{
        get {
            if(schoolList == null ){
                //system.debug('rerunning schoolList get line 53');
                schoolList = getSelectOptionsActiveSchools(schoolRegion);
            } 
            //System.debug('List<SelectOption> schoolList run: ' + schoolList);
            //system.debug('returning schoolList');
            return schoolList;
    	} set;
	}
    public List<SelectOption> gradeList 	{get; set;}
    
    public List<Schema.FieldSetMember>	hhFieldSet		{get; set;}
    public List<Schema.FieldSetMember>	parentFieldSet	{get; set;}
    public List<Schema.FieldSetMember>	childFieldSet	{get; set;}
    
    public C501_CTRL_ClassReg_CreateAcct(){
        
        language		= ApexPages.currentPage().getParameters().get('l');
        if(language == null){
            language = 'en_US';
        }
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
        
        gradeList 		= C501_UTIL_ClassRegUtilities.listOfGrades();
        schoolName 		= '';
        schoolNameText	= null;
        noState 		= false;
        noSchool 		= false;
        noGrade			= false;
        noWaiver		= false;
        dontKnowId		= false;
        noStuID			= false;
        noAllergyResp	= false;
        needPickup		= false;
        schoolregion 	= '';
        errorClassesForPicklists = '';
        
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
        
        fieldSetPicklistOptions = new Map<String, List<SelectOption> >();
        siteMultiPicklistReturnValues = new Map<String, String[] >();
        siteMultiPicklistErrorStatus = new Map<String, Boolean >();
        // loop through each field in the fieldsets. If they are multi-select picklists, get their picklist values and save them to a map
        for(FieldSetMember fsm : hhFieldSet){
            Schema.SObjectField f = fsm.getSObjectField();
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if(dfr.getType() == Schema.DisplayType.MultiPicklist ){
                List<SelectOption> picklistOptionsForField = getFieldsPicklistOptions(f,'Account');
                fieldSetPicklistOptions.put( dfr.getName(), picklistOptionsForField );
                siteMultiPicklistReturnValues.put( dfr.getName(), new String[]{} );
                siteMultiPicklistErrorStatus.put( dfr.getName(), false);
            }
        }
        for(FieldSetMember fsm : parentFieldSet){
            Schema.SObjectField f = fsm.getSObjectField();
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if(dfr.getType() == Schema.DisplayType.MultiPicklist ){
                List<SelectOption> picklistOptionsForField = getFieldsPicklistOptions(f,'Contact');
                fieldSetPicklistOptions.put( dfr.getName(), picklistOptionsForField );
                siteMultiPicklistReturnValues.put( dfr.getName(), new String[]{} );
                siteMultiPicklistErrorStatus.put( dfr.getName(), false);
            }
        }
        for(FieldSetMember fsm : childFieldSet){
            Schema.SObjectField f = fsm.getSObjectField();
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if(dfr.getType() == Schema.DisplayType.MultiPicklist ){
                List<SelectOption> picklistOptionsForField = getFieldsPicklistOptions(f,'Contact');
                fieldSetPicklistOptions.put( dfr.getName(), picklistOptionsForField );
                siteMultiPicklistReturnValues.put( dfr.getName(), new String[]{} );
                siteMultiPicklistErrorStatus.put( dfr.getName(), false);
            }
        }
        
        // Manually add family status to these lists, as it is not in the field sets
        /*Schema.SObjectField famStatus = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('Family_Status__c');
        fieldSetPicklistOptions.put('Family_Status__c',getFieldsPicklistOptions(famStatus ,'Contact') );
        siteMultiPicklistReturnValues.put('Family_Status__c',new String[]{});*/
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
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_SelectSchool)  );
            noSchool = true;
            passValidation = false;
        } else {
            noSchool = false;
        }
        /*if(family.BillingState == null || family.BillingState == '' ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_SelectState)  );
            noState = true;
            passValidation = false;
        } else {
            noState = false;
        }*/
        if(grade == null || grade == '' ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_SelectGrade)  );
            noGrade = true;
            passValidation = false;
        } else {
            noGrade = false;
        }
        
        if(term.Student_School_ID__c == null && dontKnowId == false){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_ProvideStudentId    )  );
            noStuId = true;
            passValidation = false;
        } else {
            noStuId = false;
        }
        
        if(child.Allergies__c == null && noAllergies == false){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_NoAllergiesError    )  );
            noAllergyResp = true;
            passValidation = false;
        } else {
            noAllergyResp = false;
        }
        
        if(child.Student_Transportation__c == 'Will receive a ride' && (child.Authorized_Pickup_1_Name__c == null || child.Authorized_Pickup_1_Phone__c == null || child.Authorized_Pickup_1_Relationship__c == null ) ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_PickUpChildError    )  );
            needPickup = true;
            passValidation = false;
        } else {
            needPickup	= false;
        }
        
        if( parent.Email == null && parent.HomePhone == null && parent.MobilePhone == null && parent.OtherPhone == null ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_RegSite_ParentContactRequired)  );
            passValidation = false;
        }
        
        if(term.Waiver__c == false){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_ClassReg_WaiverRequired)  );
            noWaiver = true;
            passValidation = false;
        } else {
            noWaiver = false;
        }
        
        Boolean phoneFail = false;
        
        // Phone number validation
        if(parent.MobilePhone != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(parent.MobilePhone);
            if(NAformat != null){
                parent.MobilePhone = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail parent mobile :( ');
                phoneFail = true;
                parent.MobilePhone.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(parent.HomePhone != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(parent.HomePhone);
            if(NAformat != null){
                parent.HomePhone = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail parent home :( ');
                phoneFail = true;
                parent.HomePhone.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(parent.OtherPhone != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(parent.OtherPhone);
            if(NAformat != null){
                parent.OtherPhone = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail parent other :( ');
                phoneFail = true;
                parent.OtherPhone.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.MobilePhone != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.MobilePhone);
            if(NAformat != null){
                child.MobilePhone = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail child mobile :( ');
                phoneFail = true;
                child.MobilePhone.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.Alternate_Contact_Phone__c != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.Alternate_Contact_Phone__c);
            if(NAformat != null){
                child.Alternate_Contact_Phone__c = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail emergency contact 1 :( ');
                phoneFail = true;
                child.Alternate_Contact_Phone__c.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.Emergency_Contact_2_Phone__c != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.Emergency_Contact_2_Phone__c);
            if(NAformat != null){
                child.Emergency_Contact_2_Phone__c = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail emergency contact 2 :( ');
                phoneFail = true;
                child.Emergency_Contact_2_Phone__c.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.Authorized_Pickup_1_Phone__c != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.Authorized_Pickup_1_Phone__c);
            if(NAformat != null){
                child.Authorized_Pickup_1_Phone__c = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail Auth pickup 1 :( ');
                phoneFail = true;
                child.Authorized_Pickup_1_Phone__c.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.Authorized_Pickup_2_Phone__c != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.Authorized_Pickup_2_Phone__c);
            if(NAformat != null){
                child.Authorized_Pickup_2_Phone__c = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail Auth pickup 2 :( ');
                phoneFail = true;
                child.Authorized_Pickup_2_Phone__c.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        if(child.Authorized_Pickup_3_Phone__c != null){
            String NAformat = C501_UTIL_ClassRegUtilities.NAformatPhone(child.Authorized_Pickup_3_Phone__c);
            if(NAformat != null){
                child.Authorized_Pickup_3_Phone__c = NAformat;
            } else {
                system.debug('Failed Validation due to phoneFail Auth pickup 3:( ');
                phoneFail = true;
                child.Authorized_Pickup_3_Phone__c.addError(Label.C501_ClassReg_PhoneFailSpecific);
            }
        }
        
        if(phoneFail){
            system.debug('Failed Validation due to phoneFail :( ');
            passValidation = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.C501_ClassReg_PhoneFail)  );
        }
        system.debug( 'SchoolName after validation attempts: ' + schoolName   );
        
        if(passValidation == true){
            errorClassesForPicklists = '';
            // make sure they checked something in each of the required picklists
            for(String key : siteMultiPicklistReturnValues.keySet() ){
                if(/*key != 'Family_Status__c' && */siteMultiPicklistReturnValues.get(key).size() == 0 ){
                    passValidation = false;
                    if(String.isEmpty(errorClassesForPicklists)){
                        errorClassesForPicklists = ' .picklist' + key;
                    } else {
                        errorClassesForPicklists = errorClassesForPicklists + ', .picklist' + key;
                    }
                    siteMultiPicklistErrorStatus.put( key, true);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.C501_Classreg_CheckBoxes	 )  );
                } else {
                    siteMultiPicklistErrorStatus.put( key, false);
                }
            }
        }
        
        
        // Convert all of the values in the Checklist value sets to the correct picklist values on the correct record
        loopThroughFieldsetAndSetValues(child,childFieldSet);
        loopThroughFieldsetAndSetValues(parent,parentFieldSet);
        loopThroughFieldsetAndSetValues(family,hhFieldSet);
        
        if(passValidation == false){
            system.debug('Failed Validation :( ');
            return null;
        }
        
        
        
        // manually pass the family status from the checklist value set, as it is not in the field sets
        /*Boolean first = true;
        for(String s : siteMultiPicklistReturnValues.get('Family_Status__c') ){
            if(first){
                parent.Family_Status__c = s;
                first = false;
            } else {
                parent.Family_Status__c = parent.Family_Status__c + ';' + s;
            }
        }*/
        
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
        term.C501_Sign_Up_Source__c	= 'Online';
        
        schoolNameText 		= [Select 	id,
                               			Name,
                               			C501_Next_Program_Start_Date__c,
                               			(
                                        	SELECT 	npe5__Status__c,
                                            		npe5__Contact__c,
                                            		npe5__Contact__r.FirstName,
                                            		npe5__Contact__r.LastName
                                            FROM	npe5__Affiliations__r
                                            WHERE	npe5__Status__c = 'Current'
                                             AND 	npe5__Role__c 	= 'Teacher'
                                        )
                               from 	Account 
                               where 	id = :schoolName];
        
        term.School_Year__c	= C501_UTIL_ClassRegUtilities.currentSchoolYear( Date.today() );
        term.C501_Sign_Up_Source__c = 'Online';
        
        insert term;
        if(parent.MobilePhone != null && parent.MobilePhone != '' ){
            String SMSmessage = Label.C501_RegSite_ConfirmSMS+' '+schoolNameText.Name;
            if(parent.Email != null && parent.Email != ''){
                SMSmessage = SMSmessage + Label.C501_RegSite_SMSweSentAnEmail + ' ' + parent.Email;
            }
            C501_UTIL_ClassRegUtilities.logActivityToContact(parent.Id,SMSmessage, SMSmessage,'Call');
            C501_UTIL_ClassRegUtilities.sendSMSGenericFuture(parent.MobilePhone,Label.C501_RegSite_ConfirmSMS+' '+schoolNameText.Name );
        }
        
        if(parent.Email != null && parent.Email != '' ){
            /* Commented out 8/22/2019, as the client no longer wishes to include the teacher names and contact info in the confirmation email, AFAIK (jon)
             * 
             * String teacherName = '';
            for(Integer i = 0; i < schoolNameText.npe5__Affiliations__r.size(); i++){
                if(i != 0 && i + 1 == schoolNameText.npe5__Affiliations__r.size() && schoolNameText.npe5__Affiliations__r.size() > 1){
                    teacherName = teacherName + ' ' + Label.C501_ClassReg_AND + ' ';
                } else if(i != 0  && schoolNameText.npe5__Affiliations__r.size() > 1 ) {
                    teacherName = teacherName + ', ';
                }
                teacherName = teacherName + schoolNameText.npe5__Affiliations__r[i].npe5__Contact__r.FirstName + ' ' +schoolNameText.npe5__Affiliations__r[i].npe5__Contact__r.LastName;
            }
            
            String nextStartDate = '';
            if(schoolNameText.C501_Next_Program_Start_Date__c != null){
            	nextStartDate = Datetime.newInstance(schoolNameText.C501_Next_Program_Start_Date__c, Time.newInstance(0,0,0,0)).format('MMMMM d, yyyy');
            }*/
            
            Id templateId = [Select id from EmailTemplate where DeveloperName = 'C501_Class_Registration_Confirmation_VF'].Id;
            
            //String emailMessage = Label.C501_RegSite_ConfirmSMS+' '+schoolNameText.Name +Label.C501_RegSite_EmailConfirmP2+' '+nextStartDate+' '+Label.C501_RegSite_EmailConfirmP3+' '+teacherName+Label.C501_RegSite_EmailConfirmP4;
            //C501_UTIL_ClassRegUtilities.SendEmailGeneric('salesforce@techbridgegirls.org',parent.Email,Label.C501_RegSite_ConfirmSMS+' '+schoolNameText.Name,emailMessage);
			C501_UTIL_ClassRegUtilities.SendEmailGeneric('salesforce@techbridgegirls.org',null,null,null,term.Id,templateId,parent.Id);
            
            //C501_UTIL_ClassRegUtilities.logActivityToContact(parent.Id,Label.C501_RegSite_ConfirmSMS+' '+schoolNameText.Name, emailMessage,'Email');
        }
        pageStatus = 'finished';
        return null;
    }
    
    private void loopThroughFieldsetAndSetValues(SObject record, List<Schema.FieldSetMember> fsmList ){
        // loop through child fieldset again
        for(FieldSetMember fsm : fsmList){
            Schema.SObjectField f = fsm.getSObjectField();
            Schema.DescribeFieldResult dfr = f.getDescribe();
            // check if each field is a picklist
            if(dfr.getType() == Schema.DisplayType.MultiPicklist ){
                // if it is, look through the returned values for that field's returned value
                String returnString = '';
                String[] selectedCheckboxes = siteMultiPicklistReturnValues.get(dfr.getName());
                // if we get a value, concatenate and save it!
                if(selectedCheckboxes.size() == 1){
                    returnString = selectedCheckboxes[0];
                } else {
                    Boolean first = true;
                    for(String s : selectedCheckboxes ){
                        if(first){
                            returnString = s;
                            first = false;
                        } else {
                            returnString = returnString + ';' +s;
                        }
                    }
                }
                // set value to the field on that record
                record.put(dfr.getName(),returnString);
            }
        }
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
    
    public static List<SelectOption> getFieldsPicklistOptions(Schema.SObjectField field,String objectName){
        /*Map<String, Schema.SobjectType> allObjects = schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> objectField = allObjects.get(objectName).getDescribe().fields.getMap();
        
        /*for(Schema.SObjectType obj : gd.values() ){
            if(){
                
            }
        }*/
        
        List<SelectOption> picklistOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        
        list<schema.picklistentry> values = fieldResult.getPickListValues();               
        for (Schema.PicklistEntry p : values){                  
        	picklistOptions.add(new SelectOption(p.getLabel(), p.getValue()));
        }
        
        
        return picklistOptions;
    }
    
    public static List<Account> getListOfActiveSchools(String regionFilter){
        system.debug('rerunning getListOfActiveSchools line 424');
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
            AND		C501_Is_Active_School__c	= true
            ORDER BY School_District_Lookup__r.Name, Name
        ];
        if(schoolList.size() == 0){
            system.debug('first query returned null, pulling whole list');
            schoolList = [
                SELECT	id,
                        Name,
                        School_District_Lookup__c,
                        School_District_Lookup__r.Name,
                        Region__c
                FROM	Account
                WHERE	RecordTypeId 	= :schoolRecordType
                AND		C501_Is_Active_School__c	= true
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