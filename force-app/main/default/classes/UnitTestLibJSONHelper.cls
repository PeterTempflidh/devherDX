@isTest
private class UnitTestLibJSONHelper {
    
    static final String templateCreatedJSONMessage = '{"id":"ae04335nfd332","url":"/service/test/ae04335nfd332/"}';
    static final String templateErrorMessage = '{"errors":[{"message":"message1","code":"code1"},{"message":"message2","code":"code2"}]}';
    static final String templateMessageForIdParsing = '{"id":"theID"}';
    static final String templateID = 'theID';
    static final String templateBillingAccount = '{"country":"billingCountry","billing_address":"billingAddressLine","owner":"ownerName","business_name":"accountName","business_id":123456}';
    static final String templateBackendAccount = '{"name":"restaurantName","phone_numbers":[{"number":"123456","is_phone":true}],"email_addresses":["email1@email.com","email2@email.com"],"relay_methods":["Fax","Box"],"is_test_restaurant":true}';
    static{
        UnitTestDataFactory.getRecordtypeValues();
        }

    @isTest static void test_createdJSONMessage() {
        String result = LibJSONHelper.createdJSONMessage('/service/test/', 'ae04335nfd332');

        System.assertEquals(templateCreatedJSONMessage,result);

    }
    
    @isTest static void test_errorMessage() {
        Map<String,String> theMap = new Map<String,String>{'message1'=>'code1','message2'=>'code2'};
        String result = LibJSONHelper.errorMessage(theMap);

        System.assertEquals(templateErrorMessage,result);
    }

    @isTest static void test_ParseForId(){
        String result = LibJSONHelper.parseForId(templateMessageForIdParsing);

        System.assertEquals(templateID,result);
    }

    @isTest static void test_createBillingAccount(){
        String result = LibJSONHelper.createBillingAccount('billingCountry','billingAddressLine','ownerName','accountName','123456');

        System.assertEquals(templateBillingAccount,result);
    }

    @isTest static void test_createBackendAccount(){
        List<String> listEmailAddresses = new List<String>{'email1@email.com','email2@email.com'};
        List<String> listRelayMethods = new List<String>{'Fax','Box'};
        List<String> listPaymentMethods = new List<String>{'online','cash'};

        String result = LibJSONHelper.createBackendAccount('restaurantName',listEmailAddresses,listRelayMethods,listPaymentMethods,true,'123456');
        
        System.assertEquals(templateBackendAccount,result);     
    }


    
}