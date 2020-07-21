/**
 * Created by danish.farooq on 6/3/20.
 */

({
    getSendEmailDetails  : function(component){

        // Prepare the action to load account record
        var action = component.get("c.generateSendEmailDetails");
        action.setParams({"opportunityId" : component.get("v.recordId")});
        action.setCallback(this,function(response){
            //store state of response
            var state = response.getState();
            component.set('v.isLoading', false);
            if (state === "SUCCESS") {
                 //set response value in objClassController attribute on component
                var emailWrapperObj = response.getReturnValue();
                component.set('v.sendEmailObj', emailWrapperObj);
                var errorMessage = '';

                if(emailWrapperObj.toEmailAddress === undefined ||
                    emailWrapperObj.emailBody === undefined){
                    errorMessage = $A.get("$Label.c.Contact_OR_Email_Template_Missing");
                    component.find('notifLib').showToast({
                                                "title": "Error!",
                                                "message": errorMessage,
                                                "variant" : "Error"
                                            });
                    component.set('v.isError',true);
                }
            }
           else if(state === "ERROR"){
                this.showErrorMessage(response.getError(),component);
           }
       });
      $A.enqueueAction(action);
    },

    sendEmailHelper : function(component){

        // Prepare the action to send Email
         component.set('v.isLoading', true);
         var action = component.get("c.sendEmailToContact");
         var emailPropertyWrapper = component.get("v.sendEmailObj.emailWrapperObj");
         var selectedFromEmail = component.get("v.selectedValueFrom");
         if(selectedFromEmail !== ''){
              emailPropertyWrapper.fromAddress = component.get("v.selectedValueFrom");
         }
         emailPropertyWrapper.lstBccContacts = component.get("v.selectedLookUpRecords");

         action.setParams({"emailWrapperJson" : JSON.stringify(emailPropertyWrapper)});
         action.setCallback(this,function(response){
         //store state of response
         var state = response.getState();
         component.set('v.isLoading', false);
            if (state === "SUCCESS") {

                component.find('notifLib').showToast({
                              "title": "Success!",
                              "message": $A.get("$Label.c.Email_Send_Successfully"),
                              "variant" : "Success"
                 });

            }
            else if(state == "ERROR"){
                this.showErrorMessage(response.getError(),component);
            }
        });
       $A.enqueueAction(action);
    },
    showErrorMessage : function(errors,component,errorMessage){
              if(errorMessage === undefined){
                    errorMessage = 'Something went wrong. Please contact your administrator';
              }
              if (errors) {
                if (errors[0] && errors[0].message) {
                  errorMessage = errors[0].message;
                }
            }
            component.find('notifLib').showToast({
                               "title": "Error!",
                               "message": errorMessage ,
                               "variant" : "Error"});
         }
});
