/**
* @author Mantas Jurkunas
* @date 09.01.2019
*
* @description Utility class for integration configuration custom setting
*/
public with sharing class IntegrationConfig_Util {
    private static final Boolean isSandbox {
      get {
          return isSandbox == null ? [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox : isSandbox;
      }
    }

    public static Integration_Config__c getIntegrationConfig(String name) {
        return Integration_Config__c.getInstance(isSandbox ? name + Label.Staging_Suffix : name);
    }
}