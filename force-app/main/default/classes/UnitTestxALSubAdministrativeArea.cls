/**
 * Created by marco.zeuli on 24/8/2017.
 */

@IsTest
private class UnitTestxALSubAdministrativeArea {
    static final String testPostCode = 'Test_Scenario_PostCode';
    static final String testAdminArea = 'Test_Scenario_AdminArea';
    static final String testLocality = 'Test_Scenario_Locality';
    static final String testSubArea = 'Test_Scenario_SubArea';

    static final xAL_SubAdministrativeAreas__mdt record = [
            SELECT DeveloperName,MasterLabel,Type__c,Code__c
            FROM xAL_SubAdministrativeAreas__mdt
            WHERE DeveloperName = :testSubArea
    ];

    @IsTest static void byNameReturnsCorrectly() {
        xALSubAdministrativeArea res;

        Test.startTest();

        res = xALSubAdministrativeArea.byName(testSubArea);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Type__c, res.type);
        System.assertEquals(record.Code__c, res.code);

        System.assertNotEquals(null, res.postalCodes);
        System.assertEquals(1, res.postalCodes.size());
        System.assertEquals(testPostCode, res.postalCodes[0].developerName);

        System.assertNotEquals(null, res.localities);
        System.assertEquals(1, res.localities.size());
        System.assertEquals(testLocality, res.localities[0].developerName);
    }

    @IsTest static void byAdministrativeAreaReturnsCorrectly() {
        List<xALSubAdministrativeArea> res;

        Test.startTest();

        res = xALSubAdministrativeArea.byAdministrativeArea(testAdminArea);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testSubArea, res[0].developerName);
    }
}