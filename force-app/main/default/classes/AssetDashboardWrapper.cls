public with sharing class AssetDashboardWrapper {
    @AuraEnabled
    public Integer totalAssets { get; set; }

    @AuraEnabled
    public Integer availableAssets { get; set; }

    @AuraEnabled
    public Integer allocatedAssets { get; set; }

    @AuraEnabled
    public Integer maintenanceAssets { get; set; }

    @AuraEnabled
    public List<Asset__c> assets { get; set; }

    public AssetDashboardWrapper() {
        this.totalAssets = 0;
        this.availableAssets = 0;
        this.allocatedAssets = 0;
        this.maintenanceAssets = 0;
        this.assets = new List<Asset__c>();
    }
}
