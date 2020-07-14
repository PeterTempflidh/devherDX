({    
    loadGetRestaurantDetails:  function(component,event,helper){
       if(event.getParam("recordId")==component.get("v.recordId") 
           && event.getParam("vendorId")!=undefined && event.getParam("vendorId")!=null
           && event.getParam("vendorId")!=''){
            component.set("v.dataPresent",true);
            component.set("v.vendorId",event.getParam("vendorId"));
			 component.set("v.platformName",event.getParam("platformName"));
			 component.set("v.PandoraPlatformNames",event.getParam("PandoraPlatformNames"));
            var action = component.get("c.fetchRestaurantDetails");
            action.setParams({ vendorId : event.getParam("vendorId"),
                              platform:event.getParam("platformName") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   component.set("v.accountDetail",response.getReturnValue().account);
                }
            });
            $A.enqueueAction(action);            
            helper.setCustomerdata(component,event,helper);
        }
        else if(event.getParam("recordId")==component.get("v.recordId")
                && (event.getParam("vendorId")=='' || event.getParam("vendorId")==undefined
                || event.getParam("vendorId")==null)){
            component.set("v.accountDetail",'');
            component.set("v.vendorId",'');
            component.set("v.dataPresent",false);
        }  
    },   
    //This can be refined further
    setCustomerdata : function(component,event,helper){

        if(event.getParam("recordId")==component.get("v.recordId")
           && event.getParam("customerDet")!=undefined && event.getParam("customerDet")!=null){
            component.set("v.customerURL",event.getParam("customerURL"));
            var customerDetails=event.getParam("customerDet");
            if(customerDetails!=undefined && customerDetails!=null){
                if(customerDetails.profile!=null && customerDetails.profile!=undefined){
                    component.set("v.customerDet",customerDetails.profile);
                }
                if(customerDetails.customer_id!=null &&
                   customerDetails.customer_id!=undefined){
                    component.set("v.dataPresent",true);
                }
                else{
                    component.set("v.dataPresent",false);
                }
            }
            else{
                component.set("v.dataPresent",false);
            }
        }
        else if(event.getParam("recordId")==component.get("v.recordId")
                && (event.getParam("customerDet")=='' || event.getParam("customerDet")==undefined
                || event.getParam("customerDet")==null)){
            component.set("v.dataPresent",false);
        }
    }
});