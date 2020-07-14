/**
	Controller per YoGiYo_EC_Quote page
    Dynamically retrieves the url for the documents that are going
    to be inserted into the email template
*/
public class CtrYoGiYo_EC_Quote
{

    public String headerImgUrl {
        get {
            return getImageUrl('YoGiYoEmailTemplateHeader');
        }
        private set;
    }

    public String footerImgUrl {
        get {
            return getImageUrl('YoGiYoEmailTemplateFooter');
        }
        private set;
    }

    /**
    Given a document's developer name returns the public URL for the document
    @param imgDevName Document developer name
    @return document's public url or an empty string
    */
    private String getImageUrl(String imgDevName) {
        Document[] headers = [Select Id from Document Where DeveloperName =: imgDevName];
        return headers.isEmpty() ? 
            ''
            : Url.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + headers[0].Id + '&oid=' + UserInfo.getOrganizationId();
    }
}