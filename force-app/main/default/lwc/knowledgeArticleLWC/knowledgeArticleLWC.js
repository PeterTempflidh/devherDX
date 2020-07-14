
import { LightningElement, api, track, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getAllMatchingArticles from '@salesforce/apex/KnowledgeArticle_Controller.getAllMatchingArticles';
import getSearchedArticles from '@salesforce/apex/KnowledgeArticle_Controller.getAllMatchingArticles';
//Only for refresh articles when Case reasons are set
import getupdatedAllMatchingArticles from '@salesforce/apex/KnowledgeArticle_Controller.getupdatedAllMatchingArticles';
import { registerListener,fireEvent } from 'c/pubsubutil';
import { CurrentPageReference } from 'lightning/navigation';
import Suggested_Article from '@salesforce/label/c.Suggested_Article';
import Search_Knowledge from '@salesforce/label/c.Search_Knowledge';
import No_Result from '@salesforce/label/c.No_Result';

export default class KnowledgeArticleLWC extends NavigationMixin(LightningElement) {
	@wire(CurrentPageReference) pageRef;
    @api recordId;
    @track selectedRecord;    
    @track searchResults = [];
    @track error;
    @track articlesList = [];
    @track searchKey ;
    @track iconname = "standard:knowledge";
    @track articleCount = 0;
    @track searchResults = [];
    @track showPopUp =false;
    @track hoveredArticle;
    @track rowInd = -1;
    @track top;
    @track left;
    @track noarticles = false;
    fromSearch = false ;

    label = {
        Suggested_Article,
        Search_Knowledge,
        No_Result
    }
	//1. Handler function called through Aura wrapper fired from Case reason that fires the another event here, implemented in pubsubutil
	//to make a call back to handler after registering the event
    @api
    forceRefreshInitiated() {
         fireEvent(this.pageRef, 'forceRefresh'); // your LWCs pubsub to this channel
    }
	//2.Registers the event called in step 1 and initiates the call back as implemented in pubsubutil LWC
	connectedCallback() {
		registerListener('forceRefresh', this.handleRefresh, this);
    }
	
	//3. Get the updated list of articles based on Case reason via event or after click on refresh button
	handleRefresh() {
		getupdatedAllMatchingArticles({ objRecordId: this.recordId, searchKey: '', isThroughSearch:false})
				.then(result => {
					if (result) {
						if(result === 'No results found.'){                
							this.articlesList = [];
						}else{
						this.articlesList = JSON.parse(result);
						this.articleCount = this.articlesList.length;
						}
						this.error = undefined;
					} 
				})
				.catch(error => {
					this.error = error;				  
					console.log('error'+JSON.stringify(this.error));
				});
    }
	
    get compheight(){
        return "height:10rem;";
    } 

    @wire(getAllMatchingArticles, { objRecordId: '$recordId', searchKey: '', isThroughSearch:false})    
    wiredKnowledge({ error, data }) {
        if (data) {
            if(data === 'No results found.'){                
                this.articlesList = [];
            }else{
            this.articlesList = JSON.parse(data);
            this.articleCount = this.articlesList.length;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }


    showArticleDetail(event){
        this.showPopUp = true;
        this.hoveredArticle = this.articlesList[event.currentTarget.dataset.recindex];
        this.rowInd = event.currentTarget.dataset.recindex;
       
    }
	/*Enable the popover allwoing user to explore the article */
	showPopOver(){
        this.showPopUp = true;
    }
	/*Disable the popover when user moves the mouse out of article */
    hidePopOver(){
        this.rowInd = -1;
        this.showPopUp = false;
    }  
    
	/* CSS Property of search result list height*/
	get searchResultPanelHeight(){
        return 'max-height:90px;overflow-y:auto;';
    }
    
	/* CSS Property of popover. This will be changes to calculated position*/
    get boxClass() { 
        const appliedcss ="width:700px;height: 575px;overflow:auto;position:absolute;z-index:9001;right:1%;top:2%";
		return appliedcss;
    }
	
	/* Initiate search on articles*/   
    handleOnchange( event ){
	   let validSearchStr = event.detail && event.detail.length>=3?true:false;
       if(validSearchStr){      
            getSearchedArticles({ objRecordId: '',searchKey : event.detail, isThroughSearch: true})
                .then((result) =>{
                     this.searchResults = JSON.parse(result);
                    
                }).catch(function(error){
                    console.log('in error..'+JSON.stringify(error));
                });
        }
        else {
            this.searchResults = [];
        }
    }
	
	/* Open the record as sub tab on click of any search result*/
    handleSelect(event){
        const selectedRecordId = event.detail;
        this.selectedRecord = this.searchResults.find( record => record.Id === selectedRecordId);      
        this.navigateToRecordViewPage(event);       
    }
	
    /* Open sub tab navigation*/
    navigateToRecordViewPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail,
                actionName: 'view'
            }
        });
		this.selectedRecord = undefined;
    }

    navigateToRecord(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.hoveredArticle.Id,
                actionName: 'view'
            }
        });
    }
    
}