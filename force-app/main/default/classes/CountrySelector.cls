public inherited sharing class CountrySelector {
    public static Country__c getCountryByName(String countryName){
        return [SELECT Id,Name,Iso__c,CurrencyIsoCode FROM Country__c WHERE Name = :countryName LIMIT 1];
    }
    public static List<Country__c> getCountryList(Set<String> countryNames){
        return [SELECT Id,Iso__c,Name FROM Country__c WHERE Name IN :countryNames];
    }
}
