/* eslint-disable no-console */
import { LightningElement, api, wire, track } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getPicklistFieldValues from "@salesforce/apex/dh_CustomPicklist_WebController.getPicklistValues";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import picklistResource from '@salesforce/resourceUrl/dh_picklistConfiguration';

export default class DependantPicklists extends LightningElement {
  @api componentTitle; // It contains the title of the component.
  @api sObjectName; // Config JSON which we get from meta.xml, whcih should be configured while adding component to a page.
  @api picklistsConfig; // Config JSON which we get from meta.xml, whcih should be configured while adding component to a page.
  @api recordId; // To get current record Id
  fieldInfo = {}; // Field info which get from apex call
  fieldNameDetails = {}; // with field name as  key and all deatails of that field
  picklistFields = []; // pickfields array from picklistsConfig
  fieldsConfiguration = []; // which contain 'pickListConfiguration' of component's configuration JSON
  @track fieldDetails = []; // all vales of fieldNameDetails used in html
  selectedFieldValues = {}; // selected field and it's value
  objectData; //It contains object data which we get from 'getObjectInfo
  disableSaveButton = false;

  // Below wire method will be called onload of the component, and it gets values for the first picklist field in the picklistFields[] array
  @wire(getObjectInfo, { objectApiName: "$sObjectName" })
  objectInfo({ error, data }) {
    if (data) {
      this.objectData = data;
      if (this.picklistsConfig) {
        const cmpConfigJSON = JSON.parse(this.picklistsConfig);
        if (cmpConfigJSON.configuration.hasOwnProperty('pickListConfigurationFile') && cmpConfigJSON.configuration.pickListConfigurationFile) {
            //Reading configuration from Static resource
            const configurationURL = picklistResource+'/'+cmpConfigJSON.configuration.pickListConfigurationFile;
            let request = new XMLHttpRequest();
            request.open("GET", configurationURL, false);
            request.send(null);
            const configJSON = JSON.parse(request.responseText);
            this.fieldsConfiguration =
            configJSON.configuration.pickListConfiguration;
        }
        else if (cmpConfigJSON.configuration.hasOwnProperty('pickListConfiguration') && cmpConfigJSON.configuration.pickListConfiguration) {
            this.fieldsConfiguration =
            cmpConfigJSON.configuration.pickListConfiguration;
        }

        this.fieldsConfiguration.forEach((item) => {
          this.picklistFields.push(item.pickListApiName);
        });

        for (let index = 0; index < this.picklistFields.length; index++) {
          this.fieldNameDetails[this.picklistFields[index]] = {
            label: data.fields[this.picklistFields[index]].label,
            name: data.fields[this.picklistFields[index]].apiName,
            dataType: data.fields[this.picklistFields[index]].dataType,
            multiPicklist:
              data.fields[this.picklistFields[index]].dataType ==
              "MultiPicklist"
                ? true
                : false,
            picklist:
              data.fields[this.picklistFields[index]].dataType == "Picklist"
                ? true
                : false,
            disable: true
          };
        }
      }
      if (this.picklistFields) {
        this.getPicklistValues(0);
      }
    }
  }

  // Below handleChange function will be called on change of every picklist value and gets the values for the next picklist field.
  handleChange(event) {
    let selectedField = event.target.closest("[data-key]").dataset.key;
    this.fieldNameDetails[selectedField]["selectedValues"] = event.target.value;
    console.log("//|handleChange|//" + JSON.stringify(this.fieldNameDetails));
    let index = this.picklistFields.indexOf(selectedField);
    if (this.selectedFieldValues.hasOwnProperty(selectedField)) {
      this.selectedFieldValues[selectedField] = event.target.value;
      console.log(
        "----hasOwnProperty---" + JSON.stringify(this.selectedFieldValues)
      );
    } else {
      this.selectedFieldValues = {
        ...this.selectedFieldValues,
        ...{ [selectedField]: event.target.value }
      };
      console.log(
        "----NothasOwnProperty----" + JSON.stringify(this.selectedFieldValues)
      );
    }

    //Code to disable and clear all lower level fields which come after selected field (When user re-selects top-level field)
    let disableIndex = index + 1;
    while (disableIndex < this.picklistFields.length) {
      this.fieldNameDetails[this.picklistFields[disableIndex]]["values"] = [];
      this.fieldNameDetails[this.picklistFields[disableIndex]][
        "disable"
      ] = true;
      delete this.selectedFieldValues[this.picklistFields[disableIndex]];
      disableIndex++;
    }

    if (this.picklistFields.length > index + 1) {
      this.getPicklistValues(index + 1);
    }
  }

