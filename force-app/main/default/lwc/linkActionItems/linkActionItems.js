/**
 * Created by keerthan.tantry on 03/05/2020.
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActionItems from '@salesforce/apex/CtrLinkActionItems.getActionItems';
import linkActionItems from '@salesforce/apex/CtrLinkActionItems.linkActionItems';
import delinkActionItems from '@salesforce/apex/CtrLinkActionItems.delinkActionItems';
const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Priority', fieldName: 'priority'},
    { label: 'Type', fieldName: 'actionType'},
    { label: 'Is Linked',fieldName: 'isLinked' , type: 'boolean'}
];
export default class LinkActionItems extends LightningElement {
@api objectName;
@api objId;
@api code;
@track data;
@track isLoading = false;
@track columns = columns;
@track selectedRecords;
constructor(){
    super();
}
connectedCallback(){
    this.getAllActionItems();
}

getAllActionItems(){
    this.data = [];
    this.isLoading = true;
        getActionItems({taskId : this.objId})
        .then(result => {
            this.data = (Array.isArray(result) && result.length) ? result : undefined;
            this.isLoading = false;
        })
        .catch(error => {
        });
}

linkTask(){
   this.isLoading = true;
   if(this.selectedRecords !== undefined && this.selectedRecords !== ''){
           linkActionItems({taskId : this.objId, actionItemIds : this.selectedRecords})
           .then(result => {
                 alert('Success: Linked successfully.');
                 this.getAllActionItems();
                 this.selectedRows  = [];
                 this.isLoading = false;


           })
           .catch(error => {
               alert(`Error : ${error.body.message}`);
               this.isLoading = false;
           });
          }else{
              alert('Error: Please select at least one Action Item.');
              this.isLoading = false;
          }
}
delinkTask(){
      this.isLoading = true;
      if(this.selectedRecords !== undefined && this.selectedRecords !== ''){
              delinkActionItems({code : this.code, actionItemIds : this.selectedRecords})
              .then(result => {
                  alert('Success: Delinked successfully.');
                  this.selectedRows  = [];
                  this.getAllActionItems();
                  this.isLoading = false;
              })
              .catch(error => {
                  this.isLoading = false;
              });
      }else{
           alert('Error: Please select at least one Action Item.');
           this.isLoading = false;
      }
}

getSelectedRows(event){
    const selectedRows = event.detail.selectedRows;
    const ids = new Set();
    for (let i = 0; i < selectedRows.length; i++){
                ids.add(selectedRows[i].actionItemId);
       }
    this.selectedRecords = Array.from(ids).join(',');
}

}