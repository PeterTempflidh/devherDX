({
    fetchInitialData: function (event, cmp, numberOfRecords) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        var action = cmp.get('c.loadReportData');
        action.setParam("reportDefinition", cmp.get('v.reportDefinition'));
        var self = this;
        action.setCallback(this, function(response) {
            this.handleResponse(cmp, event, response, function(returnValue) {
                cmp.set('v.reportData', {reportData: returnValue});
                cmp.set('v.data', returnValue.data.slice(0, numberOfRecords));
                cmp.set('v.columns', returnValue.columns);
                self.fetchReportSize(cmp, returnValue.data.length);
                 var spinner = cmp.find('spinner');
                $A.util.addClass(spinner, 'slds-hide');
            });
        });
        $A.enqueueAction(action);
    },

    fetchReportSize: function (cmp, size) {
        cmp.set('v.totalRows', size);
    },

    fetchData: function (event, cmp, numberOfRecords) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        var reportData = cmp.get('v.reportData').reportData;
        cmp.set('v.data', reportData.data.slice(0, numberOfRecords));
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },

    downloadCsvFile: function (event, cmp) {
        var spinner = cmp.find('spinner');
        var progressBar = cmp.find("progressBar");
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.removeClass(progressBar, "slds-hide");
        var recordId;
        this.fetchDataChunkById(event,cmp, recordId, recordId);
    },

    initialiseDownload: function (event, cmp, reportData) {
        var csvRows= '';
        var csvHeaderRow='';
        var separator = ',';
        for (var col of reportData.columns) {
            csvHeaderRow += '\"' + col.label + '\"' + separator;
        }
        csvHeaderRow = csvHeaderRow.substring(0, csvHeaderRow.length-1) + '\n';
        for (var valueMap of  reportData.data) {
            var csvRow = '';
            for (var col of reportData.columns) {
                 csvRow+= valueMap[col.fieldName] || valueMap[col.fieldName] === false ? ('\"' + valueMap[col.fieldName] + '\"' + separator) :  ('\" \" ' + separator);
            }
            csvRows += csvRow.substring(0, csvRow.length -1) + '\n';
        }
        var csv = csvHeaderRow + csvRows;
        var blob = new Blob(csv, {type: "text/plain"});
        var url = URL.createObjectURL(blob);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = url;
        hiddenElement.target = '_blank';
        hiddenElement.download = 'report.csv';
        hiddenElement.click();
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },

    fetchDataChunkById: function (event, cmp, recordId, reportData) {
        var progress = cmp.get("v.progress");
        if (progress < 99) { cmp.set("v.progress", progress + 1); }
        var action = cmp.get("c.loadReportDataById");
        action.setParam("reportDefinition", cmp.get("v.reportDefinition"));
        action.setParam("recordId", recordId);
        var self = this;
        action.setCallback(this, function(response) {
            this.handleResponse(cmp, event, response, function(returnValue) {
                 if (Array.isArray(returnValue.data) && returnValue.data.length) {
                     if (reportData) {
                          reportData.data = reportData.data.concat(returnValue.data);
                      } else {
                          reportData = returnValue;
                      }
                     self.fetchDataChunkById(event, cmp, returnValue.latestRecordId, reportData);
                 } else {
                    cmp.set("v.progress", 100);
                    self.initialiseDownload(event, cmp, reportData);
                    var progressBar = cmp.find("progressBar");
                    $A.util.addClass(progressBar, "slds-hide");
                    cmp.set("v.progress", 1);
                 }
            });
        });
        $A.enqueueAction(action);
    },

    handleResponse: function(cmp, event, response, onSuccess) {
        cmp.set('v.loadMoreStatus', 'Loading');
        event.getSource().set("v.isLoading", true);
        var state = response.getState();
        if (state === "SUCCESS") {
            onSuccess(response.getReturnValue());
        }
        else if (state === "ERROR") {
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
        event.getSource().set("v.isLoading", false);
        cmp.set('v.loadMoreStatus', '');
    }
  });