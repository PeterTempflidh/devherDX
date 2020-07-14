/**
 @Description: This is the service for update the debt status
*/
@RestResource(urlMapping='/DebtStatusRestService/*')
global with sharing class DebtStatusRestService {

    /**
    * @author William Castillo.
    * @date 30-Apr-20
    * @description This method update the platform performances witht the information of the debt by the contract number
    * SCC-14
    * @return ResponseWrapper
    */
    @HttpPost
    global static DebtStatusRestHelper.ResponseWrapper doPost(){
        RestRequest request = RestContext.request;
        String jSONRequestBody=request.requestBody.toString().trim();
        DebtStatusRestHelper.RequestWrapper wrpDebtStatus = DebtStatusRestHelper.parseRequest(jSONRequestBody);
        return DebtStatusRestHelper.processRequest(wrpDebtStatus);
    }
}