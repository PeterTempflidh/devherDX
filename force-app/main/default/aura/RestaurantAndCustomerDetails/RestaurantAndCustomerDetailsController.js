({
    init: function(component,event,helper){
        helper.loadGetRestaurantDetails(component,event,helper);     
    },
	openSubTab: function(component,event,helper){
        var workspaceAPI = component.find("restaurantWorkspace");
        var url='';
        var label='';
        var icon='';
		var isCustomerPandoraLink = false ;
		var platformString = new String(component.get("v.PandoraPlatformNames"));
		var pandoraPlatforms = [];
		pandoraPlatforms = platformString.split(',');
        if(event.target.text==component.get("v.accountDetail.Name") || event.target.text==component.get("v.accountDetail.Restaurant_Name__c")){
            var accId=component.get("v.accountDetail.Id");
            label=event.target.text;
            url='/'+accId;
            icon='standard:account';
        }
        if(event.target.text==(component.get("v.customerDet.first_name")+' '+component.get("v.customerDet.last_name"))){
            label=$A.get("{!$Label.c.Customer_Details}");
            url=component.get("v.customerURL");
            icon='standard:contact';
        }
		 isCustomerPandoraLink = (icon=='standard:contact' && !$A.util.isUndefinedOrNull(component.get("v.platformName")) && pandoraPlatforms.includes(component.get("v.platformName")))?true:false;
        if(isCustomerPandoraLink){
            window.open(url);
        }
        else if(!isCustomerPandoraLink){
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
    }
  });