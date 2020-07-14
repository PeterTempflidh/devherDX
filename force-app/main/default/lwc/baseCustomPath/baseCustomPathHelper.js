import { evaluatePathRules, processActions } from './baseCustomPathRuleProcessor.js';

/**
 * Generate a list containing all the info needed to render the path according to set of conditions given
 * @param {String} pickListFieldName - The name of the picklist that generates the stages on the path (ie. Opportunity)
 * @param {Map} recordData - The current record data with the fields requested for the query
 * @param {Array} allPickListFieldValues - The target HTML table (ie. [New,Open,...])
 * @param {Map} extraConfigurationsString - The map containing all the configurations of the path.
 * @return {Array} - The structure of the path to be rendered.
 */
function buildPath( pickListFieldName, recordData, allPickListFieldValues, extraConfigurationsString ){

    let pathStages = [];

    let extraConfigurations = extraConfigurationsString ? JSON.parse( extraConfigurationsString ) : {};

    if( !allFieldsAreReady( recordData, allPickListFieldValues ) ){
        return pathStages;
    }
    console.info('All the values are ready to process the picklist information');

    let approvedPickListValues = getApprovedPickListValues( recordData, extraConfigurations, allPickListFieldValues );
    let stages = buildStageStructure( pickListFieldName, recordData, approvedPickListValues );

    if( extraConfigurations.closingStage ){
        stages = processClosingStage( stages, extraConfigurations.closingStage );
    }

    return stages;
}

function allFieldsAreReady( recordData, allPickListFieldValues ){

    let checkRecordData = recordData && Object.keys(recordData).length > 0;
    let checkPickListFieldValues = allPickListFieldValues && Object.keys( allPickListFieldValues ).length > 0;
    let ready = checkPickListFieldValues && checkRecordData;

    return ready;
}

function getApprovedPickListValues( recordData, extraConfigurations, allPickListFieldValues ){

    let approvedPickListValues = [];

    let selectedRules = extraConfigurations ? evaluatePathRules( recordData, extraConfigurations ) : [] ;
    let approvedPickListApiNames = approvedPickListValues.concat( processActions( selectedRules ) );
    approvedPickListValues = approvedPickListValues.concat( retrievePickListData( approvedPickListApiNames, allPickListFieldValues ) );

    return approvedPickListValues;
}

function buildStageStructure( pickListFieldName, recordData, approvedPickListValues ){

    let stages = [];

    let nextStagesIncomplete = false;
    for( const [ index, pickListValue ] of approvedPickListValues.entries() ){

        let isCurrentStage = recordData.fields[ pickListFieldName ].value === pickListValue.value;

        let newStage = {

            index: index,
            name: pickListValue.label,
            apiname: pickListValue.value,
            status: isCurrentStage,
            statusLabel: getStatusLabel( isCurrentStage, nextStagesIncomplete ),
            classScheme: getClassScheme( isCurrentStage, nextStagesIncomplete )
        }

        if( !newStage.apiname ){
            console.warn('The apiname for the following picklist value contains an error', pickListValue );
        }

        let fromHereAllOtherStagesAreOpen = isCurrentStage && !nextStagesIncomplete;
        if( fromHereAllOtherStagesAreOpen ){
            nextStagesIncomplete = true;
        }

        stages.push( newStage );
    }

    return stages;
}

function processClosingStage( stages, closingStageConfigurations ){

    let stagesWithClosing = stages;

    let currentStage = stages.find( x => x.status === true );

    if( currentStage.apiname === closingStageConfigurations.successStageApiName ){

        stagesWithClosing = manageSuccessStage( stages, closingStageConfigurations );

    } else if ( currentStage.apiname === closingStageConfigurations.failureStageApiName ){

        stagesWithClosing = manageFailureStage( stages, closingStageConfigurations );

    } else {

        stagesWithClosing = manageNormalStage( stages, closingStageConfigurations );
    }

    return stagesWithClosing;
}

