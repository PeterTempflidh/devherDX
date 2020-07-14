({
    doInit: function(component,event,helper){
        component.set("v.recordId",component.get("v.pageReference").state.c__recordId);
        component.set("v.loadCriteria",component.get("v.pageReference").state.c__loadCriteria);
        component.set("v.casesIn30Days",component.get("v.pageReference").state.c__casesIn30Days);
        component.set("v.casesForSameOrder",component.get("v.pageReference").state.c__casesForSameOrder);
        helper.getCases(component,event,helper,'init');
        document.title=$A.get("$Label.c.Historical_Cases_Label")+" | Salesforce";
    },
    last30Days: function(component,event,helper){
        if(component.get("v.loadCriteria")!='Do Init'){
            var spinner = component.find("loadingSpinner");
            component.set("v.loadCriteria","Do Init");
            $A.util.toggleClass(spinner, "slds-show");
            helper.getCases(component,event,helper,'initClick');
            $A.util.toggleClass(spinner, "slds-hide");
        }
    },
    casesWithSameOrder: function(component,event,helper){
        if(component.get("v.loadCriteria")!='ordersList'){
            var spinner = component.find("loadingSpinner");
            component.set("v.loadCriteria","ordersList");
            $A.util.toggleClass(spinner, "slds-show");
            helper.getCases(component,event,helper,'sameOrder');
            $A.util.toggleClass(spinner, "slds-hide");
        }
    },
    doRefresh: function(component,event,helper){
        var spinner = component.find("loadingSpinner");
        $A.util.toggleClass(spinner, "slds-show");
        component.set("v.loadCriteria","On Init");
        helper.getCases(component,event,helper,'On Init');
        $A.util.toggleClass(spinner, "slds-hide");
    }
});