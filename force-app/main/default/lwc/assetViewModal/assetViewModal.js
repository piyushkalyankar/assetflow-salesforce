import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ASSET_OBJECT from '@salesforce/schema/Asset__c';
import NAME_FIELD from '@salesforce/schema/Asset__c.Name';
import TYPE_FIELD from '@salesforce/schema/Asset__c.Asset_Type__c';
import STATUS_FIELD from '@salesforce/schema/Asset__c.Status__c';
import PURCHASE_DATE_FIELD from '@salesforce/schema/Asset__c.Purchase_Date__c';
import COST_FIELD from '@salesforce/schema/Asset__c.Cost__c';
import SERIAL_NUMBER_FIELD from '@salesforce/schema/Asset__c.Serial_Number__c';

export default class AssetViewModal extends LightningElement {
    @api recordId;

    objectApiName = ASSET_OBJECT;
    nameField = NAME_FIELD;
    typeField = TYPE_FIELD;
    statusField = STATUS_FIELD;
    purchaseDateField = PURCHASE_DATE_FIELD;
    costField = COST_FIELD;
    serialNumberField = SERIAL_NUMBER_FIELD;

    handleClose() {
        this.dispatchEvent(new CustomEvent('modalclose'));
    }
}
