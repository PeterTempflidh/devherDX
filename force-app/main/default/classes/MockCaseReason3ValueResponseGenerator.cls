/**
 * Created by t.jain on 2019-04-30.
 */

public with sharing class MockCaseReason3ValueResponseGenerator implements HttpCalloutMock {
    Boolean validResponse;
    String field;
    public MockCaseReason3ValueResponseGenerator(Boolean flag,String fieldVal){
        validResponse=flag;
        field=fieldVal;
    }
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(validResponse && field=='Case Reason Level 3') {
            res.setBody('{"controllerValues" : {"Frontend issue" : 0,"Menu update - Major": 42,"Menu Update Major with Images": 43}, "values" : [{"attributes" : null, "label" : "Website issue", "validFor" : [ 0 ], "value" : "Website issue"},{"attributes" : null, "label" : "Add items/ toppings", "validFor" : [ 42,43 ], "value" : "Add items/ toppings"}]}');
            res.setStatusCode(200);
        }
        else if(validResponse && field=='Type'){
            res.setBody('{"controllerValues":{},"defaultValue":null,"eTag":"599b33f7e5f2ad5172221272d83a9406","url":"/services/data/v44.0/ui-api/object-info/Case/picklist-values/0121r0000007eRzAAI/Type","values":[{"attributes":null,"label":"Customer","validFor":[],"value":"Customer"}]}');
            res.setStatusCode(200);
        }
        else if(validResponse){
            res.setBody('');
            res.setStatusCode(200);
        }
        else if(!validResponse){
            res.setBody('');
            res.setStatusCode(400);
        }
        return res;
    }
}