({
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
    },
    loadinitfunction:function(component,event,helper){
    	component.set('v.columns', [{label: $A.get("$Label.c.Item_Name"), 
                                     fieldName: 'name', type: 'text'},{label: $A.get("$Label.c.Quantity"), 
                                     fieldName: 'quantity', type: 'text'},{label: $A.get("$Label.c.Unit_Price"), 
                                     fieldName: 'unit_price', type: 'text'}]);
        var chatId ;     
        chatId = component.get("v.recordId");
        var initLoad = component.get("c.getCaseFromChat");
        initLoad.setParams({ objrecId : chatId });
        initLoad.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = JSON.parse(response.getReturnValue());
                //Fetch and assign values from related case on load.
                component.set("v.orderNumber", retValue.Values.Order_Number__c);
                component.set("v.platformName", retValue.Values.Platform__c);
                component.set("v.country", retValue.Values.Country__c);
                component.set("v.paymentMethodOnCase", retValue.Values.Partial_Refund_Type__c);
                if(component.get("v.searchedOrderNumber")==null){
                    component.set("v.searchedOrderNumber",component.get("v.orderNumber"));
                }
                if(component.get("v.sObjectName") == 'LiveChatTranscript'){
                    component.set("v.caseRecId",retValue.Id);
                   
                }else if (component.get("v.sObjectName") == 'Case'){
                    component.set("v.caseRecId",component.get("v.recordId"));
                } 
                helper.fetchOrder(component,event,helper);
             
            }else if (state === "ERROR") {
                helper.handleCallbackError(response);
                component.set("v.loading",false);
            }
        });
        $A.enqueueAction(initLoad); 
	},
    fetchOrder: function(component,event,helper){
        var getOrderDetails = component.get("c.fetchOrder");
        getOrderDetails.setParams({orderId: component.get("v.searchedOrderNumber"),
                                   platform:component.get("v.platformName"),
                                   country:component.get("v.country") });
        getOrderDetails.setCallback(this, function(response) {
            var state = response.getState();
         
            if(state === "SUCCESS"){
               if(component.get("v.searchedOrderNumber")!=null && 
                   component.get("v.searchedOrderNumber")!=undefined && 
                   component.get("v.searchedOrderNumber")!=''){
                   
                   component.set("v.isError",response.getReturnValue().isError);                  
                   if(response.getReturnValue()!=undefined &&
                      response.getReturnValue()!=null){
                        component.set("v.dataPresent",true);
                        //If Error, show error and set event attributes as blank
                        if(response.getReturnValue().isError){
                            component.set("v.isDisabled",true);
                            component.set("v.errorMessage",response.getReturnValue().errorMessage);
                            var appEvent = $A.get("e.c:OrderDetailsEvent");
                            appEvent.setParams({"orderNumber":"","platformName":"","country":"",
                                                "vendorId":"","customerDet":"",
                                                "searchedOrderNumber":component.get("v.searchedOrderNumber"),
                                                "recordId":component.get("v.recordId"),"PandoraPlatformNames":component.get("v.PandoraPlatformNames")});
                            appEvent.fire();
                            component.set("v.loading",false);
                        }
                        else{
                            var obj=[];
                            obj=JSON.parse(response.getReturnValue().result);
                            component.set("v.orderDetails",obj.data);
                            var recentStatus='';
                            var orderDet=[];
                            var orderStatuses=[];
                            var eta;
                            var dataList=[];
                            var data=[];
                            if(component.get("v.orderDetails")!=null){
                                orderDet=component.get("v.orderDetails")[0];
                            }
                            if(orderDet!=undefined){                               
                                 /**SCC-40: Call update on Payment Method on Case only 
                                 * 1. if the payment method is not already populated on Case
                                 * 2. The searched order number is same as order number on Case. This is needed as the update on Case is called as a consecutive call after call to Data Fridge.
                                 *    Hence, needed to avoid the call if different order number is searched
                                 **/ 
                                let payMethodReq = $A.util.isEmpty(component.get("v.paymentMethodOnCase")) && !$A.util.isEmpty(orderDet.order.customer.payment.payment_method) 
                                && (!$A.util.isEmpty(component.get("v.searchedOrderNumber")!=null && component.get("v.searchedOrderNumber") == component.get("v.orderNumber")) );
                                
                                if(payMethodReq){
                                    this.savePaymentType(component,component.get("v.caseRecId"),orderDet.order.customer.payment.payment_method);
                                }
                                
                                orderStatuses=orderDet.order_statuses;
                                for(var i=0;i<orderStatuses.length;i++){
                                    //Capturing Rejected Flag to set styling if order status is Rejected, Failed, Expired, Cancelled
                                    if(orderStatuses[i].status == 'REJECTED' || orderStatuses[i].status == 'FAILED' || orderStatuses[i].status == 'EXPIRED' || orderStatuses[i].status == 'CANCELLED'){
                                        orderStatuses[i].isRejected = true;
                                    }
                                    else if(orderStatuses[i].status == 'DELAYED'){
                                        orderStatuses[i].isDelayed = true;
                                    }
                                    else{
                                        orderStatuses[i].isRejected = false;
                                        orderStatuses[i].isDelayed = false;
                                    }

                                    //Translating Dates to a more user friendly format
                                    if(orderStatuses[i].status == 'ACCEPTED'){
                                        orderStatuses[i].accepted.estimated_delivery_time = new Date(orderStatuses[i].accepted.estimated_delivery_time).toLocaleDateString()+' '+new Date(orderStatuses[i].accepted.estimated_delivery_time).toLocaleTimeString();
                                        eta=orderStatuses[i].accepted.estimated_delivery_time;
                                    }
                                    if(orderStatuses[i].timestamp!=undefined && orderStatuses[i].timestamp!=null){
                                        orderStatuses[i].timestamp = new Date(orderStatuses[i].timestamp).toLocaleDateString()+' '+new Date(orderStatuses[i].timestamp).toLocaleTimeString();
                                    }
                                    if(orderStatuses[i].picked_up!=undefined && orderStatuses[i].picked_up!=null && orderStatuses[i].picked_up.timestamp!=undefined && orderStatuses[i].picked_up.timestamp!=null){
                                        orderStatuses[i].picked_up.timestamp = new Date(orderStatuses[i].picked_up.timestamp).toLocaleDateString()+' '+new Date(orderStatuses[i].picked_up.timestamp).toLocaleTimeString();
                                    }
                                    if(orderStatuses[i].delivered!=undefined && orderStatuses[i].delivered!=null && orderStatuses[i].delivered.timestamp!=undefined && orderStatuses[i].delivered.timestamp!=null){
                                        orderStatuses[i].delivered.timestamp = new Date(orderStatuses[i].delivered.timestamp).toLocaleDateString()+' '+new Date(orderStatuses[i].delivered.timestamp).toLocaleTimeString();
                                    }
                                    if(orderStatuses[i].delayed!=undefined && orderStatuses[i].delayed!=null && orderStatuses[i].delayed.estimated_time!=undefined && orderStatuses[i].delayed.estimated_time!=null){
                                        orderStatuses[i].delayed.estimated_time = new Date(orderStatuses[i].delayed.estimated_time).toLocaleDateString()+' '+new Date(orderStatuses[i].delayed.estimated_time).toLocaleTimeString();
                                    }
                                    orderStatuses[i].showArticle=false;
                                }
                                orderStatuses=orderStatuses.sort((a, b) => (a.timestamp > b.timestamp) ? -1 : 1);
                                component.set("v.orderStatus",orderStatuses);
                                if(orderDet.order.order.items!=undefined && orderDet.order.order.items.length>0){
                                    //Creating tree grid for Order Items
                                    for(var i=0;i<orderDet.order.order.items.length;i++){
                                        data=[];
                                        data.name=orderDet.order.order.items[i].name;
                                        data.quantity=orderDet.order.order.items[i].quantity.toString();
                                        data.unit_price=orderDet.order.order.items[i].unit_price.toString();
                                        data._children=[];
                                        if(orderDet.order.order.items[i].options!=undefined && orderDet.order.order.items[i].options.length>0){
                                            for(var j=0;j<orderDet.order.order.items[i].options.length;j++){
                                                 data._children.push({"name":orderDet.order.order.items[i].options[j].name,
                                                                     "quantity":(!$A.util.isUndefinedOrNull(orderDet.order.order.items[i].options[j].quantity))?orderDet.order.order.items[i].options[j].quantity.toString():"",
                                                                     "unit_price":(!$A.util.isUndefinedOrNull(orderDet.order.order.items[i].options[j].unit_price))?orderDet.order.order.items[i].options[j].unit_price.toString():""});
                                            }
                                        }
                                        dataList.push(data);
                                    }
                                    component.set("v.data",dataList);
                                }
                            }

                            component.set("v.orderValue",orderDet.order.order.order_value);
                            if(orderStatuses[0]!=null && orderStatuses[0]!=undefined && orderStatuses[0].status!=null && orderStatuses[0].status!=undefined){
                                component.set("v.recentOrderStatus",orderStatuses[0].status);
                                component.set("v.isRecentStatusRejected",orderStatuses[0].isRejected);
                                component.set("v.isRecentStatusDelayed",orderStatuses[0].isDelayed);
                            }
                            else{
                                component.set("v.recentOrderStatus","");
                            }
                            component.set("v.coupons",(!$A.util.isUndefinedOrNull(orderDet.order.customer.payment) && !$A.util.isUndefinedOrNull(orderDet.order.customer.payment.coupon))?orderDet.order.customer.payment.coupon:null);
                            component.set("v.customerId",!$A.util.isUndefinedOrNull(orderDet.order.customer.customer_id)?orderDet.order.customer.customer_id:'');
                            component.set("v.platform",!$A.util.isUndefinedOrNull(orderDet.order.brand_name)?orderDet.order.brand_name:'');
                            component.set("v.address",(!$A.util.isUndefinedOrNull(orderDet.order.delivery.location) && !$A.util.isUndefinedOrNull(orderDet.order.delivery.location.address_text))?orderDet.order.delivery.location.address_text:'');
                            component.set("v.discount",(!$A.util.isUndefinedOrNull(orderDet.order.customer.payment) && !$A.util.isUndefinedOrNull(orderDet.order.customer.payment.discount))?orderDet.order.customer.payment.discount:null);
                            component.set("v.vendorId",!$A.util.isUndefinedOrNull(orderDet.order.vendor.id)?orderDet.order.vendor.id:'');
                            component.set("v.vendorName",!$A.util.isUndefinedOrNull(orderDet.order.vendor.name)?orderDet.order.vendor.name:'');
							if(!$A.util.isUndefinedOrNull(orderDet.order.corporate)){
                                component.set("v.corporateFlag",orderDet.order.corporate);
                            }
                            component.set("v.paymentMethod",(!$A.util.isUndefinedOrNull(orderDet.order.customer.payment) && !$A.util.isUndefinedOrNull(orderDet.order.customer.payment.payment_method))?orderDet.order.customer.payment.payment_method:'');
							component.set("v.paymentProvider",(!$A.util.isUndefinedOrNull(orderDet.order.customer.payment) && !$A.util.isUndefinedOrNull(orderDet.order.customer.payment.payment_provider))?orderDet.order.customer.payment.payment_provider:'');
							component.set("v.deliveryType",orderDet.order.delivery.provider.indexOf('_')>0?orderDet.order.delivery.provider.replace('_',' '):orderDet.order.delivery.provider);
                            if(orderDet.order.customer.payment.paid){
                                component.set("v.paymentStatus",'Accepted');
                            }
                            else{
                                component.set("v.paymentStatus",'Rejected');
                            }
                            var promisedDeliveryTime = new Date(orderDet.order.promised_customer_timestamp).toLocaleDateString()+' '+new Date(orderDet.order.promised_customer_timestamp).toLocaleTimeString();
                            component.set("v.eta",promisedDeliveryTime);
                            component.set("v.customerDetails",orderDet.order.customer);
                            component.find("itemsTable").expandAll();
                            helper.fetchLinks(component,event,helper);
                        }
                    }
                    else{
                        component.set("v.dataPresent",false);
                        var appEvent = $A.get("e.c:OrderDetailsEvent");
                        appEvent.setParams({"orderNumber":null,"platformName":null,"country":null,
                                            "vendorId":null,
                                            "searchedOrderNumber":component.get("v.searchedOrderNumber"),
                                            "customerDet":null,"recordId":component.get("v.recordId"),"PandoraPlatformNames":component.get("v.PandoraPlatformNames")});
                        appEvent.fire();
                        component.set("v.loading",false);
                    }
                }
                else{
                    component.set("v.isDisabled",true);
                    component.set("v.loading",false);
                }
            }
            else{
                component.set("v.isDisabled",true);
                component.set("v.dataPresent",false);
                var appEvent = $A.get("e.c:OrderDetailsEvent");
                appEvent.setParams({"orderNumber":null,"platformName":null,"country":null,
                                    "vendorId":null,
                                    "searchedOrderNumber":component.get("v.searchedOrderNumber"),
                                    "customerDet":null,"recordId":component.get("v.recordId"),"PandoraPlatformNames":component.get("v.PandoraPlatformNames")});
                appEvent.fire();
                component.set("v.loading",false);
            }
        });
        $A.enqueueAction(getOrderDetails);
    },
    fetchLinks: function(component,event,helper){
        var deliveryType=component.get("v.deliveryType");
        var isHurrier=false;
        var customerURL=null;
        var getHurrierLink = component.get("c.getLinks");
        getHurrierLink.setParams({platform:component.get("v.platformName"),country:component.get("v.country"),deliveryType:deliveryType});
        getHurrierLink.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultMap=response.getReturnValue();
                console.log(resultMap);
                //Fetching hurrier link
                if(resultMap.HurrierDetails!='Not Found'){
                    var hurrierLink=resultMap.HurrierDetails+component.get("v.searchedOrderNumber");
                    component.set("v.hurrierLink",hurrierLink);
                    component.set("v.isDisabled",false);
                }
                else{
                    component.set("v.isDisabled",true);
                }
                //Fetching order details link
                if(resultMap.OrderDetails!='Not Found'){
                    var orderUrl=resultMap.OrderDetails+component.get("v.searchedOrderNumber");
                    component.set("v.orderURL",orderUrl);
                }
                else{
                    component.set("v.orderURL",null);
                }
                if(resultMap.CustomerDetails!='Not Found'){
                    customerURL=resultMap.CustomerDetails+component.get("v.customerId");
                }
            }
            else{
                component.set("v.orderURL",null);
                component.set("v.isDisabled",true);
            }
            //Assigning attribute values to event
            var appEvent = $A.get("e.c:OrderDetailsEvent");
            appEvent.setParams({"orderNumber":component.get("v.orderNumber"),"platformName":component.get("v.platformName"),"country":component.get("v.country"),"vendorId":component.get("v.vendorId"),"customerDet":component.get("v.customerDetails"),"searchedOrderNumber":component.get("v.searchedOrderNumber"),"customerURL":customerURL,"recordId":component.get("v.recordId"),"PandoraPlatformNames":component.get("v.PandoraPlatformNames")});
            appEvent.fire();
            component.set("v.loading",false);
        });
        $A.enqueueAction(getHurrierLink);
    },

    savePaymentType: function(component,pCaseRecId, pPayMethod){
        var paymentMethod = component.get("c.updatePaymentMethod");
        paymentMethod.setParams({caseIdString:pCaseRecId,
                                 paymentMethod:pPayMethod});
        paymentMethod.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {              
               var result =response.getReturnValue();
               $A.get('e.force:refreshView').fire();
               var urltoOpen= '/lightning/r/Case/'+component.get("v.caseRecId")+'/view';
               if(result !== 'Failed' || !$A.util.isEmpty(result) ){
                    component.set("v.paymentMethodOnCase",pPayMethod);
                    var workspaceAPI = component.find("orderDetWorkspace");
                    var recTempId = component.get("v.caseRecId");
                    workspaceAPI.openTab({
                       url: urltoOpen,
                       focus: false
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            workspaceAPI.closeTab({tabId: tabInfo.tabId});
                        });
                    }).catch(function(error) {
                        console.log('@@savePaymentType'+error);
                    });
               }            
            }
        }); 
        $A.enqueueAction(paymentMethod); 
    },

     getPlatformNames: function(component) {
        var path = $A.get("$Resource.OrderDetailPandoraPlatformNames");       
        var req = new XMLHttpRequest();
        req.open("GET", path);
        req.addEventListener("load", $A.getCallback(function() {
             component.set("v.PandoraPlatformNames", req.response);
            }));
        req.send(null);
    }
})
