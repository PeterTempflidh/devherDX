/**
 * Created by marco.zeuli on 24/8/2017.
 */

@IsTest
private class UnitTestxALCountry {
    static final String testAdminArea = 'Test_Scenario_AdminArea';
    static final String testCountry = 'Test_Scenario_Country';
    static final String testCountryLabel = 'Test Scenario Country';
    static final String testCountryCode = 'XX';


    static final xAL_Country__mdt record = [
            SELECT MasterLabel,DeveloperName,Code__c
            FROM xAL_Country__mdt
            WHERE DeveloperName = :testCountry
    ];

    @IsTest static  void byLabelReturnsCorrectly() {
        xALCountry res;

        Test.startTest();

        res = xALCountry.byLabel(testCountryLabel);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Code__c, res.code);

        System.assertNotEquals(null, res.adminAreas);
        System.assertEquals(1, res.adminAreas.size());
        System.assertEquals(testAdminArea, res.adminAreas[0].developerName);
    }

    @IsTest static  void byNameReturnsCorrectly() {
        xALCountry res;

        Test.startTest();

        res = xALCountry.byName(testCountry);

        Test.stopTest();

        System.assertEquals(record.DeveloperName, res.developerName);
        System.assertEquals(record.MasterLabel, res.label);
        System.assertEquals(record.Code__c, res.code);

        System.assertNotEquals(null, res.adminAreas);
        System.assertEquals(1, res.adminAreas.size());
        System.assertEquals(testAdminArea, res.adminAreas[0].developerName);
    }

    @IsTest static void byCodesReturnsCorrectly() {
        List<xALCountry> res;

        Test.startTest();

        res = xALCountry.byCodes(new List<String>{testCountryCode});

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(testCountry, res[0].developerName);
    }
}