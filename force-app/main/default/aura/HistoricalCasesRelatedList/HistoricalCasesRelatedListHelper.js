({
    getCases: function(component,event,helper){
        //Column Labels to be added to the DOM
        //$Label.c.Case_Number
        //$Label.c.Chat_Name
        //$Label.c.Opened_Date
        //$Label.c.Case_Reason_Level_3_Label
        //$Label.c.Order_Number
        var action = component.get('c.getCases');
        action.setParams({recId:component.get("v.recordId"),isRelatedList:true,loadCriteria:component.get("v.loadCriteria")});
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var results = actionResult.getReturnValue();
                if(results && results.caseList){
                    component.set('v.oldCasesPresent',true);
                    var caseList=[];
                    var columnList=[];
                    var nps=0;
                    var totalResponses=0;
                    var avgNPS=0;
                    var casesIn30Days=0;
                    var casesForSameOrder=0;
					component.set("v.showCasesWithSameOrder",results.showCasesWithSameOrder);
                    for(var i=0;i<results.caseList.length;i++){
                        //Get NPS
                        if(results.caseList[i].Survey_Responses__r){
                            nps=nps+results.caseList[i].Survey_Responses__r[0].qualtrics__Net_Promoter_Score__c;
                            totalResponses=totalResponses+1;
                        }
                        var date = new Date();
                        date.setDate(date.getDate() - 30);
                        //Get number of cases created in last 30 days
                        if(((results.currentCase.Customer_Email__c!=null && results.currentCase.Customer_Email__c==results.caseList[i].Customer_Email__c) || (results.currentCase.Customer_Phone_Number_1__c!=null && results.currentCase.Customer_Phone_Number_1__c==results.caseList[i].Customer_Phone_Number_1__c)) && new Date(results.caseList[i].CreatedDate)>date){
                            casesIn30Days=casesIn30Days+1;
                        }
                        //Get number of cases created for same order number
                        if(results.showCasesWithSameOrder && results.currentCase.Order_Number__c!=null && results.currentCase.Order_Number__c==results.caseList[i].Order_Number__c){
                            casesForSameOrder=casesForSameOrder+1;
                        }
                    }
                    for(var i=0;i<10;i++){
                        if(results.caseList[i]){
                            //Create case & chat name as link
                            results.caseList[i].caseReasonLink='/'+results.caseList[i].Id;
                            if(results.caseList[i].LiveChatTranscripts){
                                results.caseList[i].caseReasonLink='/'+results.caseList[i].LiveChatTranscripts[0].Id;
                            }
                            if(results.caseList[i].Case_Reason_Level_3__c){
                                results.caseList[i].CaseReason = results.caseList[i].Case_Reason_Level_3__c;
                            }
                            else if(results.caseList[i].Case_Reason__c){
                                results.caseList[i].CaseReason = results.caseList[i].Case_Reason__c;
                            }
                            else{
                                results.caseList[i].CaseReason = results.caseList[i].Subject;
                            }

                            if(results.caseList[i].Status=='Closed' || results.caseList[i].Status=='Resolved'){
                                results.caseList[i].StatusVal='green';
                            }
                            else if(results.caseList[i].Status!='New'){
                                results.caseList[i].StatusVal='yellow';
                            }
                            else{
                                results.caseList[i].StatusVal='red';
                            }
                            //set createdDate in a more legible format
                            if(results.caseList[i].CreatedDate){
                                if(new Date(results.caseList[i].CreatedDate).toLocaleDateString() == new Date().toLocaleDateString()){
                                    results.caseList[i].openedDate = new Date(results.caseList[i].CreatedDate).toLocaleTimeString();
                                }
                                else{
                                    results.caseList[i].openedDate = new Date(results.caseList[i].CreatedDate).toLocaleDateString();
                                }
                                results.caseList[i].CreatedDate=new Date(results.caseList[i].CreatedDate).toLocaleDateString()+' '+new Date(results.caseList[i].CreatedDate).toLocaleTimeString();
                            }
                            caseList.push(results.caseList[i]);
                        }
                    }
                    if(nps>0){
                        avgNPS=(nps/totalResponses).toFixed(1);
                    }
                    if(caseList){
                        component.set('v.data', caseList);
                        var comp=component.find("score");
                        //Toggle styling of NPS based on score
                        if(totalResponses>0){
                            if(avgNPS>=9){
                                $A.util.addClass(comp, 'good');
                                $A.util.removeClass(comp, 'ok');
                                $A.util.removeClass(comp, 'bad');
                            }
                            if(avgNPS>=7 && avgNPS<9){
                                $A.util.addClass(comp, 'ok');
                                $A.util.removeClass(comp, 'good');
                                $A.util.removeClass(comp, 'bad');
                            }
                            if(avgNPS<7){
                                $A.util.addClass(comp, 'bad');
                                $A.util.removeClass(comp, 'ok');
                                $A.util.removeClass(comp, 'good');
                            }
                            component.set("v.nps",avgNPS);
                        }
                        else{
                            component.set("v.nps",'N/A');
                        }
                        if(component.get("v.loadCriteria")=='On Init'){
                            component.set("v.casesIn30Days",casesIn30Days);
                            component.set("v.casesForSameOrder",casesForSameOrder);
                        }
                    }
                    else{
                        component.set('v.data', results.caseList);
                        component.set("v.nps",avgNPS);
                        if(component.get("v.loadCriteria")=='On Init'){
                            component.set("v.casesIn30Days",0);
                            component.set("v.casesForSameOrder",0);
                        }
                    }
                    component.set('v.numberOfCases', results.caseList.length);
                }
                else{
                    component.set('v.data', []);
                    component.set("v.nps",'N/A');
                    component.set('v.numberOfCases', 0);
                    if(component.get("v.loadCriteria")=='On Init'){
                        component.set("v.casesIn30Days",0);
                        component.set("v.casesForSameOrder",0);
                    }
                }
            }
            else{
                component.set('v.data', []);
                component.set("v.nps",'N/A');
                component.set('v.numberOfCases', 0);
                if(component.get("v.loadCriteria")=='On Init'){
                    component.set("v.casesIn30Days",0);
                    component.set("v.casesForSameOrder",0);
                }
            }
            var last30Days=component.find("last30Days");
            var sameOrder=component.find("sameOrder");
            if(component.get("v.loadCriteria")=='ordersList'){
                $A.util.addClass(sameOrder, 'selected');
                $A.util.removeClass(last30Days, 'selected');
            }
            else if(component.get("v.loadCriteria")!='On Init'){
                $A.util.addClass(last30Days, 'selected');
                $A.util.removeClass(sameOrder, 'selected');
            }
            else{
                $A.util.removeClass(last30Days, 'selected');
                $A.util.removeClass(sameOrder, 'selected');
            }
            var spinner = component.find("loadingSpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }
});