/*
@author : Magesh Mani Yadav
@Description: This class is used to create and edit the Business rules 
@reviewer : 
@creation : 21.08.2014
*/
public with sharing class CtrBusinessConfig {
    
    public Business_Config__c genericObj {get;set;}
    public Map<integer,Business_Config__c> mapBusinessRule {get;set;}
    @TestVisible private Integer counter {get;set;}
    public Boolean renderProcessDetails {get;set;}
    public Integer removeBusinessRule {get;set;}
    public Boolean createdNew {get;set;}
    private List<Business_Config__c> listDeleteBusinessRule {get;set;}
    /*public CustomTasks__c CustomTasks{get;set;}
    public Boolean renderTaskSection {get;set;}
    @TestVisible private Integer taskCounter {get;set;}*/
    public Boolean buttonPanel{get;set;}
    public Integer editBusinessRule {get;set;}
    public Boolean renderUpdateButton {get;set;}
    
    public CtrBusinessConfig(ApexPages.StandardController controller){
        Business_Config__c tempGenericObj = (Business_Config__c) controller.getRecord();
        /*CustomTasks = new CustomTasks__c();
        renderTaskSection = false;
        taskCounter=0;*/
        this.buttonPanel = true;
        this.renderUpdateButton =false;
        System.debug('this.tempGenericObj: '+tempGenericObj);
        Boolean noParent=false;
        mapBusinessRule = new Map<integer,Business_Config__c>();
        listDeleteBusinessRule = new List<Business_Config__c>();
        counter = 0;
        renderProcessDetails = true; 
        if(tempGenericObj.id!=null){
            createdNew = false;
            if(tempGenericObj.Type__c!='Trigger'){
                noParent = true;
                for(Business_Config__c gObj : [Select id, Process_Name__c,Parent__c,Description__c, Is_Active__c,Type__c, Id_Country__c,Record_Type_Id__c, 
                                                            Business_Rule_Name__c,Business_Rule_Value__c,Is_Json__c 
                                                            from Business_Config__c 
                                                            where Process_Name__c =:tempGenericObj.Process_Name__c and 
                                                            Id_Country__c =:tempGenericObj.Id_Country__c and Record_Type_Id__c =:tempGenericObj.Record_Type_Id__c ]){
                    if(gObj.Parent__c==true){
                        this.genericObj = gObj;
                        noParent = false;
                    }else{
                        counter++;
                        mapBusinessRule.put(counter,gObj);
                    }
                    /*if(gObj.Is_Json__c){
                     Integer index = Integer.valueOf((gObj.Business_Rule_Name__c).subString(4,(gObj.Business_Rule_Name__c).length()));
                     if(index > taskCounter)
                        taskCounter = index;
                    }*/
                    
                }
            }else{
                this.genericObj = tempGenericObj;
                renderProcessDetails = false;
            }
            if(noParent){
                Business_Config__c temObj = mapBusinessRule.values()[0];
                this.genericObj = new Business_Config__c(Type__c='Process',Process_Name__c=temObj.Process_Name__c,Parent__c=true,Id_Country__c=temObj.Id_Country__c,Record_Type_Id__c=temObj.Record_Type_Id__c);
            }
        }else{
            this.genericObj = new Business_Config__c();
            this.genericObj.Parent__c = true;
            createdNew = true;
        }
    }
    
  /* public void saveJson(){
        String JSONString = JSON.serialize(CustomTasks);
        System.debug('JSONString: '+JSONString);
        taskCounter++;
        Business_Config__c newBusinessRule = new Business_Config__c(Business_Rule_Name__c='Task'+taskCounter,Is_Json__c=true,Business_Rule_Value__c=JSONString);
        counter++;
        mapBusinessRule.put(counter,newBusinessRule);
        this.renderTaskSection = false;
        this.CustomTasks = new CustomTasks__c();
        this.buttonPanel = true;
    }
   public void addTask(){
       this.CustomTasks = new CustomTasks__c();
       this.renderTaskSection = true;
       this.buttonPanel = false;
   }
  
   public void editRule(){
    this.renderTaskSection = true;
    this.renderUpdateButton =true;
       this.buttonPanel = false;
        if(mapBusinessRule.get(editBusinessRule).Business_Rule_Value__c!=null){
        this.CustomTasks = LibJSONHelper.parseJsonToCustomTask(mapBusinessRule.get(editBusinessRule).Business_Rule_Value__c);
        }       
    }
    
    public void updateTask(){
        this.renderTaskSection = false;
        this.buttonPanel = true;
        this.renderUpdateButton =false;
        String JSONString = JSON.serialize(CustomTasks);
        Business_Config__c updateBusinessRule = mapBusinessRule.get(editBusinessRule).clone(false,true,false);
        updateBusinessRule.Business_Rule_Value__c = JSONString;
        if(mapBusinessRule.get(editBusinessRule).id!=null){
            listDeleteBusinessRule.add(mapBusinessRule.get(editBusinessRule));
        }
        mapBusinessRule.remove(editBusinessRule);
        mapBusinessRule.put(editBusinessRule,updateBusinessRule);
        
              
    }

    public void cancelTask(){
        this.renderTaskSection = false;
        this.renderUpdateButton =false;
        this.buttonPanel = true;
        this.CustomTasks = new CustomTasks__c();

    }*/
    
    public PageReference saveRecords(){
    //this.renderTaskSection = false;
        System.debug('mapBusinessRule: '+mapBusinessRule);
        if(validate()){
                upsert this.genericObj;
                upsert mapBusinessRule.values();
                if(!listDeleteBusinessRule.isEmpty()){
                    delete listDeleteBusinessRule;
                }
            Schema.DescribeSObjectResult GenericProcessConfigObjectSchema = Business_Config__c.SObjectType.getDescribe();
            String objectIdPrefix = GenericProcessConfigObjectSchema.getKeyPrefix();
            PageReference pageReference = new PageReference('/'+objectIdPrefix);
            pageReference.setRedirect(true);
            return pageReference;
        }
        return null; 
    }
    
    public void changeType(){ 
        if(this.genericObj.Type__c=='Trigger'){
            renderProcessDetails = false;
        }else{
            renderProcessDetails = true;
        }
    }
    
    public void addBusinessRule(){
    //this.renderTaskSection = false;
        Business_Config__c newBusinessRule = new Business_Config__c();
        counter++;
        mapBusinessRule.put(counter,newBusinessRule);
        
    }
    
    public void removeBusinessRule(){
    //this.renderTaskSection = false;
        if(mapBusinessRule.get(removeBusinessRule).id!=null){
        listDeleteBusinessRule.add(mapBusinessRule.get(removeBusinessRule));
        }
        mapBusinessRule.remove(removeBusinessRule);
    }
    
    public Boolean validate(){
        if(this.genericObj.Type__c == 'Trigger'){
            if(genericObj.Process_Name__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Missing value for Process Name'));
                return false;
            }else{
                this.genericObj.Business_Rule_Name__c = null;
                this.genericObj.Business_Rule_Value__c = null;
                this.genericObj.Id_Country__c = null;
                this.genericObj.Record_Type_Id__c = null;
                mapBusinessRule = new Map<integer,Business_Config__c>();
            }
        }else if(this.genericObj.Type__c == 'Process'){
            if(genericObj.Process_Name__c!=null && genericObj.Id_Country__c!=null && genericObj.Business_Rule_Name__c!=null && genericObj.Business_Rule_Value__c!=null){
                    for(Business_Config__c subrules : mapBusinessRule.values()){
                        if(subrules.Business_Rule_Name__c ==null || subrules.Business_Rule_Value__c==null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Missing values for Business Rule Name, Business Rule Value'));
                            return false;
                        }
                        subrules.Process_Name__c = genericObj.Process_Name__c;
                        subrules.Record_Type_Id__c = genericObj.Record_Type_Id__c;
                        subrules.Is_Active__c = genericObj.Is_Active__c;
                        subrules.Id_Country__c = genericObj.Id_Country__c;
                        subrules.Type__c = genericObj.Type__c;
                        subrules.Parent__c = false;
                    }
            }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Missing values for Process Name, Country, Business Rule Name, Business Rule Value'));
                 return false;
            }
        }else{
            return false;
        }
        return true;
    }
}