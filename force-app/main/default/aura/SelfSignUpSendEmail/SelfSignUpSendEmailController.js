/**
 * Created by danish.farooq on 6/3/20.
 */

({
     doInit : function(component, event, helper) {

        helper.getSendEmailDetails(component);

     },

     sendEmail : function(component,event,helper){

        helper.sendEmailHelper(component);

     }
});