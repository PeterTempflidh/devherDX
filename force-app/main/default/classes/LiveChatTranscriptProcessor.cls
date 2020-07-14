/**
* @author Krunoslav Bilicic
* @date 14.2.2019.
* 
* @group Case
*
* @description This class is being called from a trigger handler (before insert) to create a case from chat.
* It can be called from anywhere but this is it's intended purpose
*/
public inherited sharing class LiveChatTranscriptProcessor {

    /**
    * @author Krunoslav Bilicic
    * @date 14.2.2019.
    * 
    * @group Case
    *
    * @description This class is used for deserialization of JSON read from a business config.
    * Value is a hardcoded value
    * Field Value OR field ChatField have to be set, not both, not none of them, just one
    */
    public class FieldMapping {
        public String  CaseField;
        public String  ChatField;
        public String  Value;  
        
        public FieldMapping()
        {
        }
    }
        
    /**
    * @description Updates case owner by copying from chat owner only if new owner is a user record
    * @param chatRecord LiveChatTranscript record from which owner is copied
    * @return updated case record
    */
    public static Case UpdateCaseOwner(LiveChatTranscript chatRecord, Case existingCase) {
        if(chatRecord != null && chatRecord.CaseId != null && existingCase!=null) {
            if(chatRecord.OwnerId != existingCase.OwnerId && ((String)chatRecord.OwnerId).startsWith('005')) {
                existingCase.OwnerId = chatRecord.OwnerId;
                return existingCase;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    /**
    * @description Creates and returns a case record created from a chat record, but doesn't insert it
    * @param chatRecord LiveChatTranscript record from which values are copied to case fields. 
    * Business config called ChatToCase defines which field get copied over to a Case record
    * @return new case record
    */
    public static Case CreateCaseFromChat(LiveChatTranscript chatRecord) {
        // create new case only if it doesn't exist
        if(chatRecord.CaseId != null)
            return null;
        
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic;
        Map<String, Business_Config__c> mapBusinessRules;
        String fieldMappingJson;
        Boolean isPresent=false;
        Map<String,List<String>> typeListByLevel1 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_1__c, Case.Type);
        Map<String,List<String>> L1ListByL2 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_2__c, Case.Case_Reason_Level_1__c);
        Map<String,List<String>> L2ListByL3 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_3__c, Case.Case_Reason_Level_2__c);
        if(moam != null) {
            mapBusinessLogic = moam.get('ChatToCase');
        }
        if(mapBusinessLogic != null) {
            mapBusinessRules = mapBusinessLogic.get(chatRecord.Platform__c);
        }
        if(mapBusinessRules != null) {
            fieldMappingJson = mapBusinessRules.get('FieldsMap').Business_Rule_Value__c;
        }
        if(fieldMappingJson != null && !String.isBlank(fieldMappingJson)) {
            try {
                List<LiveChatTranscriptProcessor.FieldMapping> mappingList = (List<LiveChatTranscriptProcessor.FieldMapping>)JSON.deserializeStrict(fieldMappingJson ,List<LiveChatTranscriptProcessor.FieldMapping>.class);
                Boolean isCaseReasonMappingPresent = false;
                Case newChatCase = new Case();
                for(FieldMapping mapping : mappingList) {
                    if(mapping.CaseField != null) {
                        if(mapping.Value != null) {
                            //set value defined in Business Config
                            newChatCase.put(mapping.CaseField, mapping.Value);
                        } else if(mapping.ChatField != null && chatRecord.get(mapping.ChatField) != null) {
                            // copy value from Chat field
                            newChatCase.put(mapping.CaseField,chatRecord.get(mapping.ChatField));
                        }
                        if( mapping.CaseField.contains('Case_Reason_Level_') ) {
                            isCaseReasonMappingPresent=true;
                        }
                    }
                }
                //Check Case Reasons Dependencies only if the mapping is present.
                if( isCaseReasonMappingPresent ) {
                    if(L2ListByL3.containsKey(newChatCase.Case_Reason_Level_3__c) && L2ListByL3.get(newChatCase.Case_Reason_Level_3__c)!=null && L2ListByL3.get(newChatCase.Case_Reason_Level_3__c).contains(newChatCase.Case_Reason_Level_2__c)) {
                        if(L1ListByL2.containsKey(newChatCase.Case_Reason_Level_2__c) && L1ListByL2.get(newChatCase.Case_Reason_Level_2__c)!=null && L1ListByL2.get(newChatCase.Case_Reason_Level_2__c).contains(newChatCase.Case_Reason_Level_1__c)) {
                            if(typeListByLevel1.containsKey(newChatCase.Case_Reason_Level_1__c) && typeListByLevel1.get(newChatCase.Case_Reason_Level_1__c)!=null && typeListByLevel1.get(newChatCase.Case_Reason_Level_1__c).contains(newChatCase.Type)) {
                                isPresent=true;
                            }
                        }
                    }
                    if(!isPresent) {
                        newChatCase.Case_Reason_Level_3__c = null;
                        newChatCase.Case_Reason_Level_2__c = null;
                        newChatCase.Case_Reason_Level_1__c = null;
                        newChatCase.Type=null;
                    }
                }
                return newChatCase;
            } catch (Exception ex) {
                LoggingUtility.logError(LiveChatTranscriptProcessor.class.getName(),'Error => ' + ex.getMessage() + '\nLine Number : ' + ex.getLineNumber());
                return null;
            } 
        }
        else {
            return null;
        }
    }
}