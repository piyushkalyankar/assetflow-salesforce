import { LightningElement, wire } from 'lwc';
import getEmployeeDashboard from '@salesforce/apex/EmployeeDashboardController.getEmployeeDashboard';
import { createElement } from 'lwc';

export default class EmployeeDashboard extends LightningElement {

    dashboardData = {
        totalRequests : null,
        pendingRequests:null,
        approvedRequests:null,
        rejectedRequests:null
    };
    dassboardResult;
    requests = [];
    allRequests = [];
    columns = [
        {
            label: 'Employee',
            fieldName: 'employeeName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Asset',
            fieldName: 'assetName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Priority',
            fieldName: 'priority',
            type: 'text',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Request Date',
            fieldName: 'requestDate',
            type: 'date'
        },
        {
            label: 'Reason',
            fieldName: 'reason',
            type: 'text'
        }
    ];
    searchKey = '';
    sortedBy;
    sortedDirection = 'asc';
    showModal = false;

    @wire(getEmployeeDashboard)
    wiredDashboard(result) {
        this.dassboardResult = result;
        const {data , error} = result
        if (data) {
            this.dashboardData = data;
            this.allRequests = data.requests.map(request => {
                return {
                    Id: request.Id,
                    employeeName: request.Employee__r.Name,
                    assetName: request.Asset__r.Name,
                    priority: request.Priority__c,
                    status: request.Status__c,
                    requestDate: request.Request_Date__c,
                    reason: request.Reason__c
                };
            });
            this.requests = [...this.allRequests];
        } else if (error) {
            console.error(error);
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.requests = this.allRequests.filter(request => {
            return request.employeeName.toLowerCase().includes(this.searchKey) ||
                   request.assetName.toLowerCase().includes(this.searchKey) ||
                   request.priority.toLowerCase().includes(this.searchKey) ||
                   request.status.toLowerCase().includes(this.searchKey) ||
                   request.reason.toLowerCase().includes(this.searchKey);
        });
    }

    handleSort(event) {

        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;

        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;

        let cloneData = [...this.requests];

        cloneData.sort((a, b) => {

            let valueA = a[fieldName] || '';
            let valueB = b[fieldName] || '';

            if (valueA > valueB) {
                return sortDirection === 'asc' ? 1 : -1;
            }

            if (valueA < valueB) {
                return sortDirection === 'asc' ? -1 : 1;
            }

            return 0;
        });

        this.requests = cloneData;
    }

    handleRequestAsset() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleRequestSuccess() {
        this.closeModal();
        this.refreshDashboard();
    }

    refreshDashboard() {
        if (this.dassboardResult?.refresh) {
            this.dassboardResult.refresh();
        }
    }
}