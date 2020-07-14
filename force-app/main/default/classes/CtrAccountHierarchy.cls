public with sharing class CtrAccountHierarchy {

    private static Map<String, Map<String, Business_Config__c>> businessData = LibBusinessConfig.motherOfAllBusinessMaps.get('Account Hierarchy');

    public CtrAccountHierarchy() {}

    public CtrAccountHierarchy(ApexPages.StandardController stdCtr) {}

    /**
     * Given an Account record type return all field's label to be displayed inside
     * the grid
     * @param  rtDevName RecordType developer name
     * @return           A list of headers or an empty list
     */
    @RemoteAction
    public static List<String> getHeaders(String rtDevName) {
        List<String> res = new List<String>();

        //System.debug('CtrAccountHierarchy.getHeaders: start, rtDevName is: ' + rtDevName);

        for (FieldDesc fld : getFieldsDescription(rtDevname)) {
            res.add(fld.label);
        }

        //System.debug('CtrAccountHierarchy.getHeaders: done, res is: ' + res);

        return res;
    } 

    /**
     * Given an account Id retrieves the related account hierarchy
     * @param  accId Account id
     * @return       a list of nodes to be displayed on the page
     */
    @RemoteAction
    public static List<TreeNode> getTree(String accId) {
        Map<Id, List<Account>> parentToChildren = new Map<Id, List<Account>>();
        Account rootAcc;
        Account acc;
        Set<Id> idToQueryFor = new Set<Id>();
        Set<Id> parentIdToQueryFor = new Set<Id>();
        Set<Id> idAlreadyVisited = new Set<Id>();
        Set<Id> parentIdAlreadyVisited = new Set<Id>();

        acc = ClsAccountSelector.findAccountById(accId);
        
        String fldQueryString = getFieldsQueryString(getFieldsDescription(acc.RecordType.DeveloperName));
        
        //System.debug('CtrAccountHierarchy.getTree: fields query is: ' + fldQueryString);

        idToQueryFor.add(acc.Id);
        parentIdToQueryFor.add(acc.Id);

        while (!idToQueryFor.isEmpty() || !parentIdToQueryFor.isEmpty()) {
            List<Account> accs = (List<Account>) Database.query(
                                     'SELECT ParentId, Franchise_Connection__c, RecordType.DeveloperName, ' + fldQueryString + ' ' +
                                     'FROM Account ' +
                                     'WHERE (Id IN :idToQueryFor AND Id NOT IN :parentIdAlreadyVisited) OR (ParentId IN :parentIdToQueryFor AND Id NOT IN :idAlreadyVisited) '
                                 );
            /*
            I know what you are thinking here... SOQL inside a LOOP!!! WTF?!?!

                                  KEEP CALM
                                    and
                                  read this!

            The number of issued queries, in the worst case scenario, is equals to
            the longest path between two accounts plus 2 additional queries.

            So... as long as we do not have a crazy Account Hierarchy where there
            could be two accounts far away as many as 99 levels we should be fine :)

            This algorithm is a Salesforce equivalent of a Breadth-first search
            Link: https://en.wikipedia.org/wiki/Breadth-first_search
            */

            // we track already visited accounts
            idAlreadyVisited.addAll(idToQueryFor);
            parentIdAlreadyVisited.addAll(parentIdToQueryFor);

            idToQueryFor.clear();
            parentIdToQueryFor.clear();

            for (Account a : accs) {
                if (!parentIdAlreadyVisited.contains(a.Id)) {
                    parentIdToQueryFor.add(a.Id); // we this we will get all ChildAccount of this account
                }

                if (!idAlreadyVisited.contains(a.ParentId)) {
                    idToQueryFor.add(a.ParentId); // with this we will get the parent of current account
                }

                if (String.isBlank(a.ParentId)) {
                    rootAcc = a;
                    continue; // root should not be inserted into the map
                }

                // add child account to map
                if (!parentToChildren.containsKey(a.ParentId)) {
                    parentToChildren.put(a.ParentId, new List<Account>());
                }

                parentToChildren.get(a.ParentId).add(a);
            }
        }

        idAlreadyVisited.clear();
        parentIdAlreadyVisited.clear();

        //System.debug('CtrAccountHierarchy.getTree: done, creating tree...');

        return new List<TreeNode> {new TreeNode(rootAcc, parentToChildren)};
    }

    /*******************************************************************************************************
    * @description Generates treeNodes with hierarchy of franchise connection
    * @param String Account Id.
    * @return List<TreeNode>
    */
    @RemoteAction
    public static List<TreeNode> getFranchiseHierarchy(String accId) {
        Map<Id, List<Account>> franchiseHierarchy = new Map<Id, List<Account>>();
        Account rootAcc;
        Account acc;
        Id franchiseRelationId;

        acc = ClsAccountSelector.findAccountById(accId);

        String fldQueryString = getFieldsQueryString(getFieldsDescription(acc.RecordType.DeveloperName));

        if (acc.Franchise_Connection__c == null) {
            return null;
        } else {
            franchiseRelationId = acc.Franchise_Connection__c;

            Set<Id> idToQueryFor = new Set<Id>(); // to store records for which parent is to be queried
            Set<Id> idAlreadyVisited = new Set<Id>(); // to store records for which parent is known

            //System.debug('CtrAccountHierarchy.getFranchiseTree: fields query is: ' + fldQueryString);

            idToQueryFor.add(acc.Id);
            idToQueryFor.add(acc.Franchise_Connection__c);

            while (!idToQueryFor.isEmpty() ) {
                List<Account> accs = (List<Account>) Database.query(
                                        'SELECT ParentId, Franchise_Connection__c, RecordType.DeveloperName, ' + fldQueryString + ' ' +
                                        'FROM Account ' +
                                        'WHERE (Id IN :idToQueryFor AND Id NOT IN :idAlreadyVisited) '
                                    );
                /*
                I know what you are thinking here... SOQL inside a LOOP!!! WTF?!?!

                                    KEEP CALM
                                        and
                                    read this!

                The number of issued queries, in the worst case scenario, is equals to
                the longest path between two accounts plus 2 additional queries.

                So... as long as we do not have a crazy Account Hierarchy where there
                could be two accounts far away as many as 99 levels we should be fine :)

                This algorithm is a Salesforce equivalent of a Breadth-first search
                Link: https://en.wikipedia.org/wiki/Breadth-first_search
                */

                // we track already visited accounts
                idAlreadyVisited.addAll(idToQueryFor);
                idToQueryFor.clear();

                for (Account a : accs) {
                    String parentId = a.parentId;

                    if (a.Franchise_Connection__c == franchiseRelationId) {
                        parentId = a.Franchise_Connection__c;
                    }

                    idToQueryFor.add(parentId); // we store the id of parent account for further quering

                    if (String.isBlank(parentId)) {
                        rootAcc = a;
                        continue;
                    }

                    // add child account to franchise map
                    if (!franchiseHierarchy.containsKey(parentId)) {
                        franchiseHierarchy.put(parentId, new List<Account>());
                    }

                    franchiseHierarchy.get(parentId).add(a);
                }     
            }

            idAlreadyVisited.clear();

            //System.debug('CtrAccountHierarchy.getFranchiseTree: done, creating tree...');

            return new List<TreeNode> {new TreeNode(rootAcc, franchiseHierarchy)};
        }
    }


    /*******************************************************************************************************
    * @description Generates treeNodes with accounts that are franchisers of current account
    * @param String Account Id.
    * @return List<TreeNode>
    */
    @RemoteAction
    public static List<TreeNode> getFranchiseChildRelations(String accId) {
        System.debug('CtrAccountHierarchy.getFranchiseTree: start, accId is: ' + accId);
        Account acc;
        Account rootAccount;

        acc = ClsAccountSelector.findAccountById(accId);

        String fldQueryString = getFieldsQueryString(getFieldsDescription(acc.RecordType.DeveloperName));

        Map<Id, List<Account>> franchiseHierarchy = new Map<Id, List<Account>>();

        List<Account> accs = (List<Account>) Database.query(
                'SELECT Id, ParentId, Franchise_Connection__c, RecordType.DeveloperName, ' + fldQueryString + ' ' +
                        'FROM Account ' +
                        'WHERE Franchise_Connection__c =: accId OR Id =: accId '
        );

        for (Account a : accs) {
            if (a.Id == accId){
                rootAccount = a;
                continue;
            }
            // add child account to franchise map
            if (!franchiseHierarchy.containsKey(accId)) {
                franchiseHierarchy.put(accId, new List<Account>());
            }
            franchiseHierarchy.get(accId).add(a);
        }

        if (franchiseHierarchy.get(accId).IsEmpty()) {
            return null;
        }

        //System.debug('CtrAccountHierarchy.getFranchiseChildRelations: ' + franchiseHierarchy);
        return new List<TreeNode> {new TreeNode(rootAccount, franchiseHierarchy)};
    }

    /**
     * Retrieves fields to display from BC and set related field's metadata information
     * @param  rtDevname RecordType developer name
     * @return           A list of fields to or an empty list
     */
    private static List<FieldDesc> getFieldsDescription(String rtDevname) {

        //System.debug('CtrAccountHierarchy.getFieldsDescription: start, rtDevName is: ' + rtDevName);

        if (businessData.get(rtDevname) == null) {
            return new List<FieldDesc>();
        }

        List<FieldDesc> res =  (List<FieldDesc>) JSON.deserialize(businessData.get(rtDevName).get('FieldsToQuery').Business_Rule_Value__c, List<FieldDesc>.class);

        //System.debug('CtrAccountHierarchy.getFieldsDescription: fields are: ' + res);

        Map<String, Schema.SObjectField> fieldType = Account.getSobjectType().getDescribe().fields.getMap();

        for (FieldDesc fld : res) {
            fld.addDetails(fieldType.get(fld.apiName).getDescribe());
        }

        //System.debug('CtrAccountHierarchy.getFieldsDescription: done');

        return res;
    }

    /**
     * Given a list of fields to display returns the SOQL query to execute
     * @param  fields List of fields
     * @return        Query string or empty string
     */
    private static String getFieldsQueryString(List<FieldDesc> fields) {
        String res = '';

        for (FieldDesc fld : fields) {
            if (fld.isPicklist) {
                res += 'toLabel(' + fld.apiName + '),';
            } else if (fld.isLookup) {
                res += fld.apiName + ',' + fld.relationshipField + ',';
            } else {
                res += fld.apiName + ',';
            }
        }

        return res.removeEnd(',');
    }

    /**
     * Represent a node inside the Hierarchy structure
     */
    @testVisible
    class TreeNode {
        public List<TreeNode> children  {get; set;}
        public List<FieldDesc> fields   {get; set;}
        public String id {get; set;}

        public TreeNode(Account acc, Map<Id, List<Account>> parentToChildren) {

            //System.debug('CtrAccountHierarchy.TreeNode.init: start, account is: ' + acc);

            id = acc.Id;
            children = new List<TreeNode>();

            // try to change this...
            this.fields = getFieldsDescription(acc.RecordType.DeveloperName);

            for (FieldDesc fld : this.fields) {

                //System.debug('CtrAccountHierarchy.TreeNode.init: processing fld: ' + fld);

                if (fld.isLookup) {
                    String relFld = fld.relationshipField.split('\\.')[0];
                    String fldName = fld.relationshipField.split('\\.')[1];

                    fld.value = (acc.getSObject(relFld) != null) ? String.valueOf(acc.getSObject(relFld).get(fldName)) : '';
                    fld.referenceTo = String.valueOf(acc.get(fld.apiName));
                } else {
                    fld.value = String.valueOf(acc.get(fld.apiName));
                }
            }

            if (parentToChildren.containsKey(acc.Id)) {
                for (Account child : parentToChildren.get(acc.Id)) {
                    children.add(new TreeNode(child, parentToChildren));
                }
            }
        }
    }

    /**
     * Represent a field to be displayed on the page
     */
    class FieldDesc {
        public String apiName           {get; set;}
        public String label             {get; set;}
        public String value             {get; set;}
        public String referenceTo       {get; set;}
        public String relationshipField {get; set;}
        public Boolean isLookup         {get; set;}
        public Boolean isPicklist       {get; set;}
        public Boolean isHeaderField    {get; set;}

        public void addDetails(Schema.DescribeFieldResult df) {
            label = df.getLabel();
            isPicklist = (df.getType() == Schema.DisplayType.Picklist
                          || df.getType() == Schema.DisplayType.MultiPicklist);
        }
    }
}