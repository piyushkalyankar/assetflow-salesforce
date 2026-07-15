import { LightningElement } from 'lwc';

import ASSET_OBJECT from '@salesforce/schema/Asset__c'
import NAME_FIELD from '@salesforce/schema/Asset__c.Name';
import TYPE_FIELD from '@salesforce/schema/Asset__c.Asset_Type__c';
import STATUS_FIELD from '@salesforce/schema/Asset__c.Status__c';
import COST_FIELD from '@salesforce/schema/Asset__c.Cost__c';
import PURCHASE_DATE_FIELD from '@salesforce/schema/Asset__c.Purchase_Date__c';
import SERIAL_FIELD from '@salesforce/schema/Asset__c.Serial_Number__c';
import STAUS_FIELD from '@salesforce/schema/Asset__c.Status__c'; 
import SERIAL_NUMBER_FIELD from '@salesforce/schema/Asset__c.Serial_Number__c';

export default class AssetModal extends LightningElement {
    objectApiName = ASSET_OBJECT;
    fields = [
        NAME_FIELD,
        TYPE_FIELD,
        STATUS_FIELD,
        COST_FIELD,
        PURCHASE_DATE_FIELD,
        SERIAL_FIELD,
        STAUS_FIELD,
        SERIAL_NUMBER_FIELD
    ];

    handleSuccess(event) {
        this.showAssetModal = false;
        this.showSuccessToast('Asset Created Successfully');
        this.dispatchEvent(new CustomEvent('assetsuccess'));
    }

    handleError(event) {
        this.showErrorToast('Error creating asset');
    }

    handleCloseModal() {
        const closeEvent  = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }
}