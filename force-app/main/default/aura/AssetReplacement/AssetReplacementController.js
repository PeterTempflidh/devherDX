({  
    toggleSpinner : function(component,event,helper){
        helper.toggleSpinner(component);
    },
    
    closeJs : function(c, e, h) {
      	$A.get("e.force:closeQuickAction").fire();  
    },
    
    openAccount : function(c, e, h) {
        h.openTab(c, c.get("v.vendor").Id);
    },
    
    openOldAsset : function(c, e, h) {
        h.openTab(c, c.get("v.recordId"));
    },
    
    openNewAsset : function(c, e, h) {
        h.openTab(c, c.get("v.newAsset").Id);
    },
    
    init : function (c, e, h) {
        var assetId = c.get("v.recordId");

        var action = c.get("c.getCurrentData");
        action.setParams({ assetIdString : assetId });
	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                
                c.set('v.vendor',JSON.parse(retValue.Values.Account));
                c.set('v.oldAsset', retValue.Values);
                c.set('v.done', retValue.Values.Status == "Return In Progress");
                c.set('v.newAsset', JSON.parse(retValue.Values.NewAsset));
                
                if($A.get('e.force:refreshView')) {
                    $A.get('e.force:refreshView').fire();
                }
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                h.handleCallbackError(response);
            }
        });

        $A.enqueueAction(action);
    },
    
	startReplacementJs: function(c, e, h)  {
    	c.set('v.started',true);
        var assetId = c.get("v.recordId");

        var action = c.get("c.startReplacement");
        action.setParams({ assetIdString : assetId });
	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                
                if(retValue.Success) {
                    c.set('v.vendor', JSON.parse(retValue.Values.Account));
                    c.set('v.oldAsset', retValue.Values);
                    c.set('v.newAsset', JSON.parse(retValue.Values.NewAsset));
                    
                    if($A.get('e.force:refreshView')) {
                        $A.get('e.force:refreshView').fire();
                    }
                    
                    c.find('notificationsLibrary').showToast( {
                        "message": retValue.UserMessage,
                        "variant": "success"
                    });
                    c.set('v.done',true);
                } else {
                    c.find('notificationsLibrary').showToast( {
                        "message": retValue.UserMessage,
                        "variant": "error"
                    });
                    c.set('v.done',false);
                }
                
                c.set('v.started',false);                
            }
            else if (state === "INCOMPLETE") {
                
            }
            else if (state === "ERROR") {
                h.handleCallbackError(response);
            }
        });

        $A.enqueueAction(action);
    }
})