({
    onInit : function(component,event,helper){
    },

    onChatEnded : function(component, event, helper) {
        helper.onChatEnded(component, event);
    },

    onCloseTabButtonPressed : function(component, event, helper) {
        component.set('v.showCloseModal', false);
        helper.closeTabButtonPressed(component);
    },

    onCancelButtonPressed : function(component, event, helper) {
        component.set('v.showCloseModal', false); 
    }    
})
