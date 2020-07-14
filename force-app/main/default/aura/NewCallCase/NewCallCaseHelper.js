({
    openTab : function(component, recordId) {
        var urlRedirect = '/one/one.app?#/sObject/'+ recordId + '/view';
        console.log('urlRedirect: ' + urlRedirect);
                
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                url: urlRedirect, 
                focus: true, 
                label: 'New Call Case'
            });
        });
    },

    handleCallbackError : function(response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + 
                errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    }
})