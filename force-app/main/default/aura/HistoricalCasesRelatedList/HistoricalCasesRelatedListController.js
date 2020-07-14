({
    doInit: function(component,event,helper){
        if(component.get("v.loadCriteria")!='On Init'){
            var spinner = component.find("loadingSpinner");
            component.set("v.loadCriteria","On Init");
            $A.util.toggleClass(spinner, "slds-show");
            helper.getCases(component,event,helper);
            $A.util.toggleClass(spinner, "slds-hide");
        }
    },
    loadInit: function(component,event,helper){
        if(component.get("v.loadCriteria")!='Do Init'){
            var spinner = component.find("loadingSpinner");
            component.set("v.loadCriteria","Do Init");
            $A.util.toggleClass(spinner, "slds-show");
            helper.getCases(component,event,helper);
            $A.util.toggleClass(spinner, "slds-hide");
        }
    },
    loadOrdersList: function(component,event,helper){
        if(component.get("v.loadCriteria")!='ordersList'){
            var spinner = component.find("loadingSpinner");
            component.set("v.loadCriteria","ordersList");
            $A.util.toggleClass(spinner, "slds-show");
            helper.getCases(component,event,helper);
            $A.util.toggleClass(spinner, "slds-hide");
        }
    },
    doRefresh: function(component,event,helper){
        var spinner = component.find("loadingSpinner");
        $A.util.toggleClass(spinner, "slds-show");
        component.set("v.loadCriteria","On Init");
        helper.getCases(component,event,helper);
        $A.util.toggleClass(spinner, "slds-hide");
    },
    openTabWithSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__HistoricalCases"
                        },
                        "state": {
                            "c__recordId": component.get("v.recordId"),
                            "c__loadCriteria": component.get("v.loadCriteria"),
                            "c__casesIn30Days": component.get("v.casesIn30Days"),
                            "c__casesForSameOrder": component.get("v.casesForSameOrder")
                        }
                    },
                    focus: true
                }).then((response) => {
                       workspaceAPI.setTabLabel({
                          tabId: response,
                          label: $A.get("$Label.c.Historical_Cases_Label")
                       });
                       workspaceAPI.setTabIcon({
                           tabId: response,
                           icon: "standard:case"
                       });
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
});