/**
* @author Alyana Navarro
* @date 21.01.2020
*
* @description Class that contains methods for Opportunity Quote Line Item
*/
public class ClsQuoteLineItemProcessor {
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    /**
    * @description Update Opportunity Quote Quote Type based on Quote Line Items.
    * @param Opportunity_Quote__c - Opportunity Quote to be updated.
    * @param Opportunity - Related Opportunity of the Quote.
    * @param Opportunity_Quote_Line_Item__c - Opportunity Quote Line Item to be checked.
    * @return Opportunity_Quote__c - Quote with updated Quote Type if Quote Line Item is matched
    **/
	public static Opportunity_Quote__c updateQuoteType(Opportunity_Quote__c oppQuote, Opportunity opportunity, Opportunity_Quote_Line_Item__c oppQuoteLineItem){
        Boolean isMatch = false;
        List<String> ruleTempList;
        Map<String, String> oppLineItemRuleMap;
        Map<String, String> bRuleNameTempMap = new Map<String, String>();
        Map<String,Business_Config__c> mapBusinessRules;
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('nintexQuoteFilters');

        if(mapBusinessLogic != null && !mapBusinessLogic.isEmpty()){
            mapBusinessRules = mapBusinessLogic.get(opportunity.RecordType.DeveloperName);
        }

        if(mapBusinessRules != null){
            for(String bRuleConfig : mapBusinessRules.keySet()){
                isMatch = true;
                bRuleNameTempMap = new Map<String, String>();
                for(String bRuleKey : mapBusinessRules.get(bRuleConfig).Business_Rule_Name__c.split(';')){
                    if(!bRuleKey.equals(Constants.BUSINESSCONIFG_RULENAME_CHECKCOMMISSIONTYPES)){ //SSC-1929
                        ruleTempList = bRuleKey.split(':');
                        bRuleNameTempMap.put(ruleTempList[0], ruleTempList[1]);
                    }
                }

                if(!bRuleNameTempMap.containsKey('Opportunity_Quote_Line_Item__c')){
                    continue;
                } else {
                    oppLineItemRuleMap = (Map<String, String>) JSON.deserialize(bRuleNameTempMap.get('Opportunity_Quote_Line_Item__c').replaceAll('=', ':'), Map<String, String>.class);
                }

                for(String bRuleKey : bRuleNameTempMap.keySet()){
                    if(bRuleKey == 'Opportunity_Quote_Line_Item__c'){
                        for(String innerBRuleKey : oppLineItemRuleMap.keySet()){
                            if(oppQuoteLineItem.get(innerBRuleKey) != oppLineItemRuleMap.get(innerBRuleKey)){
                                isMatch = false;
                                break;
                            }
                        }
                    } else if(isMatch && opportunity.get(bRuleKey) != bRuleNameTempMap.get(bRuleKey)){
                        isMatch = false;
                    }

                    if(!isMatch){
                        break;
                    }
                }

                if(isMatch){
                    oppQuote.Quote_Type__c = mapBusinessRules.get(bRuleConfig).Business_Rule_Value__c;
                    oppQuote.Template_Name__c = mapBusinessRules.get(bRuleConfig).Business_Rule_Value__c;
                    break;
                }
            }
        }

        return oppQuote;
    }
}