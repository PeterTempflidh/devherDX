public with sharing class AutoCloseChatController {
    /*
    * returns the intervals for the AutoCloseChat component
    * Order:
    *
    * Popup active modal
    * Close modal
    * Wait until inactive tab is closed
    */

	private class TimeConfig {
		public Integer warning;
		public Integer warningClose;
		public Integer inactiveClose;
	}

	private static final String TIME_RULE_NAME  = 'AutoCloseChatTime';

    @AuraEnabled
    public static Integer[] getTimes(Id recordId) {
		// the defaults if no business rule found
		Integer warning = 5;
		Integer warningClose = 10;
		Integer inactiveClose = 90;


		LiveChatTranscript tr = [SELECT Country__c
									, Platform__c
								FROM LiveChatTranscript
								WHERE Id = :recordId];

		String platform = tr.Platform__c;
		String country = tr.Country__c;

		if (platform != null && country != null) {
			try {
				Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
				if (moam.containsKey(TIME_RULE_NAME)) {
					if (moam.get(TIME_RULE_NAME).containsKey(TIME_RULE_NAME)) {
						if (moam.get(TIME_RULE_NAME).get(TIME_RULE_NAME).containsKey(platform)) {
							Map<String, TimeConfig> countryMap = (Map<String, TimeConfig>) JSON.deserialize(moam.get(TIME_RULE_NAME).get(TIME_RULE_NAME).get(platform).Business_Rule_Value__c, Map<String, TimeConfig>.class); 
							if (countryMap.containsKey(country)) {
								warning = countryMap.get(country).warning;
								warningClose = countryMap.get(country).warningClose;
								inactiveClose = countryMap.get(country).inactiveClose;
							}
						}
					}   
				}
			} catch(Exception e) {}
		}

        Integer[] tm = new Integer[]{warning*1000 ,warningClose*1000 ,inactiveClose*1000 };
        return tm;
    }
}
