import { LightningElement,api } from 'lwc';

export default class SearchResults extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;
    @api recId ;
    @api displayInfo ;
    handleSelect(event){
        event.preventDefault();
        const selectedRecord = new CustomEvent(
            "select",
            {
                detail : this.record.Id
            }
        );
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }

}