/**
* @author Sudhakar Ch
* @date 09/01/2020
* @description Class to get Account data for a Nintex docugen package "Quotes", Uasing this class with parentAccount alias name.
* This class is build as for recomendations of Nintex documentation can be find here : https://help.nintex.com/en-us/docgen/docservices/#docgen-sfdc/Services/manageDDP/RelationshipApexData.htm%3FTocPath%3DUse%2520advanced%2520techniques%7CRelationships%7C_____5
*/

global class GetAccountDataForNintex implements Loop.IApexDataSource{
    //* @description specifies object fow which we need to get data
    private string accountObjectName = 'Account';
    //* @description specifies fields of the object name which specified in 'accountObjectName' variable fow which we need to get data
	public List<String> fieldApiNames = new List<String>();
    
    //Getting required fields from fieldset 
    global GetAccountDataForNintex() {
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.NintexAPACQuotesFieldset.getFields()) {
    		fieldApiNames.add(f.getFieldPath());
		}
    }
     /*******************************************************************************************************
    * @description Returns global describe for the object
    * @return Returns global describe for the object
    */
    public Set<string> getGlobalDescribe() {
        return new Set<string>{accountObjectName};
    }
	 /*******************************************************************************************************
    * @description Used to get child records if there are any
    * @return Returns child relationships for the object
	* @param Name of the object
    */
    public Set<string> getChildRelationships(string objectName) {
        return new Set<string>();
    }

	 /*******************************************************************************************************
    * @description Describe sobject and it's fields to use in query method
    * @return Returns List<Loop.ExternalData.DataObject>
	* @param list of object Names
    */
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objectNames) {
        
        // Declare the variable to be returned.
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>();
        
        // Loop through each object in objectNames and add to the result
        for (string objectName : objectNames) {
            // Declare variable to store field data for the object
            List<Loop.ExternalData.FieldInfo> fields = new List<Loop.ExternalData.FieldInfo>();
            
            if (objectName == accountObjectName) {
                // Describe the fields for this object.
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.Fields.getMap();
                
                for (string fieldKey : fieldApiNames) {
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldKey).getDescribe();
                    
                    // Store the field info for this field
                    Loop.ExternalData.FieldInfo fieldInfo = new Loop.ExternalData.FieldInfo(fieldKey, fieldDescribe.getType());
                    fieldInfo.label = fieldDescribe.getLabel();
                    fieldInfo.scale = fieldDescribe.getScale();
                    
                    if (!fieldDescribe.getReferenceTo().isEmpty()) {
                        // referenceTo is needed to define a relationship between parent and child objects
                        fieldInfo.referenceTo = string.valueOf(fieldDescribe.getReferenceTo()[0]);
                    }
                    
                    fields.add(fieldInfo);
                }
                
            }
            
            // Declare variable to add to results list using fields described above
            Loop.ExternalData.DataObject describeObjectResult = new Loop.ExternalData.DataObject(objectName, fields);
            
            // Add to results list
            describeObjectResults.add(describeObjectResult);
        }
        return describeObjectResults;
    }
    
	 /*******************************************************************************************************
    * @description To query the data from a specified objecct
    * @return Returns Loop.ExternalData.QueryResultSet
	* @param Loop.ExternalData.QueryRequestInfo
    */
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {

        Id opportunityQuoteId = requestInfo.RecordId;
		Id accountId = OpportunityQuoteSelector.getQuotesMap(new Set<Id>{opportunityQuoteId}).get(opportunityQuoteId).Id_Account__c;	
        // Provide data for each object in requestInfo.GetObjectNames()
                
        // Declare the variable to be returned.
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        
        // Loop through all objects requested. The QueryResultSet instance returned needs to contain a QueryResult instance for each object requested.
        for (string objectName : requestInfo.GetObjectNames()) {
            
            // Declare query result to add to QueryResultSet instance
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fieldApiNames);
            
            // set up fields list and query to get data for QueryResult instance
            if (objectName == accountObjectName) {
                
                // Since we added fields to the list, update the QueryResult instance
                queryResult = new Loop.ExternalData.QueryResult(objectName, fieldApiNames);
                
                string query = string.format('SELECT {0} FROM Account WHERE Id = :accountId',new List<string>{ string.join(fieldApiNames, ',') });
                
                // for each row of data returned by the query
                for (SObject record : Database.query(query)) {
                    // Store the values (as strings) from the record in the same order of the fields defined in the QueryResult instance
                    List<string> recordValues = new List<string>();
                    for (string field : fieldApiNames) {
                        recordValues.add(getFieldValue(record, field));
                    }
                    // Add the values to the QueryResult instance rows
                    queryResult.rows.add(recordValues);
                }
            }
            
            // Add the QueryResult instance to the QueryResultSet instance
            // This needs to be done for every object specified in requestInfo.GetObjectNames(), regardless of whether data is required for the request.
            queryResultSet.add(queryResult);
        }
        
        return queryResultSet;
    } 

	 /*******************************************************************************************************
    * @description This method properly retrieves a field value from an SObject for fields used through lookup relationships, 
    * e.g. PricebookEntry.Product2.ProductCode on the OpportunityLineItem object.
    * @return Returns string which contains field value
	* @param sObject and field name
    */
    private string getFieldValue(sObject obj, string field) {
        if (obj == null) return '';
        string[] fieldParts = field.split('\\.');
        if (fieldParts.size() == 3) {
            sObject sobj = obj.getSObject(fieldParts[0]);
            if (sobj == null) return '';
            sobj = sobj.getSObject(fieldParts[1]);
            if (sobj == null) return '';
            return string.valueOf(sobj.get(fieldParts[2]));
        }
        else if (fieldParts.size() == 2) {
            sObject sobj = obj.getSObject(fieldParts[0]);
            if (sobj == null) return '';
            return string.valueOf(sobj.get(fieldParts[1]));
        }
        return string.valueOf(obj.get(field));
    } 
}