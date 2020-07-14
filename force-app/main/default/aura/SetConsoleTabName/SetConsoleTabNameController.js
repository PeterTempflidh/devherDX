({
    onTabFocused: function(component,event,helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            if(response.isSubtab==false && response.recordId.startsWith('570')){
                helper.getChatDetails(component,event,helper,response.recordId,focusedTabId);
            }
        })
    },
    onAgentSend: function(component,event,helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            if(response.isSubtab==false && response.recordId.startsWith('570')){
                helper.getChatDetails(component,event,helper,response.recordId,focusedTabId);
            }
        })
    }
})