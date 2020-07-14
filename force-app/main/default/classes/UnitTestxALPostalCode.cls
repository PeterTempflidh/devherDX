@isTest
private class UnitTestxALPostalCode {

    static final String testPostCode = 'Test_Scenario_PostCode';
    static final String testAdminArea = 'Test_Scenario_AdminArea';
    static final String testLocality = 'Test_Scenario_Locality';
    static final String testSubArea = 'Test_Scenario_SubArea';

            static final xAL_PostalCode__mdt record = [
            SELECT DeveloperName,MasterLabel,Number__c
            FROM xAL_PostalCode__mdt
            WHERE DeveloperName = :testPostCode
    ];

    @isTest static void byNameReturnsCorrectly() {
        xALPostalCode res;

        Test.startTest();

        res = xALPostalCode.byName(testPostCode);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Number__c, res.value);
    }

    @isTest static void byAdministrativeAreaReturnsCorrectly() {
        List<xALPostalCode> res;

        Test.startTest();

        res = xALPostalCode.byAdministrativeArea(testAdminArea);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(record.DeveloperName, res[0].developerName);
    }

    @IsTest static void byLocalityReturnsCorrectly() {
        List<xALPostalCode> res;

        Test.startTest();

        res = xALPostalCode.byLocality(testLocality);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(record.DeveloperName, res[0].developerName);
    }

    @IsTest static void bySubAdministrativeAreaReturnsCorrectly() {
        List<xALPostalCode> res;

        Test.startTest();

        res = xALPostalCode.bySubAdministrativeArea(testSubArea);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(record.DeveloperName, res[0].developerName);
    }
}