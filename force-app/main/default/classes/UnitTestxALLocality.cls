/**
 * Created by marco.zeuli on 24/8/2017.
 */

@IsTest
private class UnitTestxALLocality {
    static final String testPostCode = 'Test_Scenario_PostCode';
    static final String testAdminArea = 'Test_Scenario_AdminArea';
    static final String testParentLocality = 'Test_Scenario_Locality';
    static final String testDependentLocality = 'Test_Scenario_DependentLocality';
    static final String testSubArea = 'Test_Scenario_SubArea';

    static final xAL_Locality__mdt record = [
            SELECT DeveloperName,MasterLabel,Code__c, Type__c
            FROM xAL_Locality__mdt
            WHERE DeveloperName = :testParentLocality
    ];

    @IsTest static void byNameReturnsCorrectly() {
        xALLocality res;

        Test.startTest();

        res = xALLocality.byName(testParentLocality);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Type__c, res.type);
        System.assertEquals(record.Code__c, res.code);
        System.assert(String.isBlank(res.parentLocality));
        System.assertNotEquals(null, res.dependentLocalities);
        System.assertEquals(1, res.dependentLocalities.size());
        System.assertEquals(testDependentLocality, res.dependentLocalities[0].developerName);
        System.assertNotEquals(null, res.postalCodes);
        System.assertEquals(1, res.postalCodes.size());
        System.assertEquals(testPostCode, res.postalCodes[0].developerName);
    }

    @IsTest static void byAdministrativeAreaReturnsCorrectly() {
        List<xALLocality> res;

        Test.startTest();

        res = xALLocality.byAdministrativeArea(testAdminArea);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testParentLocality, res[0].developerName);
    }

    @IsTest static void bySubAdministrativeAreaReturnsCorrectly() {
        List<xALLocality> res;

        Test.startTest();

        res = xALLocality.bySubAdministrativeArea(testSubArea);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testParentLocality, res[0].developerName);
    }

    @IsTest static void byParentLocalityReturnsCorrectly() {
        List<xALLocality> res;

        Test.startTest();

        res = xALLocality.byParentLocality(testParentLocality);


        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testDependentLocality, res[0].developerName);
    }


}