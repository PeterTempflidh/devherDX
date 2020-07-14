/**
 * Created by p.bansal on 09-Dec-19.
 */

import { LightningElement, api, track, wire} from 'lwc';
import getOmniSuprvisrAgents from '@salesforce/apex/CustomPresenceConfig_LWCController.getOmniSuprvisrAgents';
import getPresenceConfig from '@salesforce/apex/CustomPresenceConfig_LWCController.getPresenceConfig';
import removeAgentsOldCapacity from '@salesforce/apex/CustomPresenceConfig_LWCController.removeAgentsOldCapacity';
import getAgentsUpdatedCapacity from '@salesforce/apex/CustomPresenceConfig_LWCController.getAgentsUpdatedCapacity';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import configNotAvailable from '@salesforce/label/c.SuperVisorConfigNotDefined';
import PresConfig_CapacityError from '@salesforce/label/c.PresConfig_CapacityError';
import PresConfig_LimitErrorPart2 from '@salesforce/label/c.PresConfig_LimitErrorPart2';
import PresConfig_NoAgentSelected from '@salesforce/label/c.PresConfig_NoAgentSelected';
import PresConfig_PartialCapacityErrorPartI from '@salesforce/label/c.PresConfig_PartialCapacityErrorPartI';
import PresConfig_PartialCapacityErrorPart2 from '@salesforce/label/c.PresConfig_PartialCapacityErrorPart2';
import PresConfig_NoConfigSelected from '@salesforce/label/c.PresConfig_NoConfigSelected';
import PresConfig_SuccessCapAssigned from '@salesforce/label/c.PresConfig_SuccessCapAssigned';
import PresConfig_ModalHeading from '@salesforce/label/c.PresConfig_ModalHeading';
import PresConfig_SearchFieldDefText from '@salesforce/label/c.PresConfig_SearchFieldDefText';
import PresConfig_RefreshListButtonName from '@salesforce/label/c.PresConfig_RefreshListButtonName';
import PresConfig_ChangeCapButtonName from '@salesforce/label/c.PresConfig_ChangeCapButtonName';
import PresConfig_SearchFieldHeaderLabel from '@salesforce/label/c.PresConfig_SearchFieldHeaderLabel';
import PresConfig_SaveButtonLabel from '@salesforce/label/c.PresConfig_SaveButtonLabel';
import PresConfig_CancelButtonLabel from '@salesforce/label/c.PresConfig_CancelButtonLabel';
import PresConfig_ComponentHeader from '@salesforce/label/c.PresConfig_ComponentHeader';
import PresConfig_AgentCountLoadMessage from '@salesforce/label/c.PresConfig_AgentCountLoadMessage';
import PresConfig_SearchResEmptyMessage from '@salesforce/label/c.PresConfig_SearchResEmptyMessage';
import PresConfig_AgentSelCountMesg from '@salesforce/label/c.PresConfig_AgentSelCountMesg';
import PresConfig_AgentSelectLimit from '@salesforce/label/c.PresConfig_AgentSelectLimit';
import PresConfig_NewLoadLimit from '@salesforce/label/c.PresConfig_NewLoadLimit';

//External JS import
import {sortList, sortOnClick} from 'c/utilityComponentLWC';




const GRIDCOLS = [
    {  type: 'text',label: 'Name', fieldName: 'agentName', editable: false, sortable : true },
    {  type: 'text',label: 'Username', fieldName: 'agentUsername', editable: false, sortable : true },
    {  type: 'text',label: 'Capacity', fieldName: 'agentCapacity', sortable : true, editable: false, cellAttributes: { alignment: 'left' } }
];
const PCCONFIGSCOLS = [
    {  type: 'text',label: 'Name', fieldName: 'MasterLabel', editable: false }
];


export default class CustomPresenceConfigLWC extends LightningElement {
	
