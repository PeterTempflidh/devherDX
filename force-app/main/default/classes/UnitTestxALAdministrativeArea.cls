/**
 * Created by marco.zeuli on 24/8/2017.
 */

@IsTest
private class UnitTestxALAdministrativeArea {
    static final String testPostCode = 'Test_Scenario_PostCode';
    static final String testAdminArea = 'Test_Scenario_AdminArea';
    static final String testAdminAreaLabel = 'Test Scenario AdminArea';
    static final String testLocality = 'Test_Scenario_Locality';
    static final String testSubArea = 'Test_Scenario_SubArea';
    static final String testCountry = 'Test_Scenario_Country';

    static final xAL_AdministrativeArea__mdt record = [
            SELECT MasterLabel,DeveloperName,Code__c,Type__c
            FROM xAL_AdministrativeArea__mdt
            WHERE DeveloperName = :testAdminArea
    ];

    @IsTest static void byNameReturnsCorrectly() {
        xALAdministrativeArea res;

        Test.startTest();

        res = xALAdministrativeArea.byName(testAdminArea);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Code__c, res.code);
        System.assertEquals(record.Type__c, res.type);

        System.assertNotEquals(null, res.localities);
        System.assertEquals(1, res.localities.size());
        System.assertEquals(testLocality, res.localities[0].developerName);

        System.assertNotEquals(null, res.subAdministrativeAreas);
        System.assertEquals(1, res.subAdministrativeAreas.size());
        System.assertEquals(testSubArea, res.subAdministrativeAreas[0].developerName);

        System.assertNotEquals(null, res.postalCodes);
        System.assertEquals(1, res.postalCodes.size());
        System.assertEquals(testPostCode, res.postalCodes[0].developerName);
    }

    @IsTest static void byLabelReturnsCorrectly() {
        xALAdministrativeArea res;

        Test.startTest();

        res = xALAdministrativeArea.byLabel(testAdminAreaLabel);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Code__c, res.code);
        System.assertEquals(record.Type__c, res.type);

        System.assertNotEquals(null, res.localities);
        System.assertEquals(1, res.localities.size());
        System.assertEquals(testLocality, res.localities[0].developerName);

        System.assertNotEquals(null, res.subAdministrativeAreas);
        System.assertEquals(1, res.subAdministrativeAreas.size());
        System.assertEquals(testSubArea, res.subAdministrativeAreas[0].developerName);

        System.assertNotEquals(null, res.postalCodes);
        System.assertEquals(1, res.postalCodes.size());
        System.assertEquals(testPostCode, res.postalCodes[0].developerName);
    }

    @IsTest static void byLabelReturnsNullIfAdminAreaNotExist() {
        xALAdministrativeArea res;

        Test.startTest();

        res = xALAdministrativeArea.byLabel('amazing takeawy experience!!!!');

        Test.stopTest();

        System.assertEquals(null, res);
    }

    @IsTest static void byCountryReturnsCorrectly() {
        List<xALAdministrativeArea> res;

        Test.startTest();

        res = xALAdministrativeArea.byCountry(testCountry);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testAdminArea, res[0].developerName);
    }


}