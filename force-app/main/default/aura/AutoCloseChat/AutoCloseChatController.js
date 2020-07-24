({
    onInit : function(component,event,helper){
        console.log('AUTO CLOSE TAB');
    },

    onChatEnded : function(component, event, helper) {
        helper.onChatEnded(component, event);
    },

    onCloseTabButtonPressed : function(component, event, helper) {
        console.log('>......');
    }
})
