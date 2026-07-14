import { LightningElement , wire} from 'lwc';
import getPendingRequests from '@salesforce/apex/AssetController.getPendingRequests'
import updateRequestStatus from '@salesforce/apex/AssetController.updateRequestStatus'
import {refreshApex} from '@salesforce/apex'
export default class AssetDashboard extends LightningElement {
    requests = [];
    columns = [
        {
            label: 'Employee',
            fieldName: 'employeeName',
            type: 'text'
        },
        {
            label: 'Asset',
            fieldName: 'assetName',
            type: 'text'
        },
        {
            label: 'Priority',
            fieldName: 'Priority__c',
            type: 'text'
        },
        {
            label: 'Reason',
            fieldName: 'Reason__c',
            type: 'text'
        },
        {
            label: 'Request Date',
            fieldName: 'Request_Date__c',
            type: 'date'
        },
        {
            label: 'Status',
            fieldName: 'Status__c',
            type: 'text'
        },
        {
            type: 'button',
            fixedWidth: 120,
            typeAttributes: {
                label: 'Approve',
                name: 'approve',
                variant: 'success'
            }
        },
        {
            type: 'button',
            fixedWidth: 120,
            typeAttributes: {
                label: 'Reject',
                name: 'reject',
                variant: 'destructive'
            }
        }
    ];
    isLoading = false;
    requestResult;
    @wire(getPendingRequests)
    wiredRequests(result){
        this.requestResult = result;
        const {data , error } = result;
        if(data){
            this.requests = data.map((request) => {
                return {
                    employeeName: request.Employee__r.Name,
                    assetName: request.Asset__r.Name,
                    Priority__c: request.Priority__c,
                    Reason__c: request.Reason__c,
                    Request_Date__c: request.Request_Date__c,
                    Status__c: request.Status__c,
                    Id: request.Id
                }
            })
        }else{
            console.error(error)
        }
    }

    async handleRowAction(event) {
        this.isLoading = true;
        const actionName = event.detail.action.name
        const row = event.detail.row
        if (actionName === 'approve') {
            try{
                await updateRequestStatus({
                    requestId : row.Id , status : 'Approved'
                })
                await refreshApex(this.requestResult);
                this.showSuccessToast('Asset Request Approved Successfully');
            }catch(error){
                this.showErrorToast(error?.body?.message || 'Approval Failed');
            }finally{
                this.isLoading = false;
            }
          
        } else if (actionName === 'reject') {
            try{
                await updateRequestStatus({
                    requestId : row.Id , status : 'Rejected'
                })
                await refreshApex(this.requestResult);
                this.showSuccessToast('Asset Request Rejected Successfully');

            }catch(error){
                this.showErrorToast(error?.body?.message || 'Update Failed');
            }finally{
                this.isLoading = false;
            }
           
        }
    }


}