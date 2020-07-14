public with sharing class ClsWebserviceCalloutsKR {

    public static String createBackendAccount(String restaurantName, String salesforceId, String salesRep) {
        Http theHttp = new Http();
        HttpRequest theRequest = new HttpRequest();
        HttpResponse theResponse = new HttpResponse();

        Integration_Config__c backendConfig = IntegrationConfig_Util.getIntegrationConfig('KR_YogiyoBackend');
        String endpoint = backendConfig.Endpoint__c + 'create/?api_key=' + backendConfig.ClientId__c + '&secret=' + backendConfig.ClientSecret__c;

        String postParameters = 'salesforce_id=' + EncodingUtil.urlEncode(salesforceId, 'UTF-8');
        postParameters = postParameters + '&salesforce_user=' + EncodingUtil.urlEncode(salesRep, 'UTF-8');
        postParameters = postParameters + '&name=' + EncodingUtil.urlEncode(restaurantName, 'UTF-8');

        theRequest.setEndpoint(endpoint);
        theRequest.setMethod('POST');
        theRequest.setBody(postParameters);

        try {

            theResponse = theHttp.send(theRequest);

            if (theResponse.getStatusCode() == 200) {

                String backendId = LibJSONHelper.parseResponseForKRBackendId(theResponse.getBody());
                return backendId;
            } else {
                return null;
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + '   ' + e.getStackTraceString());
            return null;
        }
    }

    public static FixedCommissionWrapper getFixAmountCommissionDistricts(String backendId) {
        Http theHttp = new Http();
        HttpRequest theRequest = new HttpRequest();
        HttpResponse theResponse;
        FixedCommissionWrapper theWrapper;

        Integration_Config__c backendConfig = IntegrationConfig_Util.getIntegrationConfig('KR_YogiyoBackend');
        String endpoint = backendConfig.Endpoint__c + backendId + '/zero_commission/?api_key=' + backendConfig.ClientId__c + '&secret=' + backendConfig.ClientSecret__c;

        theRequest.setMethod('GET');
        theRequest.setEndpoint(endpoint);

        try {
            theResponse = theHttp.send(theRequest);
            String json = theResponse.getBody().replaceAll('targetdistrict__id', 'targetdistrict_id').replaceAll('district__name', 'district_name').replaceAll('district__id', 'district_id');
            Integer statusCode = theResponse.getStatusCode();

            if (statusCode == 200) {
                theWrapper = (FixedCommissionWrapper) System.JSON.deserialize(json, FixedCommissionWrapper.class);
                theWrapper.errorFlag = false;
                theWrapper.errorMessage = '';
            } else if (statusCode == 404) {
                theWrapper.errorFlag = true;
                theWrapper.errorMessage = 'No results found';
            } else {
                theWrapper.errorFlag = true;
                theWrapper.errorMessage = 'There was an error. Please contact your administrator.';
            }

        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
        }

        return theWrapper;
    }

    //Is this used somewhere??
    public static DistrictPriceCategoryWrapper getAvailableDistrictsAndCategories(String backendId) {
        Http theHTTP = new Http();
        HttpRequest theRequest = new HttpRequest();
        DistrictPriceCategoryWrapper theDistrictPriceWrapper;
        String districtsAndCategoriesJSON;

        Integration_Config__c backendConfig = IntegrationConfig_Util.getIntegrationConfig('KR_YogiyoBackend');
        String endpoint = backendConfig.Endpoint__c + backendId + '/available_districts_and_categories/?api_key=' + backendConfig.ClientId__c + '&secret=' + backendConfig.ClientSecret__c;

        theRequest.setMethod('GET');
        theRequest.setEndpoint(endpoint);

        try {
            HttpResponse theResponse = theHTTP.send(theRequest);

            if (theResponse.getStatusCode() == 200 && theResponse.getBody() != null && theResponse.getBody() != '') {
                districtsAndCategoriesJSON = theResponse.getBody().replaceAll('district__id', 'district_id').replaceAll('district__name', 'district_name').replaceAll('super', 'typeSuper').replaceAll('basic', 'typeBasic');
                theDistrictPriceWrapper = (DistrictPriceCategoryWrapper) System.JSON.deserialize(districtsAndCategoriesJSON, DistrictPriceCategoryWrapper.class);
                theDistrictPriceWrapper.errorFlag = false;

            } else if (theResponse.getStatusCode() == 200 && (theResponse.getBody() == null || theResponse.getBody() == '')) {
                theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
                theDistrictPriceWrapper.errorFlag = true;
                theDistrictPriceWrapper.errorMessage = Label.AdSalesKRIncomplete;

            } else if (theResponse.getStatusCode() == 404) {
                theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
                theDistrictPriceWrapper.errorFlag = true;
                theDistrictPriceWrapper.errorMessage = Label.AdSalesKR404;
            }

        } catch (Exception e) {
            theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
            theDistrictPriceWrapper.errorFlag = true;
            theDistrictPriceWrapper.errorMessage = Label.AdSalesKRException;
        }

        return theDistrictPriceWrapper;

    }
}