import { LightningElement, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDashboardData from '@salesforce/apex/AssetDashboardController.getDashboardData';

export default class AdminDashboard extends LightningElement {
    totalAssets = 0;
    availableAssets = 0;
    allocatedAssets = 0;
    maintenanceAssets = 0;
    searchKey = '';
    assets = [];
    allAssets = [];
    columns = [
        { label: 'Asset Name', fieldName: 'assetName', type: 'text', sortable: true },
        { label: 'Asset Type', fieldName: 'assetType', type: 'text', sortable: true },
        { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
        { label: 'Cost', fieldName: 'cost', type: 'currency', sortable: true },
        { label: 'Purchase Date', fieldName: 'purchaseDate', type: 'date', sortable: true },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];
    showAssetModal = false;
    showViewModal = false;
    showEditModal = false;
    showDeleteConfirm = false;
    selectedRecordId;
    sortedBy;
    sortedDirection = 'asc';
    isDeleting = false;

    wiredDashboardResult;

    @wire(getDashboardData)
    wiredDashboard(result) {
        this.wiredDashboardResult = result;
        const { data, error } = result;
        if (data) {
            this.totalAssets = data.totalAssets ?? 0;
            this.availableAssets = data.availableAssets ?? 0;
            this.allocatedAssets = data.allocatedAssets ?? 0;
            this.maintenanceAssets = data.maintenanceAssets ?? 0;
            this.allAssets = (data.assets || []).map((asset) => ({
                Id: asset.Id,
                assetName: asset.Name,
                assetType: asset.Asset_Type__c,
                status: asset.Status__c,
                cost: asset.Cost__c,
                purchaseDate: asset.Purchase_Date__c
            }));
            this.assets = [...this.allAssets];
        } else if (error) {
            console.error(error);
        }
    }

    handleNewAsset() {
        this.showAssetModal = true;
    }

    handleCloseModal() {
        this.showAssetModal = false;
        this.showViewModal = false;
        this.showEditModal = false;
        this.showDeleteConfirm = false;
        this.selectedRecordId = undefined;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedRecordId = row.Id;

        switch (actionName) {
            case 'view':
                this.showViewModal = true;
                this.showEditModal = false;
                break;
            case 'edit':
                this.showEditModal = true;
                this.showViewModal = false;
                break;
            case 'delete':
                this.selectedRecordId = row.Id;
                this.showDeleteConfirm = true;
                break;
            default:
                break;
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.assets = this.allAssets.filter((asset) => {
            return (
                asset.assetName?.toLowerCase().includes(this.searchKey) ||
                asset.assetType?.toLowerCase().includes(this.searchKey) ||
                asset.status?.toLowerCase().includes(this.searchKey)
            );
        });
    }

    handleSort(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;

        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;

        const sortedData = [...this.assets];
        sortedData.sort((a, b) => {
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

        this.assets = sortedData;
    }

    async handleDelete(recordId) {
        this.isDeleting = true;
        try {
            await deleteRecord(recordId);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Asset deleted successfully',
                variant: 'success'
            }));
            this.refreshDashboard();
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Unable to delete asset',
                variant: 'error'
            }));
        } finally {
            this.isDeleting = false;
            this.showDeleteConfirm = false;
            this.selectedRecordId = undefined;
        }
    }

    confirmDelete() {
        if (this.selectedRecordId) {
            this.handleDelete(this.selectedRecordId);
        }
    }

    refreshDashboard() {
        this.allAssets = [];
        this.assets = [];
        this.totalAssets = 0;
        this.availableAssets = 0;
        this.allocatedAssets = 0;
        this.maintenanceAssets = 0;
        this.searchKey = '';
        this.selectedRecordId = undefined;
        this.showViewModal = false;
        this.showEditModal = false;
        this.showAssetModal = false;
        this.showDeleteConfirm = false;
        this.sortedBy = undefined;
        this.sortedDirection = 'asc';

        if (this.wiredDashboardResult?.refresh) {
            this.wiredDashboardResult.refresh();
        }
    }

    handleAssetSaved() {
        this.handleCloseModal();
        this.refreshDashboard();
    }
}