/* Created By: Preeti Bansal
 * Description: API related variables or configurations
 * Created Date: 03-Jan-2020
 */
@isTest
public class API_SalesforceInternalCalloutMockClass  implements HttpCalloutMock{
    public static String respString ;
    public static Integer respStatusCode ;
    
    public static HttpResponse respond(HTTPRequest request) {
        system.debug(respStatusCode+'@@respStatusCode');
        HttpResponse response = new HttpResponse();
        response.setBody(respString);
        response.setStatusCode(200);       
        return response;
    }           
}
