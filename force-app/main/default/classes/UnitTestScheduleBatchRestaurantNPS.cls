@isTest
private class UnitTestScheduleBatchRestaurantNPS   {
  private static User runningUser  = UnitTestDataFactory.createUser('FI Sales Management', 'fi_au@deliveryhero.com', 'FI', 'FI');
  private static User runningUserCD  = UnitTestDataFactory.createUser('CD Sales Management', 'fi_cd@deliveryhero.com', 'CD', 'CD');
  private static Account acc_fi;
  private static Country__c c_fi;
  private static Account acc;
  public static String CRON_EXP = '0 0 0 15 3 ? 2022';


  static {
    UnitTestDataFactory.getRecordtypeValues();
    insert runningUser;
    List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
    platformCountry.add(new Platform_Country__c(name = 'FinlandPlatform', country__c = 'Finland'));
    platformCountry.add(new Platform_Country__c(name = 'clickdelivery.com.pe', country__c = 'Peru'));
    insert platformCountry;

    Country__c c = UnitTestDataFactory.createCountry('CD', 'PERU', 'PEN');
    c_fi = UnitTestDataFactory.createCountry('FI', 'Finland', 'EUR');

    Company__c com = UnitTestDataFactory.createCompany('ClickDelivery Peru', 'CD', c);
    Company__c com_fi = UnitTestDataFactory.createCompany('PizzaOnline_FI', 'FI', c_fi);
    insert new List<sObject> {c, c_fi, com, com_fi};


    System.runAs(runningUser) {
      acc_fi = UnitTestDataFactory.createAccount('TestAccount', c_fi, 'FI_Account');

      insert new List<sObject> {acc_fi};
      acc_fi.backend_email__c = 'test@test.com';
      acc_fi.online_status_backend__C = 'Online';
      acc_fi.Online_Since__c = Datetime.newInstance(2014, 5, 8, 16, 17, 25);
      update acc_fi;

    }
    System.runAs(runningUserCD) {
      acc = UnitTestDataFactory.createAccount('TestAccountCD', c, 'CD_Account');

      insert new List<sObject> {acc};
      acc.backend_email__c = 'test@test.com';
      acc.online_status_backend__C = 'Online';
      acc.Online_Since__c = Datetime.newInstance(2014, 5, 8, 16, 17, 25);
      acc.Type = 'Branch';
      update acc;
      contact con = new contact( lastname = 'test', email = 'test@test.com', AccountId = acc.Id, Contact_Role__c = 'Owner', RecordTypeId = '012w0000000R07SAAS');
      insert con;
    }
  }
  // CRON expression: midnight on March 15.
  // Because this is a test, job executes
  // immediately after Test.stopTest().


  static testmethod void test() {

    List<RestaurantNPSEmail__c> resNPS = new List<RestaurantNPSEmail__c>();
    resNPS.add(new RestaurantNPSEmail__c(name = 'FI_Account', RecordTypeId__c = '012w0000000kc07', EmailFieldAPI__c = 'backend_email__c', OrgWideAddress__c = '0D2w0000000fxX6', EmailTemplateId__c = '00Xw0000002IvzP'));

    insert resNPS;
    List<RestaurantNPSEmail__c> resNPSCD = new List<RestaurantNPSEmail__c>();
    resNPSCD.add(new RestaurantNPSEmail__c(name = 'Peru', RecordTypeId__c = '012w0000000R07JAAS', EmailFieldAPI__c = 'backend_email__c', OrgWideAddress__c = '0D2w0000000fxX6', EmailTemplateId3months__c = '00Xw0000001Ofd3'));

    insert resNPSCD;
    Test.startTest();

    // Schedule the test job
    String jobId = System.schedule('ScheduleApexClassTest',
                                   CRON_EXP,
                                   new ScheduleBatchRestaurantNPS());

    // Get the information from the CronTrigger API object
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                      NextFireTime
                      FROM CronTrigger WHERE id = :jobId];

    // Verify the expressions are the same
    System.assertEquals(CRON_EXP,
                        ct.CronExpression);
    System.assertEquals(0, ct.TimesTriggered);
    System.assertEquals('2022-03-15 00:00:00',
                        String.valueOf(ct.NextFireTime));

    Test.stopTest();


  }


}