public with sharing abstract class CtrAbstractQuote {
	public CtrAbstractQuote() {}

	/**
	* Given a document's developer name returns the public URL for the document
	* @param imgDevName Document developer name
	* @return document's public url or an empty string
	*/
	protected String getImageUrl(String imgDevName) {
		Document[] headers = [Select Id from Document Where DeveloperName = : imgDevName];
		return headers.isEmpty() ?
		       ''
		       : Url.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + headers[0].Id + '&oid=' + UserInfo.getOrganizationId();
	}
}