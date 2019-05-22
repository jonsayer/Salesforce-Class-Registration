public class C501_CTRL_ClassReg_CreateAcct {
    
    public Contact 	parent   		{get; set;}
    public Account 	family   		{get; set;}
    public String  	pageStatus   	{get; set;}
    public String	confirmation	{get; set;}
    public Boolean 	remember        {get; set;}
    public ID		acctId			{get; set;}
    
    public C501_CTRL_ClassReg_CreateAcct(){
        parent = new Contact();
        family = new Account(
            RecordTypeId 	= [select id from Recordtype where Name='Household Account'].Id,
            Name			= 'Website Generated Account'
        );
        
        pageStatus 		= 'new';
        confirmation	= null;
    }
    
    public PageReference confirmLogin(){
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
    }
    
    public Pagereference createAccount(){
        
        family.C501_Class_Site_Mobile_Number__c = C501_UTIL_ClassRegUtilities.cleanInputPhone(family.C501_Class_Site_Mobile_Number__c);
        
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
        }
    }

}