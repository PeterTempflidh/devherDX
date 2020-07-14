({
    init: function (cmp, event, helper) {
        helper.fetchInitialData(event, cmp, cmp.get('v.rowsToLoad'));
    },

    resetRows: function (cmp, event, helper) {
        helper.fetchInitialData(event, cmp, cmp.get('v.rowsToLoad'));
        cmp.set('v.enableInfiniteLoading', true);
    },

    loadMoreData: function (cmp, event, helper) {
        var rowsToLoad = cmp.get('v.rowsToLoad');
        var rowsExisting = cmp.get('v.data').length;
        if (cmp.get('v.totalRows') == rowsExisting || rowsExisting >= 500 ) {
            cmp.set('v.enableInfiniteLoading', false);
            return;
        }
        helper.fetchData(event, cmp, rowsToLoad + rowsExisting);
    },

    downloadCsv: function (cmp, event, helper) {
        helper.downloadCsvFile(event, cmp);
    }
});
