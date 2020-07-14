/**
 * Created by t.holawala on 15.09.2017.
 */
@isTest
public class UnitTestMultiSelectController {
    static testMethod void testMultiselectController() {
        MultiselectController c = new MultiselectController();

        c.leftOptionsList = new List<SelectOption>();
        c.rightOptionsList = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';

        System.assertEquals(c.leftoptionsList.size(), 3);
        System.assertEquals(c.rightOptionsList.size(), 0);
    }
}