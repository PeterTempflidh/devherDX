/**
 * Created by g.singh on 29/06/2020.
 */

@IsTest
private class UserSelector_Test {
    static User testUser;

    @TestSetup
    public static void testSetup(){
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'unit.test@user.dh.test','Damejidlo', 'CZ');
        testUser.Email = 'unit.test.user@deliveryhero.com';
        testUser.CommunityNickname = 'testsocialstudioDH';
        testUser.FirstName = 'Social Studio';
        testUser.LastName = 'Account';

        insert testUser;
    }

    @IsTest
    static void testUserSelector() {
        User testUser = [SELECT Id, Email FROM User WHERE Username = 'unit.test@user.dh.test' LIMIT 1];
        UserSelector.findUsersByEmail('unit.test.user@deliveryhero.com');
        //calling method again to cover singleton block
        UserSelector.findUsersByEmail('unit.test.user@deliveryhero.com');
        UserSelector.findUserByEmail('unit.test.user@deliveryhero.com');
        UserSelector.getAllByUserId(new Set<Id> {testUser.Id});
        UserSelector.getSocialApiUser();
        UserSelector.getUsersWithDynamicCondition('Name, Email', 'UserName = \'unit.test@user.dh.test\'');
    }
}