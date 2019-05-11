public class C501_UTIL_ClassRegUtilities {
    
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