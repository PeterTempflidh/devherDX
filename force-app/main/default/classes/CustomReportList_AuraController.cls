/**
* @author Mantas Jurkunas
* @date 19.08.2019
*
* @description Controller for CustomReportList component
*/
public with sharing class CustomReportList_AuraController {

    @AuraEnabled
    public static List<ReportDescription> getReportDefinitionList() {
        List<ReportDescription> reportDescriptionList = new List<ReportDescription>();
        Map<String, Map<String, Business_Config__c>> mapBusinessProcess= LibBusinessConfig.motherOfAllBusinessMaps.get('CustomReports');
        if (mapBusinessProcess == null || mapBusinessProcess.isEmpty()) {
            return reportDescriptionList;
        }
        User currentUser = [SELECT Company_Name__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<String> userCompanies = currentUser.Company_Name__c.split(';');
        if (userCompanies == null || userCompanies.isEmpty()) {
            return reportDescriptionList;
        }
        for (String userCompany: userCompanies) {
            if (!mapBusinessProcess.containsKey(userCompany.trim())) {
                continue;
            }
            Map<String, Business_Config__c> reportDescriptionMap = mapBusinessProcess.get(userCompany.trim());
            for (String reportName: reportDescriptionMap.keySet()) {
                reportDescriptionList.add(new ReportDescription(reportName, reportDescriptionMap.get(reportName).Business_Rule_Value__c));
            }
        }
        return reportDescriptionList;
    }

    @TestVisible
     private class ReportDescription {
         @AuraEnabled public String definitionJson;
         @AuraEnabled public String reportName;
         @AuraEnabled public Boolean isVisible;

         public ReportDescription(String reportName, String definitionJson) {
             this.reportName = reportName;
             this.definitionJson = definitionJson;
             this.isVisible = false;
         }
     }
}