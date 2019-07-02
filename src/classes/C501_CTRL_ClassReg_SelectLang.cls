public class C501_CTRL_ClassReg_SelectLang {
    public string language {get;set;}
    
    public List<SelectOption> getListOfLangs(){
        List<SelectOption> langList = new List<SelectOption>();
        langList.add(new SelectOption('en-us', 'English'));
        
        //langList.add(new SelectOption('nl_NL', 'عربى'));
        langList.add(new SelectOption('es_MX', 'Español'));
        //langList.add(new SelectOption('fr', 'Francais'));
        //langList.add(new SelectOption('zh_CN', '中文'));
        //langList.add(new SelectOption('fi', 'Tiếng Việt'));
        
        return langList;
    }
    
    public PageReference changeLang() {
        Map<String,String> currentPageParameters = ApexPages.currentPage().getParameters();
        return C501_UTIL_ClassRegUtilities.generatePageLink('C501_ClassReg_Login','l',language);
    }
    
    public C501_CTRL_ClassReg_SelectLang(){
        
        language = System.currentPagereference().getParameters().get('lang');
        
    }
}