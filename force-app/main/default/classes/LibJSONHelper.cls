public with sharing class LibJSONHelper {


    //under construction!!!!!!
    public static String createKRNPSMessageRestaurantCases(String suppliedEmail, String backendId, String owner, String caseNumber){
        JSONGenerator jsonGen = JSON.createGenerator(false);

        jsonGen.writeStartObject();
            jsonGen.writeFieldName('restaurant_cases');

            jsonGen.writeStartArray();
                for(Integer i = 0; i < 10000; i++){
                jsonGen.writeStartObject();
                    jsonGen.writeStringField('supplied__email', suppliedEmail);
                    jsonGen.writeStringField('owner', owner);
                    jsonGen.writeStringField('backend_id', backendId);
                    jsonGen.writeStringField('case_number', caseNumber);
                jsonGen.writeEndObject();
                }
            jsonGen.writeEndArray();
        jsonGen.writeEndObject();

        return jsonGen.getAsString();
    }


    public static String parseResponseForKRBackendId(String responseBody){
        JSONParser parser = JSON.createParser(responseBody);
        String id;

        while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'restaurant_id'){
                parser.nextToken();
                id = parser.getText(); 
                break;
            }   
        }
        
        return id;

    }

    public static String generateJSONMsg(Map<string,string> fieldValueMap){
        JSONGenerator jsonGen = JSON.createGenerator(true);          
        jsonGen.writeStartObject();
        for(string fieldName:fieldValueMap.keySet()){
            jsonGen.writeStringField(fieldName,fieldValueMap.get(fieldName));           
        }
        jsonGen.writeEndObject();         
        String jsonMsg= jsonGen.getAsString();
        return jsonMsg;              
    }


    public static String createdJSONMessage(String baseURI, String theCaseId){
        JSONGenerator jsonGen =  JSON.createGenerator(false);

        jsonGen.writeStartObject();
            jsonGen.writeStringField('id', theCaseId);
            jsonGen.writeStringField('url', baseURI + theCaseId + '/');
        jsonGen.writeEndObject();

        return jsonGen.getAsString();
    }

    public static String errorMessage(Map<String,String> mapErrorMessages){
        JSONGenerator jsonGen = JSON.createGenerator(false);

        jsonGen.writeStartObject();
            jsonGen.writeFieldName('errors');
            jsonGen.writeStartArray();
                for(String key : mapErrorMessages.keySet()){
                    jsonGen.writeStartObject();
                        jsonGen.writeStringField('message', key);
                        jsonGen.writeStringField('code', mapErrorMessages.get(key));
                    jsonGen.writeEndObject();
                }
            jsonGen.writeEndArray();
        jsonGen.writeEndObject();

        return jsonGen.getAsString();
    }

    public static String parseForId(String responseBody){
        JSONParser parser = JSON.createParser(responseBody);
        String id;
                    
        while(parser.nextToken() != null){
            System.debug('ClsJSONUtilities: parseForId: currentToken: ' + parser.getCurrentToken() +' Text ' + parser.getText());
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'id'){
                parser.nextToken();
                id = parser.getText(); 
                break;
            }   
        }
        
        return id;
    }
    
    public static String createBillingAccount(String billingCountry,
                                              String billingAddressLine,
                                              String ownerName,
                                              String accountName,
                                              String backendId
                                              )
    {

        JSONGenerator jsonGen = JSON.createGenerator(false);

        jsonGen.writeStartObject();
            jsonGen.writeStringField('country', billingCountry);
            jsonGen.writeStringField('billing_address', billingAddressLine);
            jsonGen.writeStringField('owner', ownerName);
            jsonGen.writeStringField('business_name', accountName);
            jsonGen.writeNumberField('business_id', Integer.valueOf(backendId));
        jsonGen.writeEndObject();

        return jsonGen.getAsString();
    }

    public static String createBackendAccount(String restaurantName,
                                               List<String> listEmailAddresses,
                                               List<String> listRelayMethods,
                                               List<String> listPaymentMethods,
                                               Boolean isTestRestaurant,
                                               String phone){
        
        JSONGenerator jsonGen = JSON.createGenerator(false);

        jsonGen.writeStartObject();
            jsonGen.writeStringField('name',restaurantName);
            jsonGen.writeFieldname('phone_numbers');
            jsonGen.writeStartArray();
                jsonGen.writeStartObject();
                    jsonGen.writeStringField('number',phone);
                    jsonGen.writeBooleanField('is_phone', true);
                jsonGen.writeEndObject();
            jsonGen.writeEndArray();
            jsonGen.writeFieldName('email_addresses');
            jsonGen.writeStartArray();
                for(String emailString : listEmailAddresses){
                    jsonGen.writeString(emailString);   
                }
            jsonGen.writeEndArray();
            jsonGen.writeFieldName('relay_methods');
            jsonGen.writeStartArray();
                for(String relayMethod : listRelayMethods){
                    jsonGen.writeString(relayMethod);
                }
            jsonGen.writeEndArray();
            jsonGen.writeBooleanField('is_test_restaurant',isTestRestaurant);
        jsonGen.writeEndObject();

        return jsonGen.getAsString();
    }

    /* kept for internal case
    public static CustomTasks__c parseJsonToCustomTask(String jsonString){
        CustomTasks__c c = (CustomTasks__c)JSON.deserialize(jsonString,CustomTasks__c.class);
        return c;
    }

    public static List<CustomTasks__c> parseJsonToCustomTasks(Map<String,Business_Config__c> mapBusinessRule,SObject rObject){
        List<CustomTasks__c> listCustomTasks= new List<CustomTasks__c>();
        Integer totalTask = Integer.valueOf(mapBusinessRule.get('totalInternalTaskCount').Business_Rule_Value__c);
        Case c;
        Opportunity opp;
        Contact cont;
        Lead l;
        CustomTasks__c cTask;
        if(rObject.getSObjectType()==Case.sObjectType){
                        c = (Case) rObject;
        }else if(rObject.getSObjectType() == Opportunity.sObjectType){
                        opp = (Opportunity) rObject;
        }else if(rObject.getSObjectType() == Contact.sObjectType){
                        cont = (Contact) rObject;
        }else if(rObject.getSObjectType() == Lead.sObjectType){
                        l = (Lead) rObject;
        }else if(rObject.getSObjectType() == CustomTasks__c.sObjectType){
                        cTask = (CustomTasks__c) rObject;
        }
        Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    if(c!=null){
                        task.Related_Case__c = c.id;
                        if(c.AccountId!=null){
                            task.RelatedAccount__c = c.AccountId;
                        }
                    }else if(opp!=null){
                        task.RelatedOpportunity__c = opp.id;
                        if(opp.AccountId!=null){
                            task.RelatedAccount__c = opp.AccountId;
                        }
                    }else if(cont!=null){
                        task.Related_Contact__c = cont.id;
                        if(cont.AccountId!=null){
                            task.RelatedAccount__c = cont.AccountId;
                        }
                    }else if(l!=null){
                        task.Related_Lead__c = l.id;
                    }else if(cTask!=null){
                        if(cTask.Related_Case__c!=null){
                            task.Related_Case__c = cTask.Related_Case__c;
                        }
                        if(cTask.RelatedAccount__c!=null){
                            task.RelatedAccount__c = cTask.RelatedAccount__c;
                        }
                        if(cTask.RelatedOpportunity__c!=null){
                            task.RelatedOpportunity__c = cTask.RelatedOpportunity__c;
                        }
                        if(cTask.Related_Contact__c!=null){
                            task.Related_Contact__c = cTask.Related_Contact__c;
                        }
                        if(cTask.Related_Lead__c!=null){
                            task.Related_Lead__c = cTask.Related_Lead__c;
                        }
                    }
                     listCustomTasks.add(task);  
                }                                    
                index++;
            }*/

       /* if(rObject.getSObjectType()==Case.sObjectType){
            Case c = (Case) rObject;
            Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    task.Related_Case__c = c.id;
                    if(c.AccountId!=null){
                        task.RelatedAccount__c = c.AccountId;
                    }
                    listCustomTasks.add(task);    
                }                                    
                index++;
            }

        }else if(rObject.getSObjectType()==Opportunity.sObjectType){
            Opportunity opp = (Opportunity) rObject;
            Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    task.RelatedOpportunity__c = opp.id;
                    if(opp.AccountId!=null){
                        task.RelatedAccount__c = opp.AccountId;
                    }
                    listCustomTasks.add(task);    
                }                                    
                index++;
            }
        }else if(rObject.getSObjectType()==Contact.sObjectType){
            Contact cont = (Contact) rObject;
            Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    task.Related_Contact__c = cont.id;
                    if(cont.AccountId!=null){
                        task.RelatedAccount__c = cont.AccountId;
                    }
                    listCustomTasks.add(task);    
                }                                    
                index++;
            }
        }else if(rObject.getSObjectType()==Lead.sObjectType){
            Lead lead = (Lead) rObject;
            Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    task.Related_Lead__c = lead.id;
                    listCustomTasks.add(task);    
                }                                    
                index++;
            }
        }else if(rObject.getSObjectType()==CustomTasks__c.sObjectType){
            CustomTasks__c cTask = (CustomTasks__c) rObject;
            Integer index = 1;
            while(index <= totalTask){
                if(mapBusinessRule.get('Task'+index)!=null && mapBusinessRule.get('Task'+index).Business_Rule_Value__c!=null && mapBusinessRule.get('Task'+index).Is_Json__c){
                    CustomTasks__c task = (CustomTasks__c)JSON.deserialize(mapBusinessRule.get('Task'+index).Business_Rule_Value__c,CustomTasks__c.class);
                    
                    if(cTask.Related_Case__c!=null){
                        task.Related_Case__c = cTask.Related_Case__c;
                    }
                    if(cTask.RelatedAccount__c!=null){
                        task.RelatedAccount__c = cTask.RelatedAccount__c;
                    }
                    if(cTask.RelatedOpportunity__c!=null){
                        task.RelatedOpportunity__c = cTask.RelatedOpportunity__c;
                    }
                    if(cTask.Related_Contact__c!=null){
                        task.Related_Contact__c = cTask.Related_Contact__c;
                    }
                    if(cTask.Related_Lead__c!=null){
                        task.Related_Lead__c = cTask.Related_Lead__c;
                    }
                    listCustomTasks.add(task);    
                }                                    
                index++;
            }
        }
        return listCustomTasks;
    }*/
}