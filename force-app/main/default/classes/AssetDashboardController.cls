public with sharing class AssetDashboardController {
    @AuraEnabled(cacheable=true)
    public static AssetDashboardWrapper getDashboardData() {
        AssetDashboardWrapper wrapper = new AssetDashboardWrapper();

        List<Asset__c> assets = [
            SELECT Id, Name, Asset_Type__c, Status__c, Cost__c, Purchase_Date__c, Serial_Number__c
            FROM Asset__c
        ];

        wrapper.assets = assets;
        wrapper.totalAssets = assets.size();

        for (Asset__c assetRecord : assets) {
            if (assetRecord.Status__c == AssetConstants.ASSET_STATUS_AVAILABLE) {
                wrapper.availableAssets++;
            } else if (assetRecord.Status__c == AssetConstants.ASSET_STATUS_ALLOCATED) {
                wrapper.allocatedAssets++;
            } else if (assetRecord.Status__c == AssetConstants.ASSET_STATUS_ASSIGNED) {
                wrapper.allocatedAssets++;
            } else {
                wrapper.maintenanceAssets++;
            }
        }

        return wrapper;
    }
}
