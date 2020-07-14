/* Sort on load */
function  sortList(pfieldName, pList){
    const fieldName = pfieldName;
    const key = (a) => {
        let fieldValue = a[fieldName] ? (typeof a[fieldName] === 'string' ? a[fieldName].toLowerCase() : a[fieldName]) : '';
       return fieldValue; 
    }
    let sortedList = JSON.parse(pList).sort((a,b) => {
        return ((key(a) > key(b)) - (key(b) > key(a)));
    });

    return sortedList;
}

/* Sort on click of down and up arrow */
/*Note: The reason for having two different methods is the parsing process*/
function  sortOnClick(fieldName, sortDirection, pListToSort){
    let sortedList ;
     /** serialize the data before calling sort function **/
    let data = JSON.parse(JSON.stringify(pListToSort));
          
    /** Return the value stored in the field **/
    const key = (a) => {
        let fieldValue = a[fieldName] ? (typeof a[fieldName] === 'string' ? a[fieldName].toLowerCase() : a[fieldName]) : '';
       return fieldValue; 
    }
     /** cheking reverse direction **/ 
    let reverse = sortDirection === 'asc' ? 1: -1;

    /** sorting data and set sorted data to agents attribute**/
    sortedList = data.sort((a,b) => {
        return reverse * ((key(a) > key(b)) - (key(b) > key(a)));
    });

    return sortedList;
}

export { sortList, sortOnClick };