	/** Custom labels vars to use in the template. **/
    label = {
        configNotAvailable,
        PresConfig_NoAgentSelected,
        PresConfig_CapacityError,
        PresConfig_LimitErrorPart2,
        PresConfig_PartialCapacityErrorPartI,
        PresConfig_PartialCapacityErrorPart2,
        PresConfig_NoConfigSelected,
        PresConfig_SuccessCapAssigned,
        PresConfig_ModalHeading,
        PresConfig_SearchFieldDefText,
        PresConfig_RefreshListButtonName,
        PresConfig_ChangeCapButtonName,
        PresConfig_SearchFieldHeaderLabel,
        PresConfig_SaveButtonLabel,
        PresConfig_CancelButtonLabel,
        PresConfig_ComponentHeader,
        PresConfig_AgentCountLoadMessage,
        PresConfig_AgentSelCountMesg,
        PresConfig_SearchResEmptyMessage,
        PresConfig_AgentSelectLimit,
        PresConfig_NewLoadLimit
    };
	
	/**  Datatable columns **/
    @track gridColumns = GRIDCOLS;   
    @track modalColumns = PCCONFIGSCOLS;
	@track openmodel = false;
    /** Selection variables and apex variables **/
	@track selectedConfig ;
    @api selectedAgents = [];
    @api selectedPresConfig =[];
    @track selectedRecs = [];
    @api selectedCap ;
    @track mapOfAgents = {};
    @track selectedRecords = [];
    @api agents;
    /** Used to assign the list to agents var when the user deletes the search string **/
    @track agentsInitialList = [];
    @track agentsLoadedList = [];
    /** Sorting variables **/
    @track sortBy ;
    @track sortedDirection;
    @track error ; 
	
    @track loaded = false;
    @track loadedpopup = false ;
    @api searchKey = '';
    @track noConfigAvailForCurrUser = false ;
    @track noSuperVisorConfigAvailable ;
    
    dataLength ;     
    @track tablestartLimit = 0;
    @track tableendLimit = this.label.PresConfig_AgentSelectLimit;
    @track isInfinLoadEnabled = true ;
    @track noResString ;

    @track disablCapBut = false ;
    @track selectionCountMessage = '';
    @track selectedRecords = [];
    @track mapOfSels = {};
    @track selRows = [];
    @track refreshDis = true;

     /** Wired Apex result so it can be refreshed programmatically */
     _wiredResult;


    
    /** The error message when the supervisor does not have configuration assigned **/
    get noConfigErrorMsg() {
        return this.noSuperVisorConfigAvailable;
    }
    set noConfigErrorMsg(value) {
        this.noSuperVisorConfigAvailable = this.label.configNotAvailable;
        this.setAttribute('title', this.noSuperVisorConfigAvailable);
    }

