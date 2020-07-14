/*
 * MultiselectController synchronizes the values of the hidden elements to the
 * SelectOption lists.
 */
public with sharing class MultiselectController {
    // SelectOption lists for public consumption
    public SelectOption[] leftoptionsList { get; set; }
    public SelectOption[] rightOptionsList { get; set; }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        System.debug('options: '+options);
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftoptionsHidden { get; set {
           leftoptionsHidden = value;
           if(leftoptionsList!=null){
           setOptions(leftoptionsList, value);
           }
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           if(rightOptionsList!=null){
           setOptions(rightOptionsList, value);
            }
        }
    }
}