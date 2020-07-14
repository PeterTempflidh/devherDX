({
    init: function(component,event,helper){
        helper.setData(component,event,helper);
    },
    captureClick: function(component,event,helper){
		component.set("v.showSpinner",true);
        var appEvent = $A.get("e.c:OrderDetailsEvent");
        appEvent.setParams({"searchedOrderNumber":event.target.text,"recordId":component.get("v.recordId")});
        appEvent.fire();
    }
});