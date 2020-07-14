/***
 * @description Util class for MigrationScriptShipmentOrders_Batch
 * @date 07.05.2020
 * @author Konrad Czykin
 */
public class MigrationScriptShipmentOrders_Utils {

    private Map<Id, Opportunity> mapOpp;
    private Map<Id, List<Shipment_Order__c>> mapShipmentOrder;
    Map<String, Map<String, String>> mapCountryLPP;                     //map of <CountryName, <ProductName, ListProducPrice Id>>
    Map<String, Map<String, String>> mapOppQLI;                         //map of <Opportunity Id <Opp Quote Line Item Name, Opp Quote Line Item Id>>
    Map<String, Map<String, Opportunity_Line_Item__c>> mapOppOLI;       //map of <Opportunity Id <Opportunity Line Item Name, Opportunity Line Item>>
    Map<String, List<Opportunity_Quote_Line_Item__c>> mapExistinQLI;    //map of existing Quote Line Items <Opportunity Id, List<Opportunity_Quote_Line_Item>>
    Map<String, List<Opportunity_Line_Item__c>> mapExistingOLI;         //map of existing Opportunity Line Items <Opportunity Id List<Opportunity-LIne_Item>>
    private static final String SIMCARD = 'SIM Card';
    private static final String TABLET = 'Tablet';

    /***
    * @description class constructor
    */
    public MigrationScriptShipmentOrders_Utils(Map<Id, Opportunity> mapOpp, Map<String, Map<String, String>> mapCountryLPP){
        this.mapOpp = mapOpp;
        this.mapCountryLPP = mapCountryLPP;
        mapExistinQLI = createOppQLImap(mapOpp.values());
        mapExistingOLI = createOLImap(mapOpp.values());
    }

    /***
    * @description method creates Shipment Order records
    */
    public MigrationScriptShipmentOrders_Utils createShipmentOrder(){
        List<Shipment_Order__c> lstSO = new List<Shipment_Order__c>();
        for(Opportunity opp : mapOpp.values()){
            List<Shipment_Order__c> lstSOopp = new List<Shipment_Order__c>();
            lstSOopp = initializeShipmentOrder(opp);
            if(!lstSOopp.isEmpty()){
                lstSO.addAll(lstSOopp);
            }
        }
        insert lstSO;
        this.mapShipmentOrder = ClsSObjectUtils.convertToIdMap(lstSO, Shipment_Order__c.Id.getDescribe().getLocalName());
        return this;
    }

    /***
    * @description method creates Shipment Order records
    * @param opp - Opportunity
    * @return List<Shipment_Order__c>
    */
    private List<Shipment_Order__c> initializeShipmentOrder(Opportunity opp){
        List<Shipment_Order__c> lstSO = new List<Shipment_Order__c>();
        if(opp.Opportunity_Quotes__r == null || opp.Opportunity_Quotes__r.isEmpty()){
            return lstSO;
        }
        for(Opportunity_Quote__c oq : opp.Opportunity_Quotes__r){
            Shipment_Order__c so = new Shipment_Order__c();
            so.Status__c = 'Ready to be shipped';
            so.Type__c = 'DH to Vendor';
            so.Account__c = opp.AccountId;
            so.Opportunity__c = opp.Id;
            so.Opportunity_Quote__c = oq.Id;
            so.CurrencyIsoCode = opp.Account.CurrencyIsoCode;
            so.Account_Country__c = opp.Record_Country__c;
            
            lstSO.add(so);
        }
        
        return lstSO;
    }

    /***
    * @description method creates Shipment Order Line Items records
    */
    public MigrationScriptShipmentOrders_Utils createShipmentOrderLineItem(){
        List<Shipment_Order_Line_Item__c> lstSOLI = new List<Shipment_Order_Line_Item__c>();
        for(Id soId : mapShipmentOrder.keySet()){
            List<Shipment_Order__c> lstSO = mapShipmentOrder.get(soId);
            for(Shipment_Order__c so : lstSO){
                lstSOLI.addAll(initializeShipmentOrderLineItem(so));
            }
        }
        insert lstSOLI;
        return this;
    }

