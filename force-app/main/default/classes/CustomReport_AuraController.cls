/**
* @author Mantas Jurkunas
* @date 28.07.2019
*
* @description Controller for Custom Reports component
*/
public inherited sharing class CustomReport_AuraController {
    /**
     * @description  default parent key for top level records
     */
    private static final String PARENT_KEY = UserInfo.getUserId();
    @AuraEnabled public ReportData reportData {get; set;}

    @AuraEnabled
    public static ReportData loadReportData(final String reportDefinition) {
        ReportRelationDefinition relationDefinition = (ReportRelationDefinition) JSON.deserialize(reportDefinition, ReportRelationDefinition.class);
        relationDefinition.queryCondition = relationDefinition.queryCondition == null ? ' LIMIT 2000' : relationDefinition.queryCondition + ' LIMIT 2000';
        ReportData reportData = new ReportDataBuilder(relationDefinition).getReportDefinitionFields().queryAllData().build();
        return reportData;
    }

    /**
     * @description Gets a chunk of report data filtered by ID of the latest one retrieved.
     *
     * @param reportDefinition definition of the report.
     * @param recordId Id of the previous latest record.
     *
     * @return ReportData
     */
    @AuraEnabled
    public static ReportData loadReportDataById(final String reportDefinition, final Id recordId) {
        ReportRelationDefinition relationDefinition = (ReportRelationDefinition) JSON.deserialize(reportDefinition, ReportRelationDefinition.class);
        String condition  = (recordId == null ? '' :
                ( relationDefinition.queryCondition == null ? ' WHERE ' : ' AND ') +
                        'Id > \'' + recordId + '\' ') +
                            'ORDER BY Id LIMIT 5000';

        relationDefinition.queryCondition = relationDefinition.queryCondition == null ? condition : relationDefinition.queryCondition + condition;
        ReportData reportData = new ReportDataBuilder(relationDefinition).getReportDefinitionFields().queryAllData().build();
        return reportData;
    }

    /**
     *  @description Builder class to initialise report data
     */
    private class ReportDataBuilder {
        private final ReportRelationDefinition reportRelationDefinition;
        public ReportDataBuilder(ReportRelationDefinition reportRelationDefinition) {
            this.reportRelationDefinition = reportRelationDefinition;
        }

        public ReportDataBuilder getReportDefinitionFields() {
            return getReportDefinitionFields(new List<ReportRelationDefinition>{this.reportRelationDefinition});
        }

        public ReportDataBuilder queryAllData() {
            return queryAllData(this.reportRelationDefinition, null);
        }

        public ReportData build() {
            return new ReportData(reportRelationDefinition);
        }

        /**
         * @description Get report fields from the specified fieldSet
         *
         * @param reportRelationDefinitions
         *
         * @return ReportDataBuilder
         */
        private ReportDataBuilder getReportDefinitionFields(List<ReportRelationDefinition> reportRelationDefinitions) {
            List<ReportRelationDefinition> nextReportRelationDefinitions = new List<ReportRelationDefinition>();
            for (ReportRelationDefinition definition: reportRelationDefinitions) {
                definition.fieldSetMembers = ClsSObjectUtils.readFieldSet(definition.fieldSetName, definition.objectName);
                if (definition.children != null) {
                    nextReportRelationDefinitions.addAll(definition.children);
                }
            }
            if (nextReportRelationDefinitions.isEmpty()) {
                return this;
            }
            return getReportDefinitionFields(nextReportRelationDefinitions);
        }

        /**
         * @description Query all the data for report
         *
         * @param reportDefinition
         * @param parentIds
         *
         * @return ReportDataBuilder
         */
        private ReportDataBuilder queryAllData(ReportRelationDefinition reportDefinition, Set<Id> parentIds) {
            List<SObject> objectList = Database.query(buildQueryString(reportDefinition));
            if (String.isBlank(reportDefinition.parentLookupField) && !objectList.isEmpty()) {
                reportDefinition.latestRecordId = objectList.get(objectList.size()-1).Id;
            }
            reportDefinition.dataMap = String.isNotBlank(reportDefinition.parentLookupField) ?
                    ClsSObjectUtils.convertToIdMap(objectList, reportDefinition.parentLookupField) :
                    new Map<Id, List<SObject>>{PARENT_KEY => objectList};
            if (reportDefinition.children == null || reportDefinition.children.isEmpty()) {
                return this;
            }
            for (ReportRelationDefinition definition: reportDefinition.children) {
                /** Recursive query, but limited to the object *
                  *  structure report has, usually not more than 5 **/
                queryAllData(definition, new Map<Id, SObject>(objectList).keySet());
            }
            return this;
        }

        /**
         * @description Build query from fieldSet Members
         *
         * @param reportDefinition
         *
         * @return String query built
         */
        private String buildQueryString(ReportRelationDefinition reportDefinition) {
            final String baseQuery  = 'SELECT {0} FROM {1}';
            String condition = (String.isNotBlank(reportDefinition.parentLookupField) ? (' WHERE ' + reportDefinition.parentLookupField + ' IN :parentIds') : '');
            String conditionJoin = String.isNotBlank(condition) ? ' AND ' :
                    (reportDefinition.queryCondition.trim().startsWith('LIMIT') || reportDefinition.queryCondition.trim().startsWith('ORDER') ? '' : ' WHERE ');
            condition = String.isNotBlank(reportDefinition.queryCondition) ? (condition + conditionJoin + reportDefinition.queryCondition) : condition;
            String fieldList = String.isNotBlank(reportDefinition.parentLookupField) ? (reportDefinition.parentLookupField + ',') : '';
            for (FieldSetMember member: reportDefinition.fieldSetMembers) {
                if (member.getFieldPath().equals(reportDefinition.parentLookupField)) {
                    continue;
                }
                fieldList+=member.getFieldPath() + ',';
            }
            if (String.isBlank(reportDefinition.parentLookupField) && !fieldList.containsIgnoreCase('Id')) { fieldList+='Id,'; }
            return String.format(baseQuery, new List<String>{fieldList.removeEnd(','), reportDefinition.objectName + condition});
        }

    }

    /**
     * @description  Class that handles initial report definition in the business config and further processing
     * @example  {"queryCondition":null,"parentLookupField":null,"objectName":"Account","fieldSetName":"OptTriggerQuery","fieldSetMembers":null,"dataMap":null,"children":[{"queryCondition":null,"parentLookupField":"AccountId","objectName":"Opportunity","fieldSetName":"Test_FieldSet","fieldSetMembers":null,"dataMap":null,"children":[{"queryCondition":null,"parentLookupField":"Id_Opportunity__c", "stackValues": true,"objectName":"Opportunity_Line_Item__c","fieldSetName":"Test_FieldSet","fieldSetMembers":null,"dataMap":null,"children":null}]}]}
     */
    @TestVisible
    private class ReportRelationDefinition {
        public String fieldSetName;
        public String objectName;
        public String parentLookupField;
        public String queryCondition;
        /**
         * @description  Boolean that decides whether all the related records of this type should be in one row or should they be separated in different rows
         * @example {abc} vs {a,b,c}
         */
        public Boolean stackValues { set; get { return this.stackValues == null ? false: this.stackValues; } }
        public List<ReportRelationDefinition> children;
        public List<Schema.FieldSetMember> fieldSetMembers;
        public Map<Id, List<SObject>> dataMap;
        public Id latestRecordId;
    }

    /**
     * @description Class that contains actual processed report data
     */
    @TestVisible
    public class ReportData {
        @AuraEnabled public List<Column> columns;
        @AuraEnabled public List<Map<String, Object>> data;
        @AuraEnabled public Id latestRecordId;
        private Set<String> objectKeys;
        private Map<String, Integer> objectCountMap;

        public ReportData(ReportRelationDefinition reportDefinition) {
            this.latestRecordId = reportDefinition.latestRecordId;
            this.objectKeys = new Set<String>();
            this.objectCountMap = new Map<String, Integer>();
            this.columns = populateColumns(new List<ReportRelationDefinition>{reportDefinition}, null);
            this.objectCountMap = new Map<String, Integer>();
            this.data = getDataRowsFromDefinition(reportDefinition, null, null, null);
        }

        /**
        * @description Populate the actual report data from report definition
        *
        * @param relationDefinition
        * @param dataRows
        * @param dataRow
        * @param parentId
        *
        * @return List of label/value
        */
        private List<Map<String, Object>> getDataRowsFromDefinition(ReportRelationDefinition relationDefinition, List<Map<String, Object>> dataRows, Map<String, Object> dataRow, Id parentId) {
            List<Map<String, Object>> finalDataList;
            String objectIndex = getObjectIndex(relationDefinition.objectName);
            /* Cloning map here since when multiple records are being processed the map needs to be refreshed to pre-loop state*/
            Map<String, Integer> objectCountOuterClone = this.objectCountMap.clone();
            if (parentId == null ) {
                finalDataList = new List<Map<String, Object>>();
            }
            if (dataRows == null) {
                dataRows = new List<Map<String, Object>>();
            }
            if (dataRow == null) {
                dataRow = new Map<String, Object>();
            }
            if (!relationDefinition.dataMap.containsKey(PARENT_KEY)  && ( parentId == null || !relationDefinition.dataMap.containsKey(parentId))) {
                dataRows.add(dataRow);
                return dataRows;
            }
            List<SObject> sobjectList = parentId == null ? relationDefinition.dataMap.get(PARENT_KEY) : relationDefinition.dataMap.get(parentId);
            if (sobjectList == null || sobjectList.isEmpty()) {
                return dataRows;
            }
            for (Integer count=0; count < sobjectList.size(); count++) {
                this.objectCountMap = objectCountOuterClone.clone();
                SObject aSObject = sobjectList.get(count);

                Map<String, Object> filledRow = !relationDefinition.stackValues
                        ? populateDataRowFields(dataRow, relationDefinition.fieldSetMembers, aSObject, objectIndex)
                        : populateDataRowFields(dataRow, relationDefinition.fieldSetMembers, aSObject, objectIndex + String.valueOf(count+1));
                if (relationDefinition.stackValues && count != sobjectList.size()-1) {
                    dataRow = filledRow;
                    continue;
                }
                if (relationDefinition.children == null || relationDefinition.children.isEmpty()) {
                    dataRows.add(filledRow);
                } else {
                    for (Integer index=0; index < relationDefinition.children.size(); index++) {
                        /** Decides whether the current definition is in the same data tree**/
                        Boolean concatenateRecords  = index > 0;
                        if (!concatenateRecords) {
                            dataRows = getDataRowsFromDefinition(relationDefinition.children.get(index), dataRows, filledRow, aSObject.Id);
                            continue;
                        }
                        List<Map<String, Object>> dataRowsClone = dataRows.clone();
                        dataRows = new List<Map<String, Object>>();
                        /* Cloning map here for filling inner rows, since the same report definitions are processed multiple times in a loop */
                        Map<String, Integer> objectCountInnerClone = this.objectCountMap.clone();
                        for (Map<String, Object> preFilledDataRow: dataRowsClone) {
                            this.objectCountMap = objectCountInnerClone.clone();
                            dataRows = getDataRowsFromDefinition(relationDefinition.children.get(index), dataRows, preFilledDataRow, aSObject.Id);
                        }
                    }
                }
                if (dataRows != null && !dataRows.isEmpty() && parentId == null) {
                    finalDataList.addAll(dataRows);
                    dataRows = new List<Map<String, Object>>();
                    if (count == sobjectList.size()-1) {
                        return finalDataList;
                    }
                }
            }
            return dataRows;
        }

        private Map<String, Object> populateDataRowFields(Map<String, Object> dataRow, List<Schema.FieldSetMember> fieldSetMembers, SObject aObject, String index) {
            Map<String, Object> filledRow = dataRow.clone();
            String objectName = aObject.getSObjectType().getDescribe().getLocalName();
            for (FieldSetMember fsMember : fieldSetMembers) {
                String objectField = fsMember.getFieldPath();
                filledRow.put(objectName + index + '.' + objectField, ClsSObjectUtils.getFieldValue(aObject, objectField));
            }
            return filledRow;
        }

        private Map<String, Object> populateDataRowFields(Map<String, Object> dataRow, List<Schema.FieldSetMember> fieldSetMembers, SObject aObject) {
             return populateDataRowFields(dataRow, fieldSetMembers, aObject, '');
        }

        private List<Column> populateColumns(List<ReportRelationDefinition> reportDefinitions, List<Column> columns) {
            if (columns == null) {
                columns = new List<Column>();
            }
            List<ReportRelationDefinition> nextReportRelationDefinitions = new List<ReportRelationDefinition>();
            for (ReportRelationDefinition reportDefinition : reportDefinitions) {
                String objectIndex = getObjectIndex(reportDefinition.objectName);
                if (reportDefinition.children != null) {
                    nextReportRelationDefinitions.addAll(reportDefinition.children);
                }
                if (reportDefinition.stackValues) {
                    columns.addAll(getStackedColumns(reportDefinition));
                    continue;
                }
                for (FieldSetMember fieldSetMember: reportDefinition.fieldSetMembers) {
                    columns.add(new Column(reportDefinition.objectName, fieldSetMember).addIndex(objectIndex));
                }
            }
            if (nextReportRelationDefinitions.isEmpty()) {
                return columns;
            }
            return populateColumns(nextReportRelationDefinitions, columns);
        }

        /**
         * @description Create unique index for an object in the report when there is the same object multiple times in the report
         *
         * @param objectName
         *
         * @return String uniqueKey
         */
        private String getObjectIndex(String objectName) {
            if (!this.objectCountMap.containsKey(objectName)) {
                this.objectCountMap.put(objectName, -1);
            } else {
                Integer objectCount = objectCountMap.get(objectName);
                this.objectCountMap.put(objectName, objectCount+1);
            }
            if (this.objectCountMap.get(objectName) < 0) {
                return '';
            }
            if (this.objectKeys.size() <= this.objectCountMap.get(objectName)) {
                String uniqueKey;
                do {
                    uniqueKey = ClsSObjectUtils.generateRandomString(3);
                } while (this.objectKeys.contains(uniqueKey));
                this.objectKeys.add(uniqueKey);
            }
            return new List<String>(this.objectKeys).get(this.objectCountMap.get(objectName));
        }

        private List<Column> getStackedColumns (ReportRelationDefinition reportDefinition) {
            List<Column> columns = new List<Column>();
            Integer maxChildrenAmount = 0;
            for (List<SObject> sobjectList: reportDefinition.dataMap.values()) {
                if (sobjectList.size() <= maxChildrenAmount) {
                    continue;
                }
                maxChildrenAmount = sobjectList.size();
            }
            for (Integer index = 1; index <= maxChildrenAmount; index++ ) {
                for (FieldSetMember fieldSetMember: reportDefinition.fieldSetMembers) {
                    columns.add(new Column(reportDefinition.objectName, fieldSetMember).addIndex(index));
                }
            }
            return columns;
        }
    }

    @TestVisible
    private class Column {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Integer initialWidth;

        public Column(String objectName, FieldSetMember fsMember) {
            this.label = fsMember.getLabel();
            this.fieldName = objectName + '.' + fsMember.getFieldPath();
            this.type = String.valueOf(fsMember.getType()).toLowerCase();
            this.sortable = false;
            this.initialWidth = 150;
        }

        private Column addIndex(Object index) {
            if (index == null || index == '') {
                return this;
            }
            this.fieldName = fieldName.replace('.', String.valueOf(index) + '.');
            return this;
        }
    }
}