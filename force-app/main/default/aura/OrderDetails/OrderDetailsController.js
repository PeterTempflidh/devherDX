({
    getRecordDetails: function(component,event,helper) {    
        helper.loadinitfunction(component,event,helper); 
		helper.getPlatformNames(component);
    },
    searchOrderDetails: function(component,event,helper){
        component.set("v.loading",true);
        if(component.get("v.searchedOrderNumber")!='' && component.get("v.searchedOrderNumber")!=null && component.get("v.searchedOrderNumber")!=undefined){
            helper.loadinitfunction(component,event,helper);
        }
        else{
            component.set("v.dataPresent",false);
            component.set("v.isError",false);
            var appEvent = $A.get("e.c:OrderDetailsEvent");
            appEvent.setParams({"orderNumber":null,"platformName":null,"country":null,
                                "vendorId":null,"searchedOrderNumber":component.get("v.searchedOrderNumber"),
                                "customerDet":null,"PandoraPlatformNames":component.get("v.PandoraPlatformNames")});
            appEvent.fire();
            component.set("v.loading",false);
        }
    },
    openLink: function(component,event,helper){
        if(event.target.text==component.get("v.searchedOrderNumber")){
            var url=component.get("v.orderURL");
			var platformString = new String(component.get("v.PandoraPlatformNames"));
			var pandoraPlatforms = [];
			pandoraPlatforms = platformString.split(',');
			var isPandoraBackend = (!$A.util.isUndefinedOrNull(component.get("v.platformName")) && pandoraPlatforms.includes(component.get("v.platformName")))?true:false;
            if(isPandoraBackend){
                window.open(url);
            }else if(!isPandoraBackend){
				var workspaceAPI = component.find("orderDetWorkspace");
				workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
					workspaceAPI.openSubtab({
						parentTabId: enclosingTabId,
						url: url,
						focus: true
					}).then((response) => {
						console.log(response);
						   workspaceAPI.setTabLabel({
							  tabId: response,
							  label: $A.get("{!$Label.c.Order_Details}")
						   });
						   workspaceAPI.setTabIcon({
							   tabId: response,
							   icon: "standard:order"
						   });
					}).catch(function(error){
						console.log(error);
					});
				})
				.catch(function(error) {
					console.log(error);
				});
			}
        }
        else{
            var workspaceAPI = component.find("workspace");
            window.open(component.get('v.hurrierLink'));
        }
    },
    getDetails: function(component,event,helper){
        //Add class is is opened slds-is-open

    },
    setPreviousOrder: function(component,event,helper){
        if(event.getParam("recordId")==component.get("v.recordId") && 
           event.getParam("searchedOrderNumber")!=undefined && 
           event.getParam("searchedOrderNumber")!=null && 
           event.getParam("searchedOrderNumber")!=component.get("v.searchedOrderNumber")){
            component.set("v.searchedOrderNumber",event.getParam("searchedOrderNumber"));
            helper.fetchOrder(component,event,helper);
        }
    },
    openArticle: function(component,event,helper){
        var orderStatuses=component.get("v.orderStatus");
        if(orderStatuses[event.target.id].showArticle){
            orderStatuses[event.target.id].showArticle=false;
            component.set("v.orderStatus",orderStatuses);
            var buttonComp=document.getElementById(event.target.id);
            buttonComp.classList.add("rotateClass");
        }
        else{
            orderStatuses[event.target.id].showArticle=true;
            component.set("v.orderStatus",orderStatuses);
            var buttonComp=document.getElementById(event.target.id);
            buttonComp.classList.remove("rotateClass");
        }
    }
})