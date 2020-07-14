({
    handleCallbackError : function(response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message){
                console.log("Error message: " + 
                errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    },

    getCaseDetails: function(component,event,helper){
        var action = component.get("c.getCaseFromChat");
        action.setParams({
            objrecId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                if(retValue!=null && retValue.Values!=null){
                    component.set("v.orderNumber", retValue.Values.Order_Number__c==null?'Not Found':retValue.Values.Order_Number__c);
                    component.set("v.customerName", retValue.Values.Customer_Name__c==null?'Not Found':retValue.Values.Customer_Name__c);
                    component.set("v.customerId", retValue.Values.Customer_Id__c==null?'Not Found':retValue.Values.Customer_Id__c);
					component.set("v.platformName",retValue.Values.Platform__c);
                    helper.fetchLinks(component,event,helper,retValue.Values.Platform__c,retValue.Values.Country__c);
                }
            }else if (state === "ERROR") {
                helper.handleCallbackError(response);
            }
        });
        $A.enqueueAction(action);
    },

    fetchLinks: function(component,event,helper,platformValue,countryValue){
        var getHurrierLink = component.get("c.getLinks");
        getHurrierLink.setParams({platform:platformValue,country:countryValue,deliveryType:''});
        getHurrierLink.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultMap=response.getReturnValue();
                //Fetching order details link
                if(resultMap.OrderDetails!='Not Found'){
                    var orderNumber=component.get("v.orderNumber")==null?'':component.get("v.orderNumber");
                    var orderUrl=resultMap.OrderDetails+orderNumber;
                    component.set("v.orderNumberURL",orderUrl);
                }
                if(resultMap.CustomerDetails!='Not Found'){
                    var customerId=component.get("v.customerId")==null?'':component.get("v.customerId");
                    var customerURL=resultMap.CustomerDetails+customerId;
                    component.set("v.customerIdURL",customerURL);
                }
            }
        });
        $A.enqueueAction(getHurrierLink);
    },

    openSubtab: function(component,url,label,icon){
		var platformString = new String(component.get("v.PandoraPlatformNames"));
		var pandoraPlatforms = [];
		pandoraPlatforms = platformString.split(',');
		var isPandoraBackend = (!$A.util.isUndefinedOrNull(component.get("v.platformName")) && pandoraPlatforms.includes(component.get("v.platformName")))?true:false;
        if(isPandoraBackend){
            window.open(url);
        }
        else if (!isPandoraBackend){
			var workspaceAPI = component.find("oneViewWorkspace");
			workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
				workspaceAPI.openSubtab({
					parentTabId: enclosingTabId,
					url: url,
					focus: true
				}).then((response) => {
					   workspaceAPI.setTabLabel({
						  tabId: response,
						  label: label
					   });
					   workspaceAPI.setTabIcon({
						   tabId: response,
						   icon: icon
					   });
				}).catch(function(error){
					console.log(error);
				});
			})
			.catch(function(error) {
				console.log(error);
			});
		}
    },
	 getPandoraPlatforms:function(component){
        var path = $A.get("$Resource.OrderDetailPandoraPlatformNames");
        var req = new XMLHttpRequest();
        req.open("GET", path);
        req.addEventListener("load", $A.getCallback(function() {
            component.set("v.PandoraPlatformNames", req.response);
           
        }));
        req.send(null);        
    }
})