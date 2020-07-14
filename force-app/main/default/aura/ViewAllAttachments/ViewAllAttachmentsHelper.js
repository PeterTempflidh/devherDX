({
    sortData : function(cmp, data, fieldName, sortDirection){

        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
            // to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        
        //set sorted data to accountData attribute
        cmp.set("v.attachments",data);
    },
    
    openModal : function(cmp, event){
        
        let header = cmp.find("headerdiv");
        let table = cmp.find("tablecard");
        $A.util.addClass(header, "slds-hide");
        $A.util.addClass(table, "slds-hide");
        cmp.find("fileUploadPage").openModal();
    }
})