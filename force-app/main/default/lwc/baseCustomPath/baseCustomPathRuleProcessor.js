/**
 * Evaluates the rules in the configuration and returns the activated list.
 * @param {Map} recordData - The current record data with the fields requested for the query
 * @param {Map} extraConfigurationsString - The map containing all the configurations of the path.
 * @return {Array} - The list of activated rules given the rules in the configuration.
 */
function evaluatePathRules( recordData, extraConfigurations ){

    let selectedRules = [];

    let haveValidConfigurations = extraConfigurations && Object.keys( extraConfigurations ).length > 0;
    if( !haveValidConfigurations ){
        return selectedRules;
    }

    for( const rule of extraConfigurations.rules ){
        if( evaluateRule( recordData, rule ) ){
            selectedRules.push( rule );
        }
    }

    if( selectedRules.length === 0 ){
        console.warn('No rules were activated');
    }

    return selectedRules;
}

function evaluateRule( recordData, rule ){

    let evaluation = false;

    let fieldName = rule.condition.field;
    let operator = rule.condition.operator;
    let fieldValue = rule.condition.value;

    let recordFieldValue = getFieldValue( recordData, fieldName );

    if( executeOperation( operator, recordFieldValue, fieldValue ) ){
        evaluation = true;
    }

    return evaluation;
}

function getFieldValue( recordData, fieldName ){

    let nestedFields = fieldName.split(".");
    let resultObject = recordData;

    for( const nestedField of nestedFields ){

        if( !resultObject ){
            console.warn(`The field ${nestedField} does not contain a value`, resultObject );
            break;
        }

        resultObject = resultObject.fields[ nestedField ].value;
    }

    let fieldValue = resultObject ? resultObject : '';

    return fieldValue;
}

function executeOperation( operatorType, value1, value2 ){

    console.log(`Operation => ${value1} ${operatorType} ${value2}`);

    let result;

    switch( operatorType ){

        case '=':
            result = value1 === value2;
            break;
        case '>':
            result = value1 > value2;
            break;
        case '<':
            result = value1 < value2;
            break;
        case 'inIgnoreCase':
            result = value2.toLowerCase().includes(value1.toLowerCase());
            break;

        default:
            throw new Error('WARNING: This operator does not exist');
    }

    return result;
}

/**
 * Based on the selected rules this method will process those actions in order to build the approved list of picklist values.
 * @param {Array} selectedRules - The list of activated rules
 */
function processActions( selectedRules ){

    let uniquePartialPickListValues =  new Set();

    for( const rule of selectedRules ){
        uniquePartialPickListValues = applyAction( rule.action, uniquePartialPickListValues );
    }

    let selectedPicklistApiValues = [...uniquePartialPickListValues];

    return selectedPicklistApiValues;
}

function applyAction( action, getPickListForRule ){

    let uniquePartialPickListValues = new Set();

    switch( action.operator ){

        case 'show':
            uniquePartialPickListValues = new Set(action.values.split(','));
            uniquePartialPickListValues = getPickListForRule.size > 0  ? returnIntersection( uniquePartialPickListValues, getPickListForRule ) : uniquePartialPickListValues;
            break;

        default:
            console.warn(`The operator ${action.operator} is not supported at the moment`);
    }

    return uniquePartialPickListValues;
}

function returnIntersection( set1, set2 ){

    let intersectionSet = new Set();

    for( const element of set1 ){
        if( set2.has( element ) ){
            intersectionSet.add( element );
        }
    }

    return intersectionSet;
}

export { evaluatePathRules, processActions };