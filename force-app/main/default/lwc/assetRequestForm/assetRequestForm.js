import { LightningElement, wire } from 'lwc';
import BaseComponent from 'c/baseComponent';
import getActiveEmployees from '@salesforce/apex/AssetController.getActiveEmployees';
import getAvailableAssets from '@salesforce/apex/AssetController.getAvailableAssets';
import requestAsset from '@salesforce/apex/AssetController.requestAsset';

export default class AssetRequestForm extends BaseComponent {
    assetRequest = {
        employeeId: null,
        assetId: null,
        priority: '',
        reason: ''
    };
    employeeOptions=[];
    assetOptions=[];
    priorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];
    get isSubmitDisabled() {
        return !(
            this.assetRequest.employeeId &&
            this.assetRequest.assetId &&
            this.assetRequest.priority &&
            this.assetRequest.reason?.trim()
        );
    }
    isLoading = false;

    @wire(getActiveEmployees)
    wiredEmployees({ data, error }) {
        if (data) {
           this.employeeOptions = data.map((employee) => {
            return {
                label: employee.Name,
                value: employee.Id
            }
           })
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getAvailableAssets)
    wiredAssets({data , error}){
        if(data){
            this.assetOptions = data.map((asset) => {
                return {
                    label:asset.Name,
                    value:asset.Id
                }
            })
        }else{
            console.error(error);
        }
    }

    handleChange(event) {
        this.assetRequest = {
            ...this.assetRequest,
            [event.target.name]: event.detail.value
        };
    }

    async handleSubmit() {
        this.isLoading = true;
        try {
            const requestId = await requestAsset({
                assetRequest: this.assetRequest
            });
            this.showSuccessToast('Asset Request Created Successfully');
            this.resetForm();
        } catch (error) {
            this.showErrorToast(error?.body?.message || 'Request failed');
        } finally {
            this.isLoading = false;
        }
    }

    resetForm(){
         this.assetRequest = {
            employeeId: null,
            assetId: null,
            priority: '',
            reason: ''
        };
    }

}