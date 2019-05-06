public class C501_CTRL_ClassReg_Login {
    
    public 	String 	pageStatus		{get;set;}
    public 	String 	phoneNumber		{get;set;}
    public 	String 	confirmation	{get;set;}
    private ID		acctID			= null;
    
    public C501_CTRL_ClassReg_Login(){
        pageStatus		= 'start';
        phoneNumber		= '';
        confirmation	= '';
    }
    
    public PageReference confirmLogin(){
        String 		cleanedConfirm 		= confirmation.replaceAll('[^0-9]', '');
        Datetime 	thirtyMinutesAgo	= Datetime.now().addMinutes(-30);
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            WHERE	//Secret_Code__c = :cleanedConfirm	AND
             		Account__c = :acctID
             AND	SMS_Timestamp__c > :thirtyMinutesAgo
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        if(attList.size() > 0 ){
            if(attList[0].Secret_Code__c == cleanedConfirm){
                // redirect to the account manager page
            	return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Home','a,s',acctID+','+cleanedConfirm);
            } else {
                pageStatus	= 'confirm-fail';
            	return null;
            }
        } else {
            pageStatus	= 'confirm-fail';
            return null;
        }
    }
    
    public PageReference lookupAccount(){
        // clean the input
        String cleanedPhone = phoneNumber.replaceAll('[^0-9]', '');
        
        // look up the account
        List<Account> acctList = [
            SELECT	id,
            		C501_Class_Site_Mobile_Number__c,
            		C501_Class_Site_Mobile_Number_Lookup__c
            FROM	Account
            WHERE	RecordType.Name = 'Household Account'
             AND	C501_Class_Site_Mobile_Number_Lookup__c		= :cleanedPhone
             AND	C501_Class_Site_Mobile_Number__c 			!= null
        ];
        if(acctList.size() > 0 ){
            // set acctID
            acctID	= acctList[0].id;
            // send the sms
            C501_UTIL_ClassRegUtilities.sendSMS(acctID);
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