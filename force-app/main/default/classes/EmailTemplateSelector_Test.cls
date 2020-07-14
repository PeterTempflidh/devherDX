/**
 * Created by t.jain on 2019-04-09.
 */

@IsTest
private class EmailTemplateSelector_Test {
    @testSetup
    public static void setupData(){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test Template';
        validEmailTemplate.DeveloperName = 'test_template_testing';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Subject = 'Test Template';
        insert validEmailTemplate;
    }

    @IsTest
    static void testCaseSelectorStaticQuery() {
        EmailTemplate e1 = [SELECT Id, Name, DeveloperName FROM EmailTemplate Limit 1];
        EmailTemplate eId = EmailTemplateSelector.getTemplateByName(e1.name);
        system.assertEquals(e1.Id, eId.Id);
        
        List<EmailTemplate> eId2 = EmailTemplateSelector.getTemplatesByDeveloperName(new List<String>{e1.DeveloperName});
        system.assertEquals(e1.Id, eId2.get(0).Id);

        EmailTemplate eId3 = EmailTemplateSelector.getTemplateByDeveloperName(e1.DeveloperName);
        system.assertEquals(e1.id, eId3.id);
        
        List<EmailTemplate> eId4 = EmailTemplateSelector.getListTemplateByDeveloperName(e1.DeveloperName);
        system.assertEquals(e1.id, eId4[0].id);
    }
}