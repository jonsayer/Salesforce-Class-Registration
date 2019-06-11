How to Install

1) In the target org, install the Twilio Helper Library: https://github.com/twilio/twilio-salesforce
2) Ensure your target org has all of the fields associated with our fieldsets pre-installed. Those can be found in src/Objects, in the Account.object file and the Contact.object file. A TBG sandbox should work just fine.
3) Install this package to your instance.
4) After install, configure the Custom Settings for "TwilioConfig". 
    a) For TBG sites, please see those relevant docs.
    b) The settings must have the name "default", no quotes, all lower case.
5) Create a Force.com site with these permissions:
    a) Access to all of the Visualforce Pages in this package/
        i) C501_ClassReg_CreateAcct
        ii) C501_ClassReg_Home
        iii) C501_ClassReg_Login
    b) Set the site template to C501_ClassRegSiteTemplate
    c) Configure the PubliC Access Settings to have access to all of the fields on the Contact, Account, and School Term objects that are needed (this will shift through the lifetime of this project)
    d) Also, make sure the Public Access Settings have full access to the Class Site Login Attempt object.