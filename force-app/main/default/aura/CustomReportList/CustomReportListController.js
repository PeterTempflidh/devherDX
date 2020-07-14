({
    openReport: function(cmp,event,helper) {
        helper.toggleReport(cmp, event);
    },

     init: function (cmp, event, helper) {
          var action = cmp.get('c.getReportDefinitionList');
            var self = this;
            action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   var returnValue = response.getReturnValue();
                   cmp.set('v.reportDescriptions', returnValue);
               } else if (state === "ERROR") {
                   var errors = response.getError();
                   if (errors) {
                       if (errors[0] && errors[0].message) {
                           console.log("Error message: " + errors[0].message);
                       }
                   } else {
                       console.log("Unknown error");
                   }
               }
            });
            $A.enqueueAction(action);
 },
})