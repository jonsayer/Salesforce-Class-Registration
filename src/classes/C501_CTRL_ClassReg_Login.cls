public class C501_CTRL_ClassReg_Login {
    
    public 	String 	language		{get;set;}
    public 	String 	pageStatus		{get;set;}
    public 	String 	phoneNumber		{get;set;}
    public 	String 	identityInput	{get;set;}
    public 	String 	confirmation	{get;set;}
    public  Boolean remember        {get;set;}
    private ID		acctID			= null;
    
    public C501_CTRL_ClassReg_Login(){
        language		= ApexPages.currentPage().getParameters().get('l');
        if(language == null){
            language = 'en_US';
        }
        pageStatus		= 'start';
        phoneNumber		= '';
        confirmation	= '';
        identityInput	= null;
        remember        = false;
    }
    
    public PageReference confirmLoginBySendToAddress(){
        PageReference nextPage = C501_UTIL_ClassRegUtilities.confirmLoginByCodeToAddress(confirmation, identityInput , remember , language);
        if(nextPage == null){
            pageStatus = 'confirm-fail';
            return null;
        } else {
            return nextPage;
        }
    }
    
    public PageReference sendCodeWOacct(){
        String identityInput = C501_UTIL_ClassRegUtilities.cleanInputGeneric(identityInput);
        if(identityInput == null){
            pageStatus	= 'lookup-fail';
            return null;
        } else {
            pageStatus	= 'confirm';
            C501_UTIL_ClassRegUtilities.sendConfirmationCodeWOacctID(identityInput);
            return null;
        }
    }
    
    // Below this line, code supporting logging in by verifying an existing account
    // 
    // 
    public PageReference confirmLogin(){
        PageReference nextPage = C501_UTIL_ClassRegUtilities.confirmLogin(confirmation,acctID,remember,language);
        if(nextPage == null){
            pageStatus = 'confirm-fail';
            return null;
        } else {
            return nextPage;
        }
    }
    
    public PageReference createAccount(){
        return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_CreateAcct',null,null);
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