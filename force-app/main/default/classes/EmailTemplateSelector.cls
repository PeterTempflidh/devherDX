/**
 * Created by t.jain on 2019-04-09.
 */

public inherited sharing class EmailTemplateSelector {

    public static EmailTemplate getTemplateByName(String name) {
        List<EmailTemplate> lstEmailTemplate = [SELECT Id FROM EmailTemplate WHERE Name =: name];
        if(lstEmailTemplate.isEmpty())
            return null;
        return lstEmailTemplate[0];
    }

    public static List<EmailTemplate> getTemplatesByDeveloperName(List<String> devNames) {
        return [SELECT Id, HtmlValue,subject, DeveloperName
        FROM EmailTemplate
        WHERE DeveloperName IN: devNames];
    }

    public static EmailTemplate getTemplateByDeveloperName(String devName) {
        return [SELECT Id,HtmlValue,subject, DeveloperName
        FROM EmailTemplate
        WHERE DeveloperName =: devName limit 1];
    }

    public static List<EmailTemplate> getListTemplateByDeveloperName(String devName) {
        return [SELECT Id,HtmlValue,subject,Body
        FROM EmailTemplate
        WHERE DeveloperName =: devName];
    }
}