    /***
    * @description method maps fields for Shipment Order Line Items
    * @param so - Shipment Order
    * @return lstSOLI - List<Shipment_Order_Line_Item__c>
    */
    private List<Shipment_Order_Line_Item__c> initializeShipmentOrderLineItem(Shipment_Order__c so){
        List<Shipment_Order_Line_Item__c> lstSOLI = new List<Shipment_Order_Line_Item__c>();
        String countryCode = mapOpp.get(so.Opportunity__c).Account.Account_Country_Code__c;
        Opportunity_Line_Item__c oliSim = mapOppOLI.get(so.Opportunity__c).get(SIMCARD);
        Opportunity_Line_Item__c oliTablet = mapOppOLI.get(so.Opportunity__c).get(TABLET);
        Shipment_Order_Line_Item__c soliTablet = new Shipment_Order_Line_Item__c();
        Shipment_Order_Line_Item__c soliSIM = new Shipment_Order_Line_Item__c();
        
        soliTablet.Shipment_Order__c = so.Id;
        soliTablet.Name = oliTablet.Name;
        soliTablet.Quantity__c = oliTablet.Quantity__c;
        soliTablet.Total_Amount__c = oliTablet.Total_Amount__c;
        soliTablet.SKU__c = countryCode + '-' + TABLET;
        soliTablet.CurrencyIsoCode = oliTablet.CurrencyIsoCode;
        soliTablet.Opportunity_Quote_Line_Item__c = mapOppQLI.get(so.Opportunity__c).get(TABLET);
        soliTablet.List_Product_Price__c = oliTablet.Id_List_Price_Product__c;
        lstSOLI.add(soliTablet);

        soliSIM.Shipment_Order__c = so.Id;
        soliSIM.Name = oliSim.Name;
        soliSIM.Quantity__c = oliSim.Quantity__c;
        soliSIM.Total_Amount__c = oliSIM.Total_Amount__c;
        soliSIM.SKU__c = countryCode + '-' + SIMCARD;
        soliSIM.CurrencyIsoCode = oliSim.CurrencyIsoCode;
        soliSIM.Opportunity_Quote_Line_Item__c = mapOppQLI.get(so.Opportunity__c).get(SIMCARD);
        soliSIM.List_Product_Price__c = oliSim.Id_List_Price_Product__c;
        lstSOLI.add(soliSIM);
        return lstSOLI;
    }

