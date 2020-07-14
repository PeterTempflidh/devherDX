global class getBillingAddress implements Loop.IApexDataSource{
    
    private string addressObjectName = 'AddressDetail__c';
    
    public Set<string> getGlobalDescribe() {
        return new Set<string>{
            addressObjectName
                };
                    }
    public Set<string> getChildRelationships(string objectName) {
        return new Set<string>();
    }
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objectNames) {
        // Describe each object in objectNames.
        // In this example, we will use all fields for each Salesforce object being used.
        
        // Declare the variable to be returned.
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>();
        
        // Loop through each object in objectNames and add to the result
        for (string objectName : objectNames) {
            // Declare variable to store field data for the object
            List<Loop.ExternalData.FieldInfo> fields = new List<Loop.ExternalData.FieldInfo>();
            
            if (objectName == addressObjectName) {
                // Describe the fields for this object.
                
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.AddressDetail__c.Fields.getMap();
                
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get('AddressLine__c').getDescribe();
                
                // Store the field info for this field
                Loop.ExternalData.FieldInfo fieldInfo = new Loop.ExternalData.FieldInfo('AddressLine__c', fieldDescribe.getType());
                fieldInfo.label = fieldDescribe.getLabel();
                fieldInfo.scale = fieldDescribe.getScale();
                
                if (!fieldDescribe.getReferenceTo().isEmpty()) {
                    // referenceTo is needed to define a relationship between parent and child objects
                    fieldInfo.referenceTo = string.valueOf(fieldDescribe.getReferenceTo()[0]);
                }
                
                fields.add(fieldInfo);
                
            }
            
            // Declare variable to add to results list using fields described above
            Loop.ExternalData.DataObject describeObjectResult = new Loop.ExternalData.DataObject(objectName, fields);
            
            // Add to results list
            describeObjectResults.add(describeObjectResult);
        }
        return describeObjectResults;
    }
    
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        Id opportunityQuoteId = requestInfo.RecordId;
        Id accountId = [SELECT Id_Account__c FROM Opportunity_Quote__c WHERE Id =: opportunityQuoteId ].Id_Account__c;
        
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        for (string objectName : requestInfo.GetObjectNames()) {
            // Declare fields list for QueryResult instance
            List<string> fields = new List<string>();
            
            // Declare query result to add to QueryResultSet instance
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fields);
            if (objectName == addressObjectName) {         
                fields.add('AddressLine__c');                
                
                // Since we added fields to the list, update the QueryResult instance
                queryResult = new Loop.ExternalData.QueryResult(objectName, fields);
                
                List<AddressDetail__c> addList = AddressDetail_Selector.getByAccountId(accountId);
                
                String formattedAddValue;
                
                //Finding billing address
                for(AddressDetail__c add : addList){
                    if(add.Type__c.contains('Billing Address')){
                        formattedAddValue = add.AddressLine__c;
                        break;
                    }  
                }
                
                //If no billing address found, then assign restaurant address
                if(String.isEmpty(formattedAddValue)){
                    for(AddressDetail__c add : addList){
                        if(add.Type__c.contains('Restaurant Address')){
                            formattedAddValue = add.AddressLine__c;
                            break;
                        }
                    }
                }
                                
                List<string> recordValues = new List<string>();
                recordValues.add(formattedAddValue);                    
                queryResult.rows.add(recordValues);
            }
            queryResultSet.add(queryResult);
        }
        return queryResultSet;
    }  
    
}
