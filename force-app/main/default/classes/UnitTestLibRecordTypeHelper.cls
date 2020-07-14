@isTest
private class UnitTestLibRecordTypeHelper {

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
    }

    @isTest static void getDefaultRecordTypeIdReturnsCorrectly() {
        Id res = LibRecordTypeHelper.getDefaultRecordTypeId(Schema.Account.SobjectType);
        System.assert(String.isNotBlank(res));
    }

    @isTest static void getRecordTypeValueReturnsCorrectly() {
        String rtId = LibRecordTypeHelper.getRecordTypeValue('CD_Account');
        String rtDevname = LibRecordTypeHelper.getRecordTypeValue(rtId);

        System.assert(String.isNotBlank(rtId));
        System.assert(String.isNotBlank(rtDevname));
        System.assertEquals('CD_Account', rtDevname);
    }

    @isTest static void getRecordTypeReturnsCorrectly() {
        RecordType res = LibRecordTypeHelper.getRecordType('CD_Account', 'Account');
        System.assertNotEquals(null, res);
    }

    @isTest static void getRecordTypeForObjectsReturnsCorrectly() {
        Map<String, RecordType> res = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Account'});
        System.assert(res.containsKey('CD_Account'));
    }

    @isTest static void getRecordTypeForIdsReturnsCorrectly() {
        Map<Id, RecordType> res = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Account'});
        String cdId = LibRecordTypeHelper.getRecordTypeValue('CD_Account');
        System.assert(res.containsKey(cdId));
    }
      @isTest static void getRecordTypeIdByDeveloperNameReturnsCorrectly() {
        ID recordtypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName('Account','FP_Account');
        System.assert(String.isNotBlank(recordtypeId));
    }

}
