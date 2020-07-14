({
    doInit: function(component,event,helper){
        component.set("v.isSaving",false);
        helper.getLastCall(component,event,helper);
    },
    saveRec: function(component,event,helper){
        component.set("v.isSaving",true);
        var spinner = component.find("loadingSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        helper.saveRecord(component);
    }
});