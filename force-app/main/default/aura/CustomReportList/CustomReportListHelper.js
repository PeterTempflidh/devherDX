/**
 * Created by m.jurkunas on 8/20/19.
 */
({
    toggleReport: function (cmp, event) {
            var index =  event.currentTarget.getAttribute("data-id");
            var reportDescriptions = cmp.get('v.reportDescriptions');
            reportDescriptions.forEach(x => x.isVisible = false );
            reportDescriptions[index].isVisible = true;
            cmp.set('v.reportDescriptions', reportDescriptions);
    }
});