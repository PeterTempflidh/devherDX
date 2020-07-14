({
    getCases: function(component,event,helper,calledFrom){
        var action = component.get('c.getCases');
        action.setParams({recId:component.get("v.recordId"),isRelatedList:false,loadCriteria:component.get("v.loadCriteria")});
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var results=actionResult.getReturnValue();
                var nps=0;
                var avgNPS=0;
                var totalResponses=0;
                var casesIn30Days=0;
                var casesForSameOrder=0;
                if(results!=null && results!=undefined && results.caseList!=undefined){
                    component.set('v.oldCasesPresent',true);
                    var caseList=[];
                    var columnList=[];
                    for(var i=0;i<results.caseList.length;i++){
                        results.caseList[i].link='/'+results.caseList[i].Id;
                        if(results.caseList[i].LiveChatTranscripts!=null && results.caseList[i].LiveChatTranscripts.length>0){
                            results.caseList[i].chatLink='/'+results.caseList[i].LiveChatTranscripts[0].Id;
                            results.caseList[i].ChatName=results.caseList[i].LiveChatTranscripts[0].Name;
                        }
                        //Get NPS
                        if(results.caseList[i].Survey_Responses__r!=null && results.caseList[i].Survey_Responses__r.length>0){
                            nps=nps+results.caseList[i].Survey_Responses__r[0].qualtrics__Net_Promoter_Score__c;
                            totalResponses=totalResponses+1;
                        }
                        var date = new Date();
                        date.setDate(date.getDate() - 30);
                        //Get number of cases created in last 30 days
                        if(((results.currentCase.Customer_Email__c!=null && results.currentCase.Customer_Email__c==results.caseList[i].Customer_Email__c) || (results.currentCase.Customer_Phone_Number_1__c!=null && results.currentCase.Customer_Phone_Number_1__c==results.caseList[i].Customer_Phone_Number_1__c)) && new Date(results.caseList[i].CreatedDate)>date){
                            casesIn30Days=casesIn30Days+1;
                        }
                        //Get number of cases for same order
                        if(results.currentCase.Order_Number__c!=null && results.currentCase.Order_Number__c==results.caseList[i].Order_Number__c){
                            casesForSameOrder=casesForSameOrder+1;
                        }
                        //Set created date in a more legible format
                        if(results.caseList[i].CreatedDate!=null && results.caseList[i].CreatedDate!=undefined){
                            results.caseList[i].CreatedDate=new Date(results.caseList[i].CreatedDate).toLocaleDateString()+' '+new Date(results.caseList[i].CreatedDate).toLocaleTimeString();
                        }
                    }
                    if(nps>0){
                        avgNPS=(nps/totalResponses).toFixed(1);
                    }
                    if(results.columnOrder!=null && results.columnOrder!=undefined){
                        //column labels to be added to dom
                        //$Label.c.Status
                        //$Label.c.Origin
                        //$Label.c.Case_Number
                        //$Label.c.Chat_Name
                        //$Label.c.Opened_Date
                        //$Label.c.Case_Reason_Level_3_Label
                        //$Label.c.Order_Number
                        //$Label.c.Case_Type_Label
                        //$Label.c.Case_Reason_Level_2_Label
                        //$Label.c.Case_Reason_Level_1_Label
                        for(var i=0;i<results.columnOrder.length;i++){
                            var a = $A.getReference("$Label.c."+results.columnOrder[i].ColumnName);
                            component.set("v.colLabel",a);
                            if(results.columnOrder[i].FieldAPIName=='CaseNumber'){
                                columnList.push({label: component.get("v.colLabel"), fieldName: 'link', type: results.columnOrder[i].Type,typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_self'}});
                            }
                            else if(results.columnOrder[i].FieldAPIName=='Name'){
                                columnList.push({label: component.get("v.colLabel"), fieldName: 'chatLink', type: results.columnOrder[i].Type,typeAttributes: {label: { fieldName: 'ChatName' }, target: '_self'}});
                            }
                            else{
                                columnList.push({label: component.get("v.colLabel"), fieldName: results.columnOrder[i].FieldAPIName, type: results.columnOrder[i].Type});
                            }
                        }
                        component.set('v.columns',columnList);
                        component.set('v.data', results.caseList);
                    }
                    else{
                        component.set('v.data', results.caseList);
                    }
                    component.set('v.numberOfCases', results.caseList.length);
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
            if(calledFrom!='init')
            var spinner = component.find("loadingSpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }
});