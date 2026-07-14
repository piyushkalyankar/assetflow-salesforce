public with sharing class AssetController {
    public AssetController() {

    }

    @AuraEnabled
    public static String requestAsset(AssetRequestWrapper assetRequestWrapper){
        return AssetService.requestAsset(assetRequestWrapper);
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getActiveEmployees(){
        return AssetService.getActiveEmployees();
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset__c> getAvailableAssets(){
        return AssetService.getAvailableAssets();
    }
}