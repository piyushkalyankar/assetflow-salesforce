import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ASSET_OBJECT from '@salesforce/schema/Asset__c';
import ID_FIELD from '@salesforce/schema/Asset__c.Id';
import NAME_FIELD from '@salesforce/schema/Asset__c.Name';
import TYPE_FIELD from '@salesforce/schema/Asset__c.Asset_Type__c';
import STATUS_FIELD from '@salesforce/schema/Asset__c.Status__c';
import PURCHASE_DATE_FIELD from '@salesforce/schema/Asset__c.Purchase_Date__c';
import COST_FIELD from '@salesforce/schema/Asset__c.Cost__c';
import SERIAL_NUMBER_FIELD from '@salesforce/schema/Asset__c.Serial_Number__c';

export default class AssetEditModal extends LightningElement {
    @api recordId;

    objectApiName = ASSET_OBJECT;
    fields = {
        id: ID_FIELD,
        name: NAME_FIELD,
        type: TYPE_FIELD,
        status: STATUS_FIELD,
        purchaseDate: PURCHASE_DATE_FIELD,
        cost: COST_FIELD,
        serialNumber: SERIAL_NUMBER_FIELD
    };
    isSaving = false;
    isLoaded = false;

    handleClose() {
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    async handleSave() {
        const fields = this.template.querySelector('lightning-record-edit-form');
        if (!fields) {
            return;
        }

        this.isSaving = true;
        try {
            const recordInput = { fields: { Id: this.recordId } };
            const formFields = this.template.querySelectorAll('lightning-input-field');
            formFields.forEach((field) => {
                const fieldName = field.fieldName;
                const value = field.value;
                recordInput.fields[fieldName] = value;
            });

            await updateRecord(recordInput);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Asset updated successfully',
                variant: 'success'
            }));
            this.dispatchEvent(new CustomEvent('saved'));
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Unable to update asset',
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }
}
