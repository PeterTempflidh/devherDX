({
    openTab : function(component, recordId, newTab) {
        var urlRedirect = '';
        if(newTab) {
            urlRedirect = '/apex/VueTerminationPage?id=' + recordId + '&isdtp=vw';
        } else {
            urlRedirect = '/apex/TerminateRestaurant?id=' + recordId; 
        }
                
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                url: urlRedirect, 
                focus: true, 
                label: 'Terminate Restaurant'
            });
        });
    }
})