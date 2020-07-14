@isTest
public class UnitTestCtrYoGiYo_EC_Quote
{
    @isTest
    static void CtrYoGiYo_EC_QuoteBuildCorrectlyWhenDocumentsDoNotExist()
    {
        PageReference pref = Page.YoGiYo_EC_Quote;
        CtrYoGiYo_EC_Quote ctrl;

        Test.startTest();

        Test.setCurrentPage(pref);
        ctrl = new CtrYoGiYo_EC_Quote();

        Test.stopTest();

        System.assert(String.isBlank(ctrl.headerImgUrl));
        System.assert(String.isBlank(ctrl.footerImgUrl));
    }

    @isTest
    static void CtrYoGiYo_EC_QuoteBuildCorrectlyWhenDocumentsExist() 
    {
        PageReference pref = Page.YoGiYo_EC_Quote;
        CtrYoGiYo_EC_Quote ctrl;

        Document[] docs = new List<Document>();

        // header doc
        docs.add(new Document(
            Body = Blob.valueOf('test'),
            DeveloperName = 'YoGiYoEmailTemplateHeader',
            Name = 'YoGiYoEmailTemplateHeader',
            IsPublic = true,
            FolderId = UserInfo.getUserId()
        ));

        // footer
        docs.add(new Document(
            Body = Blob.valueOf('test'),
            DeveloperName = 'YoGiYoEmailTemplateFooter',
            Name = 'YoGiYoEmailTemplateFooter',
            IsPublic = true,
            FolderId = UserInfo.getUserId()
        ));
        
        insert docs;

        Test.startTest();

        Test.setCurrentPage(pref);
        ctrl = new CtrYoGiYo_EC_Quote();

        Test.stopTest();

        System.assert(!String.isBlank(ctrl.headerImgUrl));
        System.assert(!String.isBlank(ctrl.footerImgUrl));
    }
}