	/** Toast Notification set up**/
    _title = '';
    message = '';
    variant = '';
    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];

    titleChange(event) {
        this._title = event.target.value;
    }

    messageChange(event) {
        this.message = event.target.value;
    }

    variantChange(event) {
        this.variant = event.target.value;
    }
    modeChange(event){
        this.mode = event.target.value;
    }
    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
            mode: this.mode
        });
        this.dispatchEvent(evt);
    }
 
    	
	/** The list of Presence Configurations on the pop up**/
    @wire(getPresenceConfig) getPresenceConfig({ error, data} ){
        if (data) {
            this.presenceConfigs = data;
        }else if (error) {
            this.error = error;
            this.presenceConfigs = undefined;
            console.log('error..'+this.error);
        }
    }
	
	/** The list of agents on page **/
	@wire(getOmniSuprvisrAgents) readJson(result ){
		this._wiredResult = result;
		if (result.data) {
			/** When there are no configs available for the supervisor**/
			if(result.data === 'NotFound'){ 
				this.noConfigAvailForCurrUser = true;
				this.noSuperVisorConfigAvailable = this.label.configNotAvailable ;
				if(this.loaded === false){	this.loaded = !this.loaded;}
			}
			else{
                /** This list is maintained to solve the issue when the search list does not get reset after deleting the search string**/
                this.loaded = false;
                this.noConfigAvailForCurrUser = false;
                this.agentsInitialList = sortList('agentName',result.data);
                this.dataLength = this.agentsInitialList.length ;
                this.tablestartLimit = 0;
                this.tableendLimit = this.label.PresConfig_AgentSelectLimit;
				this.doInitialLoad(this.agentsInitialList,this.dataLength);
			}  
		} else if (result.error) {
			this.error = result.error;
			this.agents = undefined;
			this.loaded = !this.loaded;
			console.log('error..'+this.error);              
		}

	}   

    doInitialLoad(pAgentsInitialList, pDataLength){        
        this.agents = [];
        for(let i = this.tablestartLimit ; i < this.tableendLimit ; i++ ) {

            this.agents.push(pAgentsInitialList[i]);
            if(this.agents.length >= pDataLength){
	        this.isInfinLoadEnabled = false;
            break ;
           }
        }
        this.agentsLoadedList = this.agents ;        
        this.loadedcount = this.agentsLoadedList.length;
        this.loaded = !this.loaded;
        if(this.loaded === false){	this.loaded = !this.loaded;}
    }


    loadMoreData(event){
		
        if(this.agents.length >= this.dataLength){
            this.isInfinLoadEnabled = false;
            this.loadedcount = this.agents.length;
        }           
       
        this.tablestartLimit = this.tableendLimit;
        this.tableendLimit = +this.tableendLimit+ +this.label.PresConfig_NewLoadLimit;
        this.tableendLimit = this.tableendLimit>=this.dataLength?this.dataLength:this.tableendLimit ;
        let newDataList = [];
        const currentRecord = this.agents;
        let noMoreData = false ;
        for(let i = this.tablestartLimit ; i < this.tableendLimit ; i++ ) {
            /** This is added due to issue with selected agents outside of current context,
              *  as the selected agent will be removed from the complete list of already selected in list
              *  **/
            if(i === this.agentsInitialList.length) {   break;}
            if(newDataList.length >= this.dataLength){
                noMoreData =true;
            }
            if(noMoreData){                 
               this.isInfinLoadEnabled = false;
               break ;
            }else{   
				if(!this.selRows.includes(this.agentsInitialList[i].agentPresenceConfigId)){
					newDataList.push(this.agentsInitialList[i]);
				}   
            }
        }
        newDataList = currentRecord.concat(newDataList);
        this.agents = newDataList;
		this.loadedcount = this.agents.length;
        this.agentsLoadedList = this.agents ;      
    }
	
     /** Refresh List through Apex if the list is not refreshed **/
     refreshList(){
        this.selectionCountMessage = '';
		this.selectedConfig = '';        
        this.searchKey = ''; 
        this.selRows = []; 
        this.loaded = !this.loaded;
        this.refreshDis = true;        
        return  refreshApex(this._wiredResult);    
     }   
    
    @track mapOfAgentsAndProfiles = {};
    openmodal(event) {  
        this.selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
        if(this.selectedRecords.length===0){
            this._title = 'Error';
            this.message = this.label.PresConfig_NoAgentSelected;
            this.variant = 'error';
			this.mode = 'dismissable';
            this.showNotification();
            this.openmodel = false;
        }   
        else{
            this.openmodel = true;
        } 
        
    }      
    

    closeModal() {
        this.openmodel = false;
        this.selectedPresConfig = [];
        this.selectedConfig = '';
    }
    
	
	/** Sort the list ascending or descending **/
    updateColumnSorting(event){
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;    
        /** assign the values **/
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        /** call the custom sort method. **/
        this.agents = sortOnClick(fieldName, sortDirection,this.agents);
      }
   

    @api failedRecs = [];
	/** Delete the existing Presence Configuration **/
    deleteResult( pOldPresConfigs, pSelectedRows){
        removeAgentsOldCapacity({ //newPresConfig: pselectedConfig,
                                  oldPresConfigIds:pOldPresConfigs,
                                  pAgentsConfigOldMap:pSelectedRows
                                }).then((result) =>{

            this.loadedpopup = true;
            switch(result) {
                case "Success": 
                this.createResult(this.selectedConfig,this.selectedAgents, this.selectedCap,this.mapOfAgentsAndProfiles);            
                break;
                case "Error":
                this._title = 'Error';
                this.message = this.label.PresConfig_CapacityError;
                this.variant = 'error';
                this.mode = 'dismissable';
                this.showNotification();              
                break;
                case "No record ids received": 
                this.createResult(this.selectedConfig,this.selectedAgents, this.selectedCap,this.mapOfAgentsAndProfiles);            
                break;
                default:
                this.createResult(this.selectedConfig,this.selectedAgents, this.selectedCap,this.mapOfAgentsAndProfiles);     
            }
            }).catch(function(error){  
                console.log('error..'+this.error);                
                this.loadedpopup = false;       
                this._title = 'Error';
                this.message =  error.body.message;
                this.variant = 'error';   
                this.mode = 'dismissable';                
                this.showNotification();
        });
    }
    /** Create the new Presence Configuration for the users selected **/
    createResult(pselectedConfig, pAgentsIds, pSelectedCap ,pSelectedRows){
       getAgentsUpdatedCapacity({ newPresConfig: pselectedConfig, 
                                  newCapacity : pSelectedCap,
                                  agentsId: pAgentsIds,
                                  pAgentsConfigOldMap:pSelectedRows})
                                  .then((result) =>{
                                    this.failedRecs = [];
                                    let resStr ;
                                    if(result && result.includes('Success--')){
                                        resStr = result.split('--')[1];
                                        result = result.split('--')[0];
                                    }else { resStr = result;}

                                    switch(result) {                                        
                                        case "Success":  
                                          this.refreshData(JSON.parse(resStr));           
                                          break;
                                        case "Error":
                                          this._title = 'Error!';
                                          this.message = this.label.PresConfig_CapacityError;
                                          this.variant = 'error';
                                          this.mode = 'dismissable';
                                          this.showNotification();              
                                          break;
										case "No record ids received":
										  this._title = 'Error!';
                                          this.message = this.label.PresConfig_CapacityError;
                                          this.variant = 'error';
                                          this.mode = 'dismissable';
                                          this.showNotification(); 
										  break;
                                        default:                                          
                                          this.refreshData(JSON.parse(resStr));
                                     }                                
                                    }).catch(function(error){
                                        console.log('in error..'+JSON.stringify(error));
                                        this.loadedpopup = false ;
                                        this._title = 'Error';
                                        this.message =  error.body.message;
                                        this.variant = 'error';   
                                        this.mode = 'dismissable';     
                                        this.showNotification();
                                    });
    }
  
    /** Refresh the table with new Capacity Assignment **/
    refreshData(pRecs) {
        let agentsNames = '';
        let sucmesg = this.label.PresConfig_SuccessCapAssigned; 
        let mesg = '';         
        const updatedIds = [];
        const successIds = [];
		let hasErrors = false;  
        let updatedRec= {};
        for(var i = 0; i < pRecs.length; i++)
        {
            var rec = pRecs[i];   
            if(!rec.dmlSuc){
                agentsNames +=  rec.agentName+' ,';
            }  
            else{
                successIds.push(rec.userId);
            }  
			updatedIds.push(rec.userId);     
			updatedRec[rec.userId] = rec; 
        } 
        let newAgentInitialList = [];
        /* Update the full list as agents can be searched and selected from full list also*/
        for(var i = 0 ; i<this.agentsInitialList.length ; i++){
            var tbRow = this.agentsInitialList[i];
            if(this.selectedAgents.includes(tbRow.userId) && updatedIds.includes(tbRow.userId) && (tbRow.userId in updatedRec)){
                tbRow.agentCapacity = updatedRec[tbRow.userId].agentCapacity ;
                tbRow.agentPresenceConfigId = updatedRec[tbRow.userId].agentPresenceConfigId ;
                tbRow.presenceConfigId = updatedRec[tbRow.userId].presenceConfigId ;
                tbRow.isCapSetAtUser = updatedRec[tbRow.userId].isCapSetAtUser ;
            }
                newAgentInitialList.push(tbRow);
        }
        if(newAgentInitialList.length>0){    this.agentsInitialList = newAgentInitialList;}
       
        let tempAgents_list = []; 
		let data_Length = this.agentsInitialList.length>this.tableendLimit?this.tableendLimit:this.agentsInitialList.length;
        for(let i =0; i<data_Length ;i++){
            tempAgents_list.push(this.agentsInitialList[i]);
        }
      
        if(tempAgents_list.length>0){   
            this.agents = tempAgents_list;
            this.agentsLoadedList = this.agents;

        }
        if(this.agents.length<this.dataLength){
            this.isInfinLoadEnabled = true;
        }
        if(agentsNames !== ''){
               agentsNames = agentsNames.replace(/,\s*$/, ""); 
               mesg = this.label.PresConfig_PartialCapacityErrorPartI +agentsNames+this.label.PresConfig_PartialCapacityErrorPart2;
               hasErrors = true ;  
        }     
      
        this.selectedConfig = '';        
        this.searchKey = ''; 
        this.selRows = []; 
        this.selectionCountMessage = '';

        if(successIds.length>0){   
            this.loadedcount = this.agentsLoadedList.length;                  
            this._title = 'Success';
            this.message =  sucmesg;
			this.mode = 'dismissable';
            this.variant = 'success';
            this.showNotification();  
        } 
        if(hasErrors){
            this._title = 'Error';
            this.message =  mesg;
            this.variant = 'error';   
            this.mode = 'dismissable';     
            this.showNotification();
        }  
        this.loadedpopup = false;
        this.closeModal();
    }
    /** Method called on click of Save button to update the assignment **/
    saveMethod() {       
         
        this.selectedPresConfig = [];
        this.selectedAgents = [];
        this.selectedRecs = [];
        this.mapOfAgents = {};
        this.mapOfAgentsAndProfiles = {};       
        this.selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
        if(this.selectedRecords.length===0){
            this._title = 'Error';
            this.message = this.label.PresConfig_NoAgentSelected;
			this.mode = 'dismissable';
            this.variant = 'error';
            this.showNotification();
        }
        else{
            this.selectedRecs.push(this.selectedRecords);
            /** Display that fieldName of the selected rows **/
            for (let i = 0; i < this.selectedRecords.length; i++){
                if(this.selectedRecords[i].isCapSetAtUser){
                     this.selectedPresConfig.push(this.selectedRecords[i].agentPresenceConfigId);
                     this.mapOfAgents[this.selectedRecords[i].agentPresenceConfigId] = this.selectedRecords[i];
                }
                 this.mapOfAgentsAndProfiles[this.selectedRecords[i].userId] = this.selectedRecords[i];
                 this.selectedAgents.push(this.selectedRecords[i].userId);
                         
            }
        }
        if(this.selectedRecords.length === 0){
            this.selectedPresConfig = [];
            this.selectedAgents = [];
            this.selectedRecs = [];
            this.mapOfAgents = {};
        }
      
       
       if(this.selectedConfig){                  
            if(this.selectedAgents.length > 0) {     
               this.refreshDis = false;          
               this.deleteResult(this.selectedPresConfig,this.mapOfAgents);
            }   
        }else{
            this._title = 'Error';
            this.message =  this.label.PresConfig_NoConfigSelected;
            this.variant = 'error';   
            this.mode = 'dismissable';    
            this.showNotification();
		}        
    }
    /** New Capacity selected **/
    getSelectedConfig(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows){
            this.selectedConfig = selectedRows[0].Id;
            this.selectedCap = selectedRows[0].MasterLabel;
        }     
    }
        
    getSelectedAgents(event) { 
		this.selectedRecords = event.detail.selectedRows;		
		let selrId = [];		
		for(let i=0 ; i<this.selectedRecords.length ; i++){
			selrId.push(this.selectedRecords[i].agentPresenceConfigId);
			this.mapOfSels[this.selectedRecords[i].agentPresenceConfigId] = this.selectedRecords[i];
		}
		if(this.selectedRecords.length>this.label.PresConfig_AgentSelectLimit){
			this._title = 'Error';
			this.message = this.selectedRecords.length + this.label.PresConfig_LimitErrorPart2;
			this.disablCapBut = true ;
			this.variant = 'error';
			this.mode = 'dismissable';
			this.showNotification();
		} 
		else{
			this.disablCapBut = false ;
			this.selRows = selrId;
		}
		if(this.selRows.length>0){                
			this.selectionCountMessage = this.label.PresConfig_AgentSelCountMesg+this.selRows.length;
		}else{
            this.selectionCountMessage = '';
        }
    }
   
	/** Show search result and refresh list when user changes the input string in search field **/
	handleKeyChange( event ) {   
		this.searchKey = event.target.value; 
		let str = this.searchKey ;
		str = str.trim().toLowerCase();       
		let items = [];
		let tempList = [];
		let tempSel = [];
		let itemsNotSel = [];
		/* Iterate over the selected item from current loaded slot that can be different from search results as search result is from complete list */
		for(let i =0 ; i< this.agentsLoadedList.length ; i++){           
			if(this.selRows.includes(this.agentsLoadedList[i].agentPresenceConfigId)){
				tempList.push(this.agentsLoadedList[i]);
				tempSel.push(this.agentsLoadedList[i].agentPresenceConfigId);
			}
			/* When the string becomes empty, selected results and initial List needs to be loaded. This logic is for that  */
			else{
				itemsNotSel.push(this.agentsLoadedList[i]);
			}
		}
		/* Iterate over the selected item from cpomplete list selected during search */
		for (var key in this.mapOfSels) {
			/* check if the property/key is defined in the object itself, not in parent */
			if(!tempSel.includes(key) && this.selRows.includes(key)){
			    tempList.push(this.mapOfSels[key]);
			}
		}

		if(this.searchKey.trim() !== ""){
			this.isInfinLoadEnabled = false;
			items = this.agentsInitialList.filter(item => item.agentName.toLowerCase().indexOf(str) !== -1);
			/* If no serach results are found, then just show the selected records with no results message */
			if(items.length===0){
				this.noResString = this.label.PresConfig_SearchResEmptyMessage;
                		this.agents = tempList;
                		this.loadedcount = tempList.length;
			}
			else{
				this.noResString ='';
				let shortList = [];
				for(let i = 0; i<items.length; i++){
					if(!this.selRows.includes(items[i].agentPresenceConfigId)){
					shortList.push(items[i]);
					}
				}
				/*If there are more than 200 searched results then trim the results to 200+selected rows */
				if(shortList.length>200){ 
					tempList = tempList.concat(shortList.slice(0,200));
				}
				/*If there are searched results less than 200, show all */
				else if(shortList.length<=200){
					tempList = tempList.concat(shortList) ;
				}
                this.agents = tempList;
                this.loadedcount = this.agents.length;
               	}            
		}else{
            this.noResString ='';            
            this.agents = tempList.concat(itemsNotSel);  
            this.agentsLoadedList = this.agents;
            this.loadedcount = this.agents.length;
			this.isInfinLoadEnabled = true;      
		}
	}

}
