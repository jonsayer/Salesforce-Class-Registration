public class C501_CTRL_ClassReg_Login {
    
    public 	String 	pageStatus		{get;set;}
    public 	String 	phoneNumber		{get;set;}
    public 	String 	confirmation	{get;set;}
    public  Boolean remember        {get;set;}
    private ID		acctID			= null;
    
    public C501_CTRL_ClassReg_Login(){
        pageStatus		= 'start';
        phoneNumber		= '';
        confirmation	= '';
        remember        = true;
    }
    
    public PageReference confirmLogin(){
        PageReference nextPage = C501_UTIL_ClassRegUtilities.confirmLogin(confirmation,acctID,remember);
        if(nextPage == null){
            pageStatus = 'confirm-fail';
            return null;
        } else {
            return nextPage;
        }
    }
    
    public PageReference lookupAccount(){
        // clean the input
        String cleanedPhone = C501_UTIL_ClassRegUtilities.cleanInputPhone(phoneNumber);
        
        // TO DO, return error if phone is not the correct format
        
        // look up the account
        
        acctID = C501_UTIL_ClassRegUtilities.lookupAccountByPhone(cleanedPhone);
        
        if(acctID != null ){
            // send the sms
            C501_UTIL_ClassRegUtilities.sendSMS(acctID,cleanedPhone);
        	// present user with a code screen
        	pageStatus	= 'confirm';
        	return null;
        } else {
            // login failed
            pageStatus	= 'lookup-fail';
            return null;
        }
    }
}