function manageSuccessStage( stages, closingStageConfigurations ){

    let failureStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.failureStageApiName );

    if( failureStageIndex >= 0 ){
        stages.splice( failureStageIndex, 1 );
    }

    let successStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.successStageApiName );

    if( successStageIndex >= 0  ){
        let successStage = stages[successStageIndex];
        successStage.classScheme = 'slds-path__item slds-is-won slds-is-active slds-is-current';
    }

    return stages;
}

function manageFailureStage( stages, closingStageConfigurations ){

    let successStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.successStageApiName );

    if( successStageIndex >= 0  ){
        stages.splice( successStageIndex, 1 );
    }

    for( const stage of stages ){
        stage.classScheme = getClassScheme( false, true );
    }

    let failureStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.failureStageApiName );

    if( failureStageIndex >= 0  ){
        let failureStage = stages[failureStageIndex];
        failureStage.classScheme = 'slds-path__item slds-is-lost slds-is-active slds-is-current';
    }

    return stages;
}

function manageNormalStage( stages, closingStageConfigurations ){

    let failureStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.failureStageApiName );

    if( failureStageIndex >= 0  ){
        stages.splice( failureStageIndex, 1 );
    }

    let successStageIndex = stages.findIndex( x => x.apiname === closingStageConfigurations.successStageApiName );

    if( successStageIndex >= 0 ){
        let successStage = stages[successStageIndex];
        let truncatedLabel = successStage.name.split(" ")[0];
        successStage.name = truncatedLabel;
    }

    return stages;
}

function getStatusLabel( isCurrentStage, nextStagesIncomplete ){

    let statusLabel = 'Stage Completed';

    if( nextStagesIncomplete ){
        statusLabel = 'Open';
    } else if( isCurrentStage ){
        statusLabel = 'Current Stage';
    }

    return statusLabel;
}

function getClassScheme( isCurrentStage, nextStagesIncomplete ){

    let cssClassNames = 'slds-path__item slds-is-complete';

    if( nextStagesIncomplete ){
        cssClassNames = 'slds-path__item slds-is-incomplete';
    } else if( isCurrentStage ){
        cssClassNames = 'slds-path__item slds-is-current slds-is-active';
    }

    return cssClassNames;
}

function retrievePickListData( approvedPickListApiNames, allPickListFieldValues ){

    let matchedPickListData = [];

    let allPickListFieldValueMap = {};
    for( const pickListFieldValue of allPickListFieldValues ){
        allPickListFieldValueMap[ `${pickListFieldValue.value}` ] = pickListFieldValue;
    }

    for( const pickListApiName of approvedPickListApiNames ){
        if( allPickListFieldValueMap[ pickListApiName ] && pickListApiName === allPickListFieldValueMap[ pickListApiName ].value ){
            matchedPickListData.push( allPickListFieldValueMap[ pickListApiName ] );
        } else {
            console.warn(`The value ${pickListApiName} does not have a match in the general picklist API name list`);
        }
    }

    return matchedPickListData;
}

/**
 * It will return a list of field names prefixed with the name of the sobjectname from a string with comma separated values.
 * (ie. ( Opportunity, "New,Open" ) => ["Opportunity.New", "Opportunity.Open"] )
 * @param {String} sobjectName - The name of the sobject that needs to be prefixed (ie. Opportunity)
 * @param {Map} recordFieldListString - The field names in a comman separated string
 * @return {Array} - The list of fields prefixed by their sobject.
 */
function getRecordFieldsList( sobjectName, recordFieldListString ){

    let recordFieldList = [];

    let splitRecordFieldList = recordFieldListString ? recordFieldListString.split(",") : [];
    for( const field of splitRecordFieldList ){
        recordFieldList.push( `${sobjectName}.${field}` );
    }

    return recordFieldList;
}

/**
 * This method handles the error obtained in the controller.
 * @param {Map} error - The error map
 */
function handleError( error ){
    console.error('The error is => ', error);
}

export { buildPath, handleError, getRecordFieldsList };