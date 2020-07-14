/**
 * Created by w.novoa on 19.11.2018.
 */

global class BatchAssetMigration implements Database.Batchable<sObject>,Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {


        return Database.getQueryLocator([select id, Id_List_Product_Price__r.Product_Name__c,Id_Opportunity__r.OwnerId,
                                                    Id_Account__c, Id_Opportunity__r.CurrencyIsoCode,Id_Opportunity__c
                                        from Additional_Charges__c
                                        where Id_List_Product_Price__r.Requires_Asset__c = true
                                            And Id_Opportunity__c != null
                                            And RecordType.DeveloperName = 'PY_Additional_Charges'
                                        Order by Id_Opportunity__c
            ]);
    }
    //
    global void execute(Database.BatchableContext BC, List<Additional_Charges__c> scope) {

        map<String,Asset__c> mpOptbyAsset = new map<String,Asset__c>();
        map<String,String> mpAssetbyOpt = new map<String,String>();
        set<String> stOptWithOutAsset = new set<String>();

        for(Additional_Charges__c addCharge : scope){ // fetch all the opportunities
            stOptWithOutAsset.add(addCharge.Id_Opportunity__c);
        }
        for(Asset__c asset: [select id,Opportunity__c from Asset__c where Opportunity__c IN: stOptWithOutAsset]){
            stOptWithOutAsset.remove(asset.Opportunity__c);
        }

        List<Asset__c> listAssets = new List<Asset__c>();

        for(Additional_Charges__c addCharge : [select id, Id_List_Product_Price__r.Product_Name__c,Id_Opportunity__r.OwnerId,
                                                Id_Account__c, Id_Opportunity__r.CurrencyIsoCode,Id_Opportunity__c
                                                from Additional_Charges__c
                                                where Id_Opportunity__c IN :stOptWithOutAsset] ){
            if(stOptWithOutAsset.Contains(addCharge.Id_Opportunity__c)){
                Asset__c newAsset = new Asset__c();
                newAsset.name = addCharge.Id_List_Product_Price__r.Product_Name__c;
                newAsset.OwnerId = addCharge.Id_Opportunity__r.OwnerId;
                newAsset.Account__c = addCharge.Id_Account__c;
                newAsset.CurrencyIsoCode = addCharge.Id_Opportunity__r.CurrencyIsoCode;
                newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('PY_Asset');
                //newAsset.Id_Opportunity_Quote_Line_Item__c = ;
                newAsset.Opportunity__c = addCharge.Id_Opportunity__c;
                newAsset.Status__c = 'Activated Successfully';
                listAssets.add(newAsset);
                mpOptbyAsset.put(newAsset.Opportunity__c,newAsset);
            }
        }


        if(!listAssets.isEmpty()){
            List<Database.saveResult> saveUpdateResults = Database.insert(listAssets);

            LoggingUtility.createLog('BatchAssetMigration','BATCH','Update Send Survey Flag',null);
            Boolean isError = false;
            for(Database.saveResult result : saveUpdateResults){
                if(!result.isSuccess()){
                    LoggingUtility.logError('BatchAssetMigration','BatchAssetMigration: Update failed for Asset ' + result.getId() +
                            ' Errors '  + result.getErrors() + '\n');
                    isError = true;
                }
            }

            // Do Logging in case of error.
            if(isError){
                LoggingUtility.commitLogs();
            }
        }

        List<case> lstCase = new List<case>();

        lstCase = [select id, Opportunity__c from case
                    where recordType.DeveloperName = 'PY_Restaurant_Operations'
                        AND (Type = 'Onboarding' OR Type = 'Logistics') AND Opportunity__c IN :mpOptbyAsset.keyset()];

        for(Case caso: lstCase){
            caso.Asset__c = mpOptbyAsset.get(caso.Opportunity__c).id;
        }


        if(!lstCase.isEmpty()){
            List<Database.saveResult> saveUpdateResults = Database.update(lstCase);

            LoggingUtility.createLog('BatchAssetMigration','BATCH','CreateCase',null);
            Boolean isError = false;
            for(Database.saveResult result : saveUpdateResults){
                if(!result.isSuccess()){
                    LoggingUtility.logError('BatchAssetMigration','BatchAssetMigration: Update failed for Case ' + result.getId() +
                            ' Errors '  + result.getErrors() + '\n');
                    isError = true;
                }
            }

            // Do Logging in case of error.
            if(isError){
                LoggingUtility.commitLogs();
            }
        }

    }


    global void finish(Database.BatchableContext BC) {

    }
}