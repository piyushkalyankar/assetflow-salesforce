import { LightningElement, wire } from 'lwc';
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
        { label: 'Purchase Date', fieldName: 'purchaseDate', type: 'date', sortable: true }
    ];
    showAssetModal = false;
    sortedBy;
    sortedDirection = 'asc';

    @wire(getDashboardData)
    wiredDashboard({ data, error }) {
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
}