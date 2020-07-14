({    
    setData :  function(component,event,helper){
       if(event.getParam("recordId")==component.get("v.recordId") 
           && event.getParam("customerDet")!=undefined
           && event.getParam("customerDet")!=null && event.getParam("customerDet")!=""){
			component.set("v.customerDetails",event.getParam("customerDet"));
            component.set("v.orderNumber",event.getParam("searchedOrderNumber"));
            var customerDetails=event.getParam("customerDet");
            if(customerDetails.customer_id!=null && customerDetails.customer_id!=undefined){
                component.set("v.dataPresent",true);
                helper.fetchOrderHistory(component,event,helper,customerDetails);
            }
            else{
                component.set("v.dataPresent",false);
            } 
        }
       else if(event.getParam("recordId")==component.get("v.recordId") && (event.getParam("customerDet")=='' || event.getParam("customerDet")==		undefined || event.getParam("customerDet")==null)){
            component.set("v.dataPresent",false);
       }
    },
    
    fetchOrderHistory :  function(component,event,helper,customerDetails){
            var action=component.get("c.fetchOrderHistory");
            action.setParams({customerId: customerDetails.customer_id,platform:event.getParam("platformName"),country:event.getParam("country")});
            action.setCallback(this,function(response){
				component.set("v.showSpinner",false);
                var state = response.getState();
                if (state === "SUCCESS") {
                   if(response.getReturnValue()!=undefined && response.getReturnValue()!=null){
                        if(response.getReturnValue().isError!=true){
                            var obj=JSON.parse(response.getReturnValue().result);
                            var result;
                            if(obj!=undefined && obj!=null){
                                if(obj.data!=undefined && obj.data!=null){
                                    result=obj.data.order_status_aggregates;
                                }
                            }
                            var dataList=[];
                            for(var i=0;i<result.length;i++){
                                var data=[];
								if(component.get("v.orderNumber")!=result[i].order.order_id){
									data.orderId=result[i].order.order_id;
									if(result[i].order_statuses[result[i].order_statuses.length-1]!=null && result[i].order_statuses[result[i].order_statuses.length-1]!=undefined && result[i].order_statuses[result[i].order_statuses.length-1].status!=null && result[i].order_statuses[result[i].order_statuses.length-1]!=undefined){
										data.status=result[i].order_statuses[result[i].order_statuses.length-1].status;
										if(data.status == 'FAILED' || data.status == 'REJECTED' ||  data.status == 'CANCELLED' || data.status == 'EXPIRED'){
											data.isNegative=true;
										}
									}
									else{
										data.isNegative=true;
									}
									data.amount=result[i].order.order.order_value;
									data.Restaurant_Name=result[i].order.vendor.name;
									var timestamp = !$A.util.isUndefinedOrNull(result[i].order.place_timestamp)?result[i].order.place_timestamp:result[i].order.timestamp;
									data.createdDate=new Date(timestamp).toLocaleDateString()+' '+new Date(timestamp).toLocaleTimeString();
                                   	dataList.push(data);
								}
                            }
                            dataList=dataList.sort((a, b) => (a.createdDate > b.createdDate) ? -1 : 1);
                            component.set("v.data",dataList);
                        }//Call was made but no result returned
                        else{
                            console.log('error state prev orders');
                            component.set("v.dataPresent",false);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
    }
});