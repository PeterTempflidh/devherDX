({
    openTab : function(component, event,helper, focus) {
        //Invoke the Lightning Page and open as a sub tab
        var workspaceAPI = component.find("workspace");
       
        
       workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {          
           workspaceAPI.openSubtab({              
               pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__OrderHistoryMaster"                        
                    },
                    "state": {                        
                        "c__paramRec": component.get("v.recordId") ,
                        "c__paramsObjName": component.get("v.sObjectName")                     
                    }
                }
            }).then(function(tabId) {                               
				
				workspaceAPI.setTabLabel({
					tabId: tabId,
					label: $A.get("{!$Label.c.OrderHistoryComponentTabName}")
				});
				workspaceAPI.setTabIcon({
					tabId: tabId,
					icon: "custom:custom33",
					iconAlt: $A.get("{!$Label.c.OrderHistoryComponentTabName}")
				});
			}).catch(function(error) {
                console.log("@@error",JSON.stringify(error));
            });
           
        })
      
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