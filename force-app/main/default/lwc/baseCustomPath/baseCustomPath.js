import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { buildPath, handleError, getRecordFieldsList } from './baseCustomPathHelper.js';

export default class BaseCustomPath extends LightningElement {

    @api recordId;
    @api sObjectName;
    @api pickListFieldName;
    @api hasStatusCompleteButton;
    @api recordFieldsToQuery;
    @api extraConfigurations;

    @track recordFieldsToQueryList = [];
    @track allPickListFieldValues = [];
    @track pathStageConfigurations = {};
    @track recordData = {};
    @track pathStages = [];
    @track masterRecordTypeId = '';
    @track pickListFieldNameForWire = '';

    get getHasStatusCompleteButton(){
        let hasStatusCompleteButton = this.hasStatusCompleteButton ? this.hasStatusCompleteButton : false;
        return hasStatusCompleteButton;
    }

    @wire(getObjectInfo, { objectApiName: '$sObjectName' })
    handleObjectMetadata( { error, data } ){

        if( error || !data ){
            handleError(error);
            return;
        }

        let selectedRecordType = Object.values( data.recordTypeInfos ).find( recordType => recordType.master === true );
        this.masterRecordTypeId = selectedRecordType.recordTypeId;
        this.pathStages = buildPath( this.pickListFieldName, this.recordData, this.allPickListFieldValues, this.extraConfigurations );
    }

    @wire(getPicklistValues, { recordTypeId: '$masterRecordTypeId', fieldApiName: '$pickListFieldNameForWire' })
    handleObjectPicklistData( { error, data } ){

        if( error || !data ){
            handleError(error);
            return;
        }

        this.allPickListFieldValues = this.allPickListFieldValues.concat( data.values );
        this.pathStages = buildPath( this.pickListFieldName, this.recordData, this.allPickListFieldValues, this.extraConfigurations );
    }

    @wire( getRecord, { recordId: '$recordId', fields: '$recordFieldsToQueryList' } )
    handleRecordData( { error, data } ){

        if( error || !data ){
            handleError(error);
            return;
        }

        this.recordData = data;
        this.pathStages = buildPath( this.pickListFieldName, this.recordData, this.allPickListFieldValues, this.extraConfigurations );
    }

    connectedCallback(){
        this.recordFieldsToQuery = `${this.recordFieldsToQuery},${this.pickListFieldName}`;
        this.recordFieldsToQueryList = getRecordFieldsList( this.sObjectName, this.recordFieldsToQuery );
        this.pickListFieldNameForWire = `${this.sObjectName}.${this.pickListFieldName}`;
    }
}