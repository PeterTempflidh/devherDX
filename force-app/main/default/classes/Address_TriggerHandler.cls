/**
* @author Sarfaraz Ahmed
* @date 19.03.2020
*
* @description Handler class for Address trigger
*/

public class Address_TriggerHandler implements ITrigger {

    /**
    * @date     : [05/04/2020]
    * @method name  : bulkBefore
    * @description  : Logic to check before update
    */
    public void bulkBefore() {

    }

    /**
    * @date      [05/04/2020]
    * @method name   bulkAfter
    * @description   Logic to check after insert
    */
    public void bulkAfter() {
        if (Trigger.isInsert) {
            TrgAddressDetailProcessor.updateKitchenAddressWhenFacltyAddessIsUpdated(Trigger.New,null); //SSC-335
        }
        if (Trigger.isUpdate) {
            TrgAddressDetailProcessor.updateKitchenAddressWhenFacltyAddessIsUpdated(Trigger.New,(Map<Id, AddressDetail__c >) Trigger.oldMap); //SSC-335
        }
    }

    /**
    * @date      [05/04/2020]
    * @method name   beforeInsert
    * @description   Logic to check before insert
    * @param         SObject so
    */
    public void beforeInsert(SObject so) {
    }

    /**
    * @date      [05/04/2020]
    * @method name   beforeUpdate
    * @description   Logic to check before update
    * @param         SObject oldSo, SObject so
    */
    public void beforeUpdate(SObject oldSo, SObject so) {
    }

    /**
    * @date     : [05/04/2020]
    * @method name  : beforeDelete
    * @description  : Logic to check before delete
    * @param         SObject so,
    */
    public void beforeDelete(SObject so) {
    }

    /**
    * @date      [05/04/2020]
    * @method name   afterInsert
    * @description   Logic to check after insert
    * @param         SObject so
    */
    public void afterInsert(SObject so) {
    }

    /**
   * @date      [05/04/2020]
   * @method name   afterUpdate
   * @description   Logic to check after update
   * @param         SObject oldSo, SObject so
   */
    public void afterUpdate(SObject oldSo, SObject so) {
    }

    /**
    * @date     : [05/04/2020]
    * @method name  : afterDelete
    * @description  : Logic to check after code
    * @param        : SObject so
    */
    public void afterDelete(SObject so) {
    }

    /**
   * @date     : [05/04/2020]
   * @method name  : andFinally
   * @description  : Logic to check finally code
   */
    public void andFinally() {
    }
}