  //Helper method to call apex and get picklist values based on the rule engine
  getPicklistValues(index) {
    let selectedValues = [];

    this.objectData;
    for (var key in this.selectedFieldValues) {
      let selectedVal;
      if (this.objectData.fields[key].dataType == "MultiPicklist") {
        selectedVal = this.selectedFieldValues[key].toString();
      } else {
        selectedVal = this.selectedFieldValues[key];
      }
      selectedValues.push({
        field: key,
        value: selectedVal
      });
    }

    let inputToApex = {
      ...{ pickListConfiguration: this.fieldsConfiguration[index] },
      ...{ selectedPicklistValues: selectedValues },
      ...{ currentRecordId: this.recordId },
      ...{ picklistFieldAPIName: this.picklistFields[index] },
      ...{ sObjectName: this.sObjectName }
    };
    console.log("NEWNEW" + JSON.stringify(inputToApex));

    getPicklistFieldValues({
      jsonString: JSON.stringify(inputToApex)
    })
      .then((result) => {
        this.fieldInfo = JSON.parse(result);
        for (let key in this.fieldInfo) {
          if (this.fieldInfo[key].length != 0) {
            this.fieldNameDetails[key]["values"] = this.fieldInfo[key];
            this.fieldNameDetails[key]["disable"] = false;
          }
        }
        this.fieldDetails = Object.values(this.fieldNameDetails);
        console.log(
          "|||getPicklistValues|--|APEX==result|||" +
            JSON.stringify(this.fieldNameDetails)
        );
      })
      .catch((error) => {
        console.log(
          "|||getPicklistValues|--|APEX==error|||" +
            error.message +
            " stackTrace: " +
            error.stackTrace
        );
      });
  }

  //function to save the field, values to record
  saveFields() {
    this.disableSaveButton = true;
    let fieldsObj = { Id: this.recordId };
    for (let key in this.fieldNameDetails) {
      let fieldValue = "";
      if (this.selectedFieldValues[key]) {
        if (this.fieldNameDetails[key]["multiPicklist"] == true) {
          fieldValue = this.selectedFieldValues[key].join(";");
        } else {
          fieldValue = this.selectedFieldValues[key];
        }
      } else if (!this.fieldNameDetails[key]["disable"]) {
       this.dispatchEvent(
         new ShowToastEvent({
           title: "Please fill below fields",
           message: this.fieldNameDetails[key]["label"],
           variant: "error"
         })
       );
       this.disableSaveButton = false;
       return;
      }
      fieldsObj = {
        ...fieldsObj,
        ...{ [key]: fieldValue }
      };
    }
    let record = {
      fields: fieldsObj
    };
    updateRecord(record)
      .then(() => {
        this.disableSaveButton = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: this.sObjectName + " is updated",
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.disableSaveButton = false;
        let errorMsg = "";
        if (error.body.output.errors && error.body.output.errors.length > 0) {
          errorMsg = "Error: " + error.body.output.errors[0].message;
        } else if (error.body.output.fieldErrors) {
            for (const eachField of this.picklistFields) {
              if (error.body.output.fieldErrors.hasOwnProperty(eachField)) {
                errorMsg =
                  errorMsg +
                  error.body.output.fieldErrors[eachField][0].fieldLabel +
                  ": " +
                  error.body.output.fieldErrors[eachField][0].message;
              }
            }
        }else {
          errorMsg = "Error: " + error.body.message;
        }
        this.dispatchEvent(
          new ShowToastEvent({
            title: errorMsg,
            message: error,
            variant: "error"
          })
        );
      });
  }
}
