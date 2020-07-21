/**
 * Created by danish.farooq on 6/6/20.
 */
({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method
        var action = component.get("c.fetchLookUpValues");
         // set param to method
        var params = this.getParameters(component,getInputkeyWord);
        action.setParams({'jsonString': JSON.stringify(params) });

        // set a callBack
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.
                if (storeResponse.length === 0) {
                    component.set("v.message", 'No Records Found...');
                } else {
                    component.set("v.message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            else if(state === "ERROR"){
                this.showErrorMessage(response.getError(),component);
            }
        });
        // enqueue the Action
        $A.enqueueAction(action);
    },
    getParameters : function(component,getInputkeyWord)
    {
        return {
              'searchKeyWord': getInputkeyWord,
              'objectName' : component.get("v.objectAPIName"),
              'excludedItemLst' : component.get("v.lstSelectedRecords"),
              'fieldToQuery' : component.get("v.fieldToQuery")
        };
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
})

