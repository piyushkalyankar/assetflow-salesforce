import { LightningElement, wire } from 'lwc';
import getActiveEmployees from '@salesforce/apex/AssetController.getActiveEmployees';
import getAvailableAssets from '@salesforce/apex/AssetController.getAvailableAssets';


export default class AssetRequestForm extends LightningElement {
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

    handleChange(event){
        this.assetRequest[event.target.name] = event.detail.value;
    }

    handleSubmit(){

    }

}