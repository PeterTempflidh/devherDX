/**
* @author Krunoslav Bilicic
* @date 28.1.2019.
* 
* @group General
*
* @description Helper class that decodes dependencies between field values. For example depending picklist values.
*/
public class DependingPicklistHelper {
    
    /**
    * @description Returns list of picklist values for a giver picklist field
    * @param objectField sObjectField picklist
    * @return the list of picklist values as a list of strings
    * @example
    * List<String> picklistValues = DependingPicklistHelper.getPicklistValues(Case.Case_Reason_Level_1__c);
    */
    public static List<String> getPicklistValues(Schema.sObjectField objectField) {
        List<String> vals = new List<String>();
        Schema.DescribeFieldResult depend = objectField.getDescribe();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) {
            vals.add(entry.getLabel());
        }
        
        return vals;
    }
    
    /**
    * @description Returns a map of depending picklist values between two dependant picklists
    * @param dependToken Schema.sObjectField picklist that represents dependant field
    * @param controlToken Schema.sObjectField picklist that represents controlling field
    * @return a map of depending picklist values between two dependant picklists
    * @example
    * Map<String,String> map1 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_1__c, Case.Type);
    */
    public static Map<String,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken,  Schema.sObjectField controlToken )
    {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        List<String> allParents=new List<String>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getValue() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null || base64chars.size() <= bitIndex || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0) 
                    continue;
                if ( !dependentPicklistValues.containsKey( entry.getValue() ) )
                {
                    allParents=new List<String>();
                    allParents.add((String)controlValue);
                    dependentPicklistValues.put(entry.getValue(), allParents );
                }
                else{
                    allParents=dependentPicklistValues.get(entry.getValue());
                    allParents.add((String)controlValue);
                    dependentPicklistValues.put(entry.getValue(), allParents );
                }
            }
        }
        return dependentPicklistValues;
    }
}