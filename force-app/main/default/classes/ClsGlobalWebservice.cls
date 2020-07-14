global class ClsGlobalWebservice {
       public static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Task'});

    webservice String parameter { get; set; }

    public ClsGlobalWebservice() {
        this.parameter = 'value';
    }

    //webservice static String serviceName(){
    //    return '';
    //}

    webservice static String getTaskRecordType(String objId){
        try{
            Schema.SObjectType token = Id.valueOf(objId).getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String errormsg = 'Save log Failed: recordtype for Task is not defined';
            String objectName = dr.getName();
            String taskrecordtypeId;
            String queryString;
            String accountID;
                if(objectName=='Contact'){
                    queryString = 'SELECT AccountID, recordtype.DeveloperName FROM ' + objectName + ' WHERE Id=\'' + objId + '\'';
                }else{
                    queryString = 'SELECT recordtype.DeveloperName FROM ' + objectName + ' WHERE Id=\'' + objId + '\'';
                }
            sObject[] objDBList = Database.query(queryString);
            if(objectName=='Contact'){
                accountID = (String) objDBList[0].get('AccountID');
            }
            //System.debug('objDBList[0]: '+objDBList[0]);
            String stg = JSON.serialize(objDBList[0]);
            List<String> splitDB = stg.split('"DeveloperName":"');
            String currentObjRecordtype = splitDB[1].substringBefore('"');
            if(objDBList!=null && !objDBList.isEmpty()){
                List<String> splitted =  currentObjRecordtype.split('_'+objectName);
                String taskrecordtype = splitted[0]+'_Task';
                if(mapRecordTypes.get(taskrecordtype)!=null){
                    taskrecordtypeId = mapRecordTypes.get(taskrecordtype).Id;
                }else{
                    ClsLogErrorMessage.logMessages('Twilio', errormsg);
                    return errormsg;
                }
            }else{
                ClsLogErrorMessage.logMessages('Twilio', errormsg);
                return errormsg;
            }

            String OppQuery = 'Select Id,Name from Opportunity where ';
             String csQuery = 'Select Id,Subject,caseNumber from Case where status!=\'Closed\' AND ';
            
            if(objectName=='Contact'){
                OppQuery += 'AccountID = \''+accountID+'\'';
                csQuery+= 'AccountID = \''+accountID+'\'';
            }else if(objectName=='Account'){
                OppQuery += 'AccountID = \''+objId+'\'';
                csQuery+= 'AccountID = \''+objId+'\'';
                
            }
            WrapperData wdata;
            if(objectName=='Contact' || objectName=='Account'){
                //System.debug('OppQuery: '+OppQuery);
                List<Opportunity> opps = (List<Opportunity>) Database.query(OppQuery);
                List<Case> cases =(List<case>)Database.query(csQuery);
                if(((opps!=null && opps.isEmpty()) || opps==null) && (cases==null || cases.isEmpty())){
                    wdata =  new WrapperData(taskrecordtypeId);
                }
                else if((opps!=null && !opps.isEmpty()) && (cases==null && cases.isEmpty())){
                    wdata =  new WrapperData(taskrecordtypeId,opps);
                }

                else{
                    wdata =  new WrapperData(taskrecordtypeId,opps,cases);
                }
            }else{
               wdata =  new WrapperData(taskrecordtypeId); 
            }

            //System.debug('wdata: '+wdata);
            return Json.serialize(wdata);
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            ClsLogErrorMessage.logMessages('Twilio', e.getMessage()+ e.getStackTraceString()+' :: '+objId);
            return e.getMessage();
        }
    }


    global class WrapperData{
        List<Opportunity> opps;
        String taskTemplateId;
        List<case> cases;

        global WrapperData(String taskTemplateId, List<Opportunity> opps){
            this.opps = opps;
            this.taskTemplateId = taskTemplateId;
            this.cases=null;
        }
        global WrapperData(String taskTemplateId){
            this.taskTemplateId = taskTemplateId;
            this.opps = null;
            this.cases=null;
        }
        global WrapperData(String taskTemplateId, List<Opportunity> opps,List<Case> cases){
            this.opps = opps;
            this.taskTemplateId = taskTemplateId;
            this.cases=cases;
        }
    }
}