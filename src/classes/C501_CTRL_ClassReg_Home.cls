public class C501_CTRL_ClassReg_Home {
    public String	acctID {get; set;}
    
    public C501_CTRL_ClassReg_Home(){
        acctID	= null;
        
        Cookie aId = ApexPages.currentPage().getCookies().get('AccountIdClassRegSite');
        if (aId != null){
            acctID = 'cookie found';//aId.getValue(); 
        } else {
            String acctPa = ApexPages.currentPage().getParameters().get('a');
            String secret = ApexPages.currentPage().getParameters().get('s');
            if(acctPa != null && secret != null){
                Datetime 	thirtyMinutesAgo	= Datetime.now().addMinutes(-30);
                List<Class_Site_Login_Attempt__c> attList = [
                    SELECT 	id,
                            Account__c,
                            Secret_Code__c,
                            SMS_Timestamp__c,
                            Login_Attempts__c
                    FROM	Class_Site_Login_Attempt__c
                    WHERE	Account__c = :acctPa
                     AND	SMS_Timestamp__c > :thirtyMinutesAgo
                    ORDER BY SMS_Timestamp__c DESC
                    LIMIT 	1
                ];
                if(attList.size() > 0 ){
            		if(attList[0].Secret_Code__c == secret){
                        acctID = attList[0].Account__c;
                        aId = new cookie('AccountIdClassRegSite', acctID, null, -1, false);
						ApexPages.currentPage().setCookies(new Cookie[] {aId});
                    } else {
                        acctID = 'fail to validate';
                    }
                } else {
                    acctID = 'didn\'t find';
                }
            } else {
                acctID = 'no provided variables';
            }
        }
    }
}