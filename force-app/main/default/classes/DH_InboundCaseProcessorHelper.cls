/**
    * Additional helper class for DH_InboundCaseProcessor.
    * CreatedBy: Preeti Bansal
*/
public class DH_InboundCaseProcessorHelper {

     /* @description - Validation for skipping case escalation if needed on certain criteria
     *
     * @param pCase - current Case record
     * @param escalationLogicMap - current matching escalation business rule
     * @return - boolean, is the criteria matching on the case record to skip current escalation or not
     */
   
    public static Boolean validateSkipEsc(Case pCase, Map<String, String> escalationLogicMap){
        Boolean isSkipEscValid = false;
        Id recId = pCase.Id ;
        Set<String> setFields = new Set<String>();        
        DescribeSObjectResult objSchema = recId.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
		Set<String> fieldsToCheck = new Set<String>(escalationLogicMap.get('Exclude Rule Criteria').split(';'));
       Map<String,String> fieldAndItsType = new Map<String,String>();
        for (String fieldName : fieldMap.keySet())
        {   
            if(fieldsToCheck.contains(fieldName)){
                SObjectField sfield = fieldMap.get(fieldName);
                schema.describefieldresult dfield = sfield.getDescribe();
                Schema.DisplayType fielddataType = dfield.getType();
                string strFieldDataType = string.valueOf(fielddataType);
                fieldAndItsType.put(dfield.getName(),strFieldDataType);                 
            }
        }
        if(fieldAndItsType.isEmpty()){return false;}
        for(String fld: fieldAndItsType.keyset()){
           Boolean isValid = validateFieldCheck(pCase,fieldAndItsType.get(fld),fld, escalationLogicMap.get(fld) );
            if(isValid){
                continue;
            }return false;
        }
        return true;
    }

    /* @description - Validation for skipping case escalation on the field based on which escalation has to be skipped
     *
     * @param pCase - current Case record
     * @param fieldType - datatype of field - based on which validations can be set.
     *        For e.g. for boolean check true or false, if string check matchig string etc.
     * @param - fieldName - api name of the field to be validated, also defined in business config
     * @param - fieldName - value of the field to be validated against, also defined in business config
     * @return - boolean, trigger the validation on the field
     */
    public static Boolean validateFieldCheck(Case pCase, String fieldType, String fieldName, String fieldValue){
        if(String.isEmpty(fieldType)){return false;}
          switch on fieldType {
            when 'BOOLEAN' {
               return validateBooleanField(pCase,fieldName, fieldValue);
            }
			when 'PICKLIST' {
                return validateStringField(pCase,fieldName, fieldValue);
            }
            //More when's can be added
            when else {
               return false;
            }
         }
    }
    /* @description - Field value validation only for field type of boolean
     *
     * @param pCase - current Case record
     * @param - fieldName - value of the field to be validated against, also defined in business config
     * @return - boolean, is the value true or false on current case or not
     */

    public static Boolean validateBooleanField(Case pCase,String fieldName, String fieldValue){
        Boolean boolValue = (Boolean)pCase.get(fieldName);
        Boolean boolFieldValue = Boolean.valueOf(fieldValue);
        if(boolFieldValue && boolValue){return true;}
        return false;       
    }
	
	 /* @description - Field value validation only for field type of String,Picklist
     *
     * @param pCase - current Case record
     * @param - fieldName - value of the field to be validated against, also defined in business config
     * @return - boolean, is the value true or false on current case or not
     */

    public static Boolean validateStringField(Case pCase,String fieldName, String fieldValue){
        String stringValue = (String)pCase.get(fieldName);
        String stringFieldValue = fieldValue;
        return runOperatorCheck(stringFieldValue.subStringBefore('::'),stringFieldValue.substringAfter('::'),stringValue);
               
    }
	/* @description - Field value validation provided in business config based on operator type
     *
     * @param operatorType - NOTIN, IN, NOTEQUALS etc
     * @param - fieldValue - value of the field  in business config
	 * @param - fieldValue - value of the field  on case
     * @return - boolean, is the value true or false on current case or not
     */
    public static Boolean runOperatorCheck(String operatorType, String fieldValue, String caseFieldValue ){
        if(String.isEmpty(operatorType)){   return false;}
        Set<String> valueSet = new Set<String>();
        if(fieldValue.contains(',')){
            valueSet = new Set<String>(fieldValue.split(','));
        }
        else{ 
            valueSet.add(fieldValue) ;
        }
       switch on operatorType {
            when 'NOTIN' {
               if(!valueSet.contains(caseFieldValue)){ return true;}
                return false;
            }
            //More when's can be added
            when else {
               return false;
            }
         }
    }
}
