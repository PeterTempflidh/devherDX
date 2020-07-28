public with sharing class AutoCloseChatController {
    /*
    * returns the intervals for the AutoCloseChat component
    * Order:
    *
    * Popup active modal
    * Close modal
    * Wait until inactive tab is closed
    */
    @AuraEnabled
    public static Integer[] getTimes() {
        Integer[] tm = new Integer[]{3000, 5000, 8000};
        return tm;
    }
}
