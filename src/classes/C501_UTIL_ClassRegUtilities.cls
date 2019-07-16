public class C501_UTIL_ClassRegUtilities {
    
    public static String getRegionFromAddy(String city,String state){
        // to do: make this a setting that TBG staff can edit
        if(state == 'DC' || state == 'MD' || state == 'VA' || state == 'Virginia' || state == 'Maryland'){
            return 'DC';
        } else if(state == 'WA' || state == 'Washington'){
            return 'Seattle';
        } else if (state == 'CA' || state == 'California'){
            return 'SF Bay';
        } else {
            return null;
        }
    }
    
    public static List<SelectOption> listOfGrades(){
        
        List<SelectOption> gradeList 	= new List<SelectOption>();
        gradeList.add(new SelectOption( '', 'Select One: ') );
        
        for(Integer i = 1;i <= 12; i++){
            gradeList.add(new SelectOption( String.valueOf(i), String.valueOf(i) ) ); 
        }
        
        return gradeList;
    }
    
    public static String currentSchoolYear(Date currentDate){
        String returnYear 	= '';
        if( currentDate.month() >= 7 ){
            returnYear = String.valueOf( currentDate.year() ) + '-' + String.valueOf( currentDate.year() + 1 );
        } else {
            returnYear = String.valueOf( currentDate.year() - 1) + '-' + String.valueOf( currentDate.year() );
        }
        return returnYear;
    }
    
    public static String getGraduatingYearFromCurrentGrade(Integer grade){
        Integer thisYear 	= Date.today().year() ;  
        String returnYear 	= '';
        if( Date.today().month() >= 7 ){
            returnYear = String.valueOf(thisYear + (13 - grade));
        } else {
            returnYear = String.valueOf(thisYear + (12 - grade)); 
        }
        return returnYear;
    }
    
    public static PageReference confirmLogin(String confirmation,ID acctID,Boolean remember,String language){
        String pageStatus	= C501_UTIL_ClassRegUtilities.checkVerificationCode(confirmation,acctID);
        
        if(pageStatus == 'success'){
            // redirect to the account manager page
            String remString = '';
            if(remember){
                remString = '1';
            } else {
                remString = '0';
            }
            return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Home','a,s,r,l',acctID+','+confirmation.replaceAll('[^0-9]', '')+','+remString+','+language);
        } else {
            return null;
        }
    }
    
    
    public static Boolean confirmLoggedIn(String loginID, Boolean timeCare){
        Integer timeModify = 0;
        if(timeCare){
            timeModify = -30;
        } else {
            // minutes in 6 months
            timeModify = -262980;
        }
        Datetime 	cutOffDateTime	= Datetime.now().addMinutes(timeModify);
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		SMS_Timestamp__c
            FROM	Class_Site_Login_Attempt__c
            WHERE	id = :loginID
             AND	SMS_Timestamp__c > :cutOffDateTime
            LIMIT 	1
        ];
        return attList.size() > 0;
    }
    
    public static PageReference confirmLoginByCodeToAddress(String confirmation,String codeToAddress,Boolean remember,String language){
        String pageStatus	= checkVerificationCodeByCodeToAddress(confirmation,codeToAddress);
        if(pageStatus != 'confirm-fail'){
            // redirect to the account manager page
            String remString = '';
            if(remember){
                remString = '1';
            } else {
                remString = '0';
            }
            return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_CreateAcct','a,r,c,l',pageStatus+','+remString+','+codeToAddress+','+language);
        } else {
            return null;
        }
    }
    
    public static String checkVerificationCodeByCodeToAddress(String input, String codeToAddress){
        String 		cleanedConfirm 		= input.replaceAll('[^0-9]', '');
        Datetime 	thirtyMinutesAgo	= Datetime.now().addMinutes(-30);
        
        List<Class_Site_Login_Attempt__c> attList = [
            SELECT 	id,
            		Account__c,
            		Secret_Code__c,
            		SMS_Timestamp__c,
            		Login_Attempts__c,
            		Login_IP_Address__c,
            		Code_Sent_To__c,
            		Verified__c
            FROM	Class_Site_Login_Attempt__c
            WHERE	Code_Sent_To__c = :codeToAddress
             AND	SMS_Timestamp__c > :thirtyMinutesAgo
            ORDER BY SMS_Timestamp__c DESC
            LIMIT 	1
        ];
        if(attList.size() > 0 ){
            if(attList[0].Secret_Code__c == cleanedConfirm){
                attList[0].Verified__c = true;
                update attList[0];
                return attList[0].Id;
            } else {
                attList[0].Login_Attempts__c++;
                update attList;
                return 'confirm-fail';
            }
        } else {
            return 'confirm-fail';
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
    
    public static void sendConfirmationCodeWOacctID(String input){
        if(input.contains('@')){
            sendEmailConfirmation(null,input);
        } else {
            sendSMS(null,input);
        }
    }
    
    public static void sendEmailConfirmation(ID AcctID, String emailAddress){
        Class_Site_Login_Attempt__c att 	= generateLoginCode(AcctID, emailAddress);
        String message 		= Label.C501_ClassReg_CodeMessage + ' '+att.Secret_Code__c + ' ' +Label.C501_ClassReg_CodeMessageDisclaim+' '+Label.C501_ClassReg_CodeMessageExpire;
        SendEmailGeneric('salesforce@techbridgegirls.org',emailAddress,Label.C501_ClassReg_ConfirmCodeSubject,message);
        insert att;
    }
    
    public static void SendEmailGeneric(String fromAddress,String toAddress,String subject,String message){
        // Blatantly stolen from here: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_forcecom_email_outbound.htm
        
        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        Messaging.reserveSingleEmailCapacity(1);
        
        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.
        
        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Strings to hold the email addresses to which you are sending the email.
        List<String> toAddresses = new List<String>();
        toAddresses.add(toAddress);
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo(fromAddress);
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('Techbridge Girls');
        
        // Specify the subject line for your email address.
        mail.setSubject(subject);
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(message);
        
        mail.setHtmlBody('<p>'+message+'</p>');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    
    public static Class_Site_Login_Attempt__c generateLoginCode(ID AcctId,String codeSentTo){
        Class_Site_Login_Attempt__c att	= new Class_Site_Login_Attempt__c(
            Account__c 			= AcctID,
            Login_Attempts__c	= 0,
            Secret_Code__c		= C501_UTIL_ClassRegUtilities.generateRandomString(6,true,false,false),
            SMS_Timestamp__c	= datetime.now(),
            Code_Sent_To__c     = codeSentTo
            //Login_IP_Address__c = GetUserIPAddress()
        );
        
        return att;
    }
    
    @future(callout=true)
    public static void sendSMSGenericFuture(String phoneNumber, String message){
        sendSMSGeneric(phoneNumber,message);
    }
    
    
    public static void sendSMSGeneric(String phoneNumber, String message){
        TwilioConfig__c tcon = [SELECT id, AccountSid__c, AuthToken__c,	Default_Send_Number__c FROM TwilioConfig__c WHERE Name = 'default' LIMIT 1];
        
        if (!Test.isRunningTest()){
            TwilioRestClient client = new TwilioRestClient(tcon.AccountSid__c, tcon.AuthToken__c);
            Map<String,String> params = new Map<String,String> {
                'To'   => '+1'+phoneNumber,
                'From' => tcon.Default_Send_Number__c,
                'Body' => message
            }; 
            TwilioSMS sms = client.getAccount().getSMSMessages().create(params);
        }
    }
    
    public static void sendSMS(ID AcctID,String phoneNumber){
        Class_Site_Login_Attempt__c att = generateLoginCode(AcctId, phoneNumber);
        sendSMSGeneric(phoneNumber,Label.C501_ClassReg_CodeMessage + ' '+att.Secret_Code__c + ' ' + Label.C501_ClassReg_CodeMessageDisclaim+' '+Label.C501_ClassReg_CodeMessageExpire);
        insert att;
    }

    public static string cleanInputGeneric(String input){
        if(input.contains('@')){
            return verifyValidEmail(input);
        } else {
            return cleanInputPhone(input);
        }
        
    }
    
    public static string verifyValidEmail(String input){
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(input);
        if (!MyMatcher.matches()){
            return null;
        } else {
            return input;
        }
    } 
    
    public static string cleanInputPhone(String input){
        // to do: clean the string to make sure first number is not '1' and that there are 10 digits.
        String output = input.replaceAll('[^0-9]', '');
        if(output.left(1) == '1'){
            output = output.right( output.length()-1 );
        }
        if(output.length() != 10){
            return null;
        }
        return output;
    }
    
    public static string NAformatPhone(String input){
        String output = cleanInputPhone(input);
        if(output == null){
            return null;
        } else {
            return '('+output.left(3)+') '+output.left(6).right(3)+'-'+output.right(4);
        }
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
    
    public static void logActivityToContact(Id contactId,String subject, String message,String messageType){
        Task log = new Task(
        	Description = message,
            WhoId		= contactId,
            Priority 	= 'Normal', 
            Subject		= subject,
            Status		= 'Completed',
            CallType 	= 'Outbound',
            Type		= messageType,
            Activity_Report_Type__c = 'Programs',
            ReminderDateTime = System.now()+1
        );
        insert log;
    }
    
    /*public void ObjectsFieldMerge(Account masterObject, List<Account> duplicateObjects){ 
        Set<Id> mergeCandidates = new Set<Id> { 
            masterObject.Id 
        };
        
        for (Account objectItem :duplicateObjects){ 
	        mergeCandidates.add(objectItem.Id); 
        }
        Map<String, Schema.SObjectField> 			objectFields 				= Schema.SObjectType.Account.fields.getMap();
        Map<String, Schema.DescribeFieldResult> 	standardFieldMap 			= new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> 	customFieldMap 				= new Map<String, Schema.DescribeFieldResult>();
     
     	//C501_MassMerge_SharedCode c501MassMerge_SharedCode =newC501_MassMerge_SharedCode();
     
        // Construct the query string
        String query ='Select ';
        for (String fieldName :objectFields.keySet()) {
        	Schema.SObjectField f =objectFields.get(fieldName);
            Schema.DescribeFieldResult fResult =f.getDescribe();
         
			// Ignore fields that have an identical API name as an npsp prefixed field
            // This is due to a bug in dynamic SOQL, which causes querying for two real fields,
            // e.g. npsp_fooc and foo_c, to throw a duplicate field selected error.
            // Only select the NPSP namespaced field and ignore the same field without namespace
            /* if (!fieldName.startsWith('npsp__') &&
				objectFields.containsKey(UTIL_Namespace.StrTokenNSPrefix(fieldName)))

			{   continue; }
				//
             
            // Only include the fields which are updateable and accessible
            if (fResult.isUpdateable() && fResult.isAccessible() /*&&!c501MassMerge_SharedCode.isNPSPHiddenField(fieldname) /// ) {
             
             	// If the field is type lookup, then ignore in the merge fields because is handled during the object merge
             	string relName =fResult.getRelationshipName();
             	if (string.isBlank(relName)){ 
                    query+= (fieldName+','); 
                } else { 
                    continue; 
                }
             	if(fResult.isCustom()) { 
                    customFieldMap.put(fieldName, fResult); 
                } else { 
                    standardFieldMap.put(fieldName, fResult); 
                }
         	}
     	}
     
        query+='Id from Account where Id IN :mergeCandidates';
        //System.debug('***** C501_MassMerge_SharedCode::ObjectsFieldMerge - The Account query is: ' + query);
     
     	List<Account> objectList;
     	try {
        	objectList=Database.query(query); // Query the records
         
         	// Ensure we got back the same number of records as expected. In case any record got deleted/moved since last search.
         	if (objectList==null||objectList.size() !=mergeCandidates.size()){ 
                System.debug('***** C501_MassMerge_SharedCode::ObjectsFieldMerge Query failed to return expected number of objects'); 
                return; 
            }
         	// Merge fields into master
         	SObject masterRecord = null;
         	for (SObject objectItem :objectList) {
                // Check to assign master object
                if (masterRecord==null){ 
                    masterRecord=objectItem; continue; 
                }
             	for (String fieldName :standardFieldMap.keySet()) {
                	if ( (masterRecord.get(fieldName) == null 
                          || String.isBlank(String.valueOf(masterRecord.get(fieldName)))
                         ) && 
                         objectItem.get(fieldName) <> null && 
                         !String.isBlank(String.valueOf(objectItem.get(fieldName)))) 
                    {
                    	try { 
                            masterRecord.put(fieldName, objectItem.get(fieldName)); 
                        } catch (Exception e) { 
                            System.debug('***** C501_MassMerge_SharedCode::ObjectsFieldMerge Update Merge Standard Field - fieldName: '+fieldName+' Exception: '+String.valueOf(e.getMessage())); 
                        }
                    }
                }
             
             	for (String fieldName :customFieldMap.keySet()) {
                	if ( (masterRecord.get(fieldName) == null || String.isBlank(String.valueOf(masterRecord.get(fieldName)))) &&
                    	  objectItem.get(fieldName) <> null && 
                          !String.isBlank(String.valueOf(objectItem.get(fieldName)))) 
                    {
                    	try{ 
                            masterRecord.put(fieldName, objectItem.get(fieldName)); 
                        } catch (Exception e){ 
                            System.debug('***** C501_MassMerge_SharedCode::ObjectsFieldMerge Update Merge Custom Field - fieldName: '+fieldName+' Exception: '+String.valueOf(e.getMessage())); 
                        }
                    }
             	}
         	}
         
         	Database.SaveResult updateResult = Database.update((Account)masterRecord, false);
         	if (!updateResult.isSuccess()) {
            	for (Database.Error err :updateResult.getErrors()){ 
                    System.debug('***** C501_MassMerge_SharedCode::ObjectsMerge Account Merge Exception: '+err.getMessage()); 
                }
         	}
     	} catch (Exception e){ 
            System.debug('***** C501_MassMerge_SharedCode::ObjectsFieldMerge update fields exception: '+String.valueOf(e.getMessage())); 
        }
    }*/
    
    /*public static String GetUserIPAddress() {
        // Blatantly stolen from here: https://www.forcetalks.com/salesforce-topic/how-to-get-ip-address-of-user-in-salesforce-apex/
        string ReturnValue ='';
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if (ReturnValue == '') {
        	ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
        	system.debug('USER IP ADDRESS: ' + ReturnValue);
        	return ReturnValue;
    }*/
    
    
}