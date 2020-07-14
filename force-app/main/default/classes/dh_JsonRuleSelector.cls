/**
Created by Sudhakar 31/4/2020
 */

public inherited sharing class dh_JsonRuleSelector implements dh_IRuleSelector {

    public Map<String, Object> getSetOfRules( Map<String, Object> input ) {

        Map<String, Object> output = new Map<String, Object>();

        if( !input.containsKey('jsonConfiguration') ){
            throw new dh_JsonRuleSelectorException('The JSON configuration has not been found');
        }

        String serializedJsonConfiguration = (String) input.get('jsonConfiguration');
        dh_RuleConfiguration ruleConfiguration = dh_RuleConfiguration.deserialize(serializedJsonConfiguration);
        output.put('ruleConfiguration', ruleConfiguration);

        return output;
    }

    public class dh_JsonRuleSelectorException extends Exception {}
}