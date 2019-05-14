public class C501_UTIL_ClassRegUtilities {
    
    public static PageReference confirmLogin(String confirmation,ID acctID,Boolean remember){
        String pageStatus	= C501_UTIL_ClassRegUtilities.checkVerificationCode(confirmation,acctID);
        
        if(pageStatus == 'success'){
            // redirect to the account manager page
            String remString = '';
            if(remember){
                remString = '1';
            } else {
                remString = '0';
            }
            return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Home','a,s,r',acctID+','+confirmation.replaceAll('[^0-9]', '')+','+remString);
        } else {
            return null;
        }
    }
    
    public static String checkVerificationCode(String input, ID acctID){
        String 		cleanedConfirm 		= input.replaceAll('[^0-9]', '');
        Datetime 	thirtyMinutesAgo	= Datetime.now().addMinutes(-30);
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c
            FROM	Class_Site_Login_Attempt__c
            WHERE	Account__c = :acctID
             AND	SMS_Timestamp__c > :thirtyMinutesAgo
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        if(attList.size() > 0 ){
            if(attList[0].Secret_Code__c == cleanedConfirm){
                return 'success';
            } else {
                attList[0].Login_Attempts__c++;
                update attList;
                return 'confirm-fail';
            }
        } else {
            return 'confirm-fail';
        }
    }
    
    public static String lookupAccountByPhone(String phone){
        List<Account> acctList = [
            SELECT	id,
            		C501_Class_Site_Mobile_Number__c,
            		C501_Class_Site_Mobile_Number_Lookup__c
            FROM	Account
            WHERE	RecordType.Name = 'Household Account'
             AND	C501_Class_Site_Mobile_Number_Lookup__c		= :phone
             AND	C501_Class_Site_Mobile_Number__c 			!= null
        ];
        if(acctList.size() > 0){
            return acctList[0].Id;
        } else {
            return null;
        }
    }
    
    public static void sendSMS(ID AcctID,String phoneNumber){
        
        TwilioConfig__c tcon = [SELECT id, AccountSid__c, AuthToken__c,	Default_Send_Number__c FROM TwilioConfig__c WHERE Name = 'default' LIMIT 1];
        
        Class_Site_Login_Attempt__c att	= new Class_Site_Login_Attempt__c(
            Account__c 			= AcctID,
            Login_Attempts__c	= 0,
            Secret_Code__c		= C501_UTIL_ClassRegUtilities.generateRandomString(6,true,false,false),
            SMS_Timestamp__c	= datetime.now()
        );
		
		if (!Test.isRunningTest()){
            TwilioRestClient client = new TwilioRestClient(tcon.AccountSid__c, tcon.AuthToken__c);
            
            Map<String,String> params = new Map<String,String> {
                    'To'   => '+1'+phoneNumber,
                    'From' => tcon.Default_Send_Number__c,
                    'Body' => 'Hello there! Your code is: '+att.Secret_Code__c
                };
                    
            TwilioSMS sms = client.getAccount().getSMSMessages().create(params);
        }

        insert att;
    }

    public static string cleanInputPhone(String input){
        // to do: clean the string to make sure first number is not '1' and that there are 10 digits.
        input.replaceAll('[^0-9]', '');
        return input;
    }
    
    public static String generateRandomString(Integer len, Boolean includeNumbers,Boolean includeUppers,Boolean includeLowers) {
        String chars = '';
        if(includeNumbers){
            chars = chars + '0123456789';
        }
        if(includeUppers){
            chars = chars + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        }
        if(includeLowers){
            chars = chars + 'abcdefghijklmnopqrstuvwxyz';
        }
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    public static PageReference generatePageLink(String nextPage,String parameter,String paraValue){
        String siteURL = '';
        if(Site.getBaseURL() == '' || Site.getBaseURL() == null){
            //We are in a logged-in testing environment that is not on a public site, so treat as vf page
            siteURL = '/apex';
        } else { 
            //We are on a public site
            siteURL = Site.getBaseURL();
        }
        PageReference page = new PageReference( siteURL + '/' + nextPage );
        if(parameter != null && paraValue != null){
            if(parameter.contains(',')){
                List<String> splitPara 	= parameter.split(',');
                List<String> splitVal 	= paraValue.split(',');
                if(splitPara.size() == splitVal.size() ){
                    for(Integer i = 0;i<splitPara.size();i++){
                        page.getParameters().put(splitPara[i],splitVal[i]);
                    }
                }
            } else {
                page.getParameters().put(parameter,paraValue);
            }
        }
        return page;
    }

}