    /***
    * @description method creates Opportunity Quote Line Items records
    */
    public MigrationScriptShipmentOrders_Utils createOppQuoteLineItem(){
        List<Opportunity_Quote_Line_Item__c> lstOppQLI = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity opp : this.mapOpp.values()){
            List<Opportunity_Quote_Line_Item__c> lstOppQLIopp = new List<Opportunity_Quote_Line_Item__c>();
            lstOppQLIopp = initializeOppQuoteLineItem(opp);
            if(!lstOppQLIopp.isEmpty()){
                lstOppQLI.addAll(lstOppQLIopp);
            }
        }
        if(!lstOppQLI.isEmpty()){
            insert lstOppQLI;
        }
        this.mapOppQLI = createMapOfOppQLI(lstOppQLI);
        return this;
    }

    /***
    * @description method maps fields for Opportunity Quote Line Items
    * @param opp - Opportunity
    * @return lstoppQLI - List<Opportunity_Quote_Line_Item__c>
    */
    private List<Opportunity_Quote_Line_Item__c> initializeOppQuoteLineItem(Opportunity opp){
        List<Opportunity_Quote_Line_Item__c> lstoppQLI = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> existingSimOQLI = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> existingTabletOQLI = new List<Opportunity_Quote_Line_Item__c>();

        if(opp.Opportunity_Quotes__r == null || opp.Opportunity_Quotes__r.isEmpty()){
            return lstoppQLI;
        }
        String companyCode = mapOpp.get(opp.Id).Account.Company_Code__c;
        Date startDate = Date.today();
        Opportunity_Quote__c oq = opp.Opportunity_Quotes__r[0];
        Id recordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Opportunity_Quote_Line_Item');

        Opportunity_Line_Item__c oliSim = mapOppOLI.get(opp.Id).get(SIMCARD);
        Opportunity_Line_Item__c oliTablet = mapOppOLI.get(opp.Id).get(TABLET);

        Opportunity_Quote_Line_Item__c oppQLISIM = new Opportunity_Quote_Line_Item__c();
        Opportunity_Quote_Line_Item__c oppQLITablet = new Opportunity_Quote_Line_Item__c();
        
        if(mapExistinQLI.get(opp.Id) != null && !mapExistinQLI.isEmpty()){
            for(Opportunity_Quote_Line_Item__c oqli : mapExistinQLI.get(opp.Id)){
                if(oqli.Name == SIMCARD){
                    existingSimOQLI.add(oqli);
                }
                if(oqli.Name == TABLET){
                    existingTabletOQLI.add(oqli);
                }
            }
        }

        if(existingSimOQLI.isEmpty()){
            oppQLISIM.Id_Opportunity__c = opp.Id;
            oppQLISIM.Id_Opportunity_Quote__c = oq.Id;
            oppQLISIM.CurrencyIsoCode = oliSim.CurrencyIsoCode;
            oppQLISIM.Name = oliSim.Name;
            oppQLISIM.Line_Item_Type__c  = oliSim.Line_Item_Type__c;
            oppQLISIM.Listed_Price__c = oliSim.Listed_Price__c;
            oppQLISIM.Product_Group__c = oliSim.Product_Group__c;
            oppQLISIM.Quantity__c = oliSim.Quantity__c;
            oppQLISIM.RecordTypeId = recordTypeId;
            oppQLISIM.Sub_type__c = oliSim.Sub_type__c;
            oppQLISIM.Status__c = 'Created';
            oppQLISIM.Start_Date__c = startDate;
            oppQLISIM.Id_List_Product_Price__c = oliSim.Id_List_Price_Product__c;
            oppQLISIM.Delivery__c = oliSim.Delivery__c;
            oppQLISIM.Total_Amount__c = oliTablet.Total_Amount__c;
            lstoppQLI.add(oppQLISIM);
        }

        if(existingTabletOQLI.isEmpty()){
            oppQLITablet.Id_Opportunity__c = opp.Id;
            oppQLITablet.Id_Opportunity_Quote__c = oq.Id;
            oppQLITablet.CurrencyIsoCode = oliTablet.CurrencyIsoCode;
            oppQLITablet.Name = oliTablet.Name;
            oppQLITablet.Line_Item_Type__c = oliTablet.Line_Item_Type__c;
            oppQLITablet.Listed_Price__c =oliTablet.Listed_Price__c;
            oppQLITablet.Product_Group__c = oliTablet.Product_Group__c;
            oppQLITablet.Quantity__c = oliTablet.Quantity__c;
            oppQLITablet.RecordTypeId = recordTypeId;
            oppQLITablet.Sub_type__c = oliTablet.Sub_type__c;
            oppQLITablet.Status__c = 'Created';
            oppQLITablet.Start_Date__c = startDate;
            oppQLITablet.Id_List_Product_Price__c = oliTablet.Id_List_Price_Product__c;
            oppQLITablet.Delivery__c = oliTablet.Delivery__c;
            oppQLITablet.Total_Amount__c = oliTablet.Total_Amount__c;
            lstoppQLI.add(oppQLITablet);
        }

        return lstoppQLI;
    }

    /***
    * @description method creates Opportunity Line Items records
    */
    public MigrationScriptShipmentOrders_Utils createOpportunityLineItem(){
        List<Opportunity_Line_Item__c> lstOLI = new List<Opportunity_Line_Item__c>();
        for(Opportunity opp : mapOpp.values()){
            List<Opportunity_Line_Item__c> lstOppOLI = new List<Opportunity_Line_Item__c>();
            lstOppOLI = initializeOpportunityLineItem(opp);
            if(!lstOppOLI.isEmpty()){
                lstOLI.addAll(lstOppOLI);
            }
        }
        if(!lstOLI.isEmpty()){
            insert lstOLI;
        }
        this.mapOppOLI = createMapOfOppOLI(lstOLI);

        return this;
    }

    /***
    * @description method maps fields for Opportunity Line Items
    * @param opp - Opportunity
    * @return lstOLI - List<Oppoerunity_Line_Item__c>
    */
    private List<Opportunity_Line_Item__c> initializeOpportunityLineItem(Opportunity opp){
        List<Opportunity_Line_Item__c> lstOLI = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Line_Item__c> existingSimOLI = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Line_Item__c> existingTabletOLI = new List<Opportunity_Line_Item__c>();
        Opportunity_Line_Item__c oliSIM = new Opportunity_Line_Item__c();
        Opportunity_Line_Item__c oliTablet = new Opportunity_Line_Item__c();
        String companyCode = mapOpp.get(opp.Id).Account.Company_Code__c;

        if(opp.Opportunity_Line_Items__r != null && !opp.Opportunity_Line_Items__r.isEmpty()){
            for(Opportunity_Line_Item__c oli : opp.Opportunity_Line_Items__r){
                if(oli.Name == SIMCARD){
                    existingSimOLI.add(oli);
                }
                if(oli.Name == TABLET){
                    existingTabletOLI.add(oli);
                }
            }
        }

        if(existingSimOLI.isEmpty()){
            oliSIM.Name = 'SIM Card';
            oliSIM.Line_Item_Type__c = 'Product';
            oliSIM.Sub_type__c = 'Hardware';
            oliSIM.Id_Opportunity__c = opp.Id;
            oliSIM.CurrencyIsoCode = mapOpp.get(opp.Id).Account.CurrencyIsoCode;
            oliSIM.Listed_Price__c = 0;
            oliSIM.Product_Group__c = 'Add. Charges';
            oliSIM.Delivery__c = 'Shipment';
            oliSIM.Installments__c = 1;
            oliSIM.Quantity__c = 1;
            oliSIM.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Opportunity_Line_Item');
            oliSIM.Id_List_Price_Product__c = mapCountryLPP.get(opp.Record_Country__c).get(SIMCARD);  
            oliSIM.Total_Amount__c = 0;
            lstOLI.add(oliSIM);
        }

        if(existingTabletOLI.isEmpty()){
            oliTablet.Name = 'Tablet';
            oliTablet.Line_Item_Type__c = 'Product';
            oliTablet.Sub_type__c = 'Hardware';
            oliTablet.Id_Opportunity__c = opp.Id;
            oliTablet.CurrencyIsoCode = mapOpp.get(opp.Id).Account.CurrencyIsoCode;
            oliTablet.Listed_Price__c = 0; 
            oliTablet.Product_Group__c = 'Add. Charges';
            oliTablet.Delivery__c = 'Shipment';
            oliTablet.Installments__c = 1;
            oliTablet.Quantity__c = 1;
            oliTablet.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Opportunity_Line_Item');
            oliTablet.Id_List_Price_Product__c = mapCountryLPP.get(opp.Record_Country__c).get(TABLET); 
            oliTablet.Total_Amount__c = 0;
            lstOLI.add(oliTablet);
        }
        return lstOLI;
    }

    /***
    * @description method creates map <Opportunity Id, <Opportunity Quote Line Item Name, Opportunity Quote Line Item Id>>
    *   used to assign Opportunity Quote Line Item to Shipment Order Line Items
    * @param lstOppQLI - List of Opportunity Quote Line Items
    * @return mapOppQ - Map<String, Map<String, String>>
    */
    private Map<String, Map<String, String>> createMapOfOppQLI(List<Opportunity_Quote_Line_Item__c> lstOppQLI){
        Map<String, Map<String, String>> mapOppQ = new Map<String, Map<String, String>>();
        
        if(lstOppQLI != null && !lstOppQLI.isEmpty()){
            for(Opportunity_Quote_Line_Item__c oQLI : lstOppQLI){
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put(oQLI.Name, oQLI.Id);
                if(mapOppQ.get(oQLI.Id_Opportunity__c) == null){
                    mapOppQ.put(oQLI.Id_Opportunity__c, tempMap);
                    continue;
                }
                mapOppQ.get(oQLI.Id_Opportunity__c).putAll(tempMap);
            }
        }

        if(mapExistinQLI != null && !mapExistinQLI.isEmpty()){
            for(String oppId : mapExistinQLI.keySet()){
                Map<String, String> tempMap = new Map<String, String>();
                for(Opportunity_Quote_Line_Item__c qli : mapExistinQLI.get(oppId)){
                    tempMap.put(qli.Name, qli.Id);
                }
                if(mapOppQ.get(oppId) == null){
                    mapOppQ.put(oppId, tempMap);
                    continue;
                }
                mapOppQ.get(oppId).putAll(tempMap);
            }
        }

        return mapOppQ;
    }

    /***
    * @description method creates map <Opportunity Id, <Opportunity Line Item Name, Opportunity Line Item Id>>
    *   used to assign Opportunity Quote Line Item to Shipment Order Line Items
    * @param lstOppOLI - List of Opportunity Line Items
    * @return mapOppOLItemp - Map<String, Map<String, Opportunity_Line_Item__c>>
    */
    private Map<String, Map<String, Opportunity_Line_Item__c>> createMapOfOppOLI(List<Opportunity_Line_Item__c> lstOppOLI){
        Map<String, Map<String, Opportunity_Line_Item__c>> mapOppOLItemp = new Map<String, Map<String, Opportunity_Line_Item__c>>();
        
        if(lstOppOLI != null && !lstOppOLI.isEmpty()){
            for(Opportunity_Line_Item__c oOLI : lstOppOLI){
                Map<String, Opportunity_Line_Item__c> tempMap = new Map<String, Opportunity_Line_Item__c>();
                tempMap.put(oOLI.Name, oOLI);
                if(mapOppOLItemp.get(oOLI.Id_Opportunity__c) == null){
                    mapOppOLItemp.put(oOLI.Id_Opportunity__c, tempMap);
                    continue;
                }
                mapOppOLItemp.get(oOLI.Id_Opportunity__c).putAll(tempMap);
            }
        }

        if(mapExistingOLI != null && !mapExistingOLI.isEmpty()){
            for(String oppId : mapExistingOLI.keySet()){
                Map<String, Opportunity_Line_Item__c> tempMap = new Map<String, Opportunity_Line_Item__c>();
                for(Opportunity_Line_Item__c oli : mapExistingOLI.get(oppId)){
                    tempMap.put(oli.Name, oli);
                }
                if(mapOppOLItemp.get(oppId) == null){
                    mapOppOLItemp.put(oppId, tempMap);
                    continue;
                }
                mapOppOLItemp.get(oppId).putAll(tempMap);
            }
        }
        
        return mapOppOLItemp;
    }

    /***
    * @description method creates map <Opportunity Id, List<Opportunity Quote Line Item>>
    * @param lstOpp - List of Opportunity
    * @return mapQLI - Map<String, List<Opportunity_Quote_Line_Item__c>>
    */
    private Map<String, List<Opportunity_Quote_Line_Item__c>>  createOppQLImap(List<Opportunity> lstOpp){
        Map<String, List<Opportunity_Quote_Line_Item__c>> mapQLI = new Map<String, List<Opportunity_Quote_Line_Item__c>>();
        List<Opportunity_Quote_Line_Item__c> lstOQLI = [SELECT Id, Name, Id_Opportunity__c FROM Opportunity_Quote_Line_Item__c WHERE Id_Opportunity__c IN :lstOpp];
        for(Opportunity_Quote_Line_Item__c oqli : lstOQLI){
            if(mapQLI.get(oqli.Id_Opportunity__c) == null){
                mapQLI.put(oqli.Id_Opportunity__c, new List<Opportunity_Quote_Line_Item__c>{oqli});
            }else{
                mapQLI.get(oqli.Id_Opportunity__c).add(oqli);
            }
        }
        return mapQLI;
    }

    /***
    * @description method creates map <Opportunity Id, List<Opportunity Line Item>
    * @param lstOpp - List of Opportunity
    * @return mapOLI - Map<String, List<Opportunity_Line_Item__c>>
    */
    private Map<String, List<Opportunity_Line_Item__c>> createOLImap(List<Opportunity> lstOpp){
        Map<String, List<Opportunity_Line_Item__c>> mapOLI = new Map<String, List<Opportunity_Line_Item__c>>();
        for(Opportunity opp : lstOpp){   
            mapOLI.put(opp.Id, new List<Opportunity_Line_Item__c>(opp.Opportunity_Line_Items__r));
        }
        return mapOLI;
    }
}