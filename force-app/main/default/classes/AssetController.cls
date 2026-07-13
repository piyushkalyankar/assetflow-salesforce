public with sharing class AssetController {
    public AssetController() {

    }

    @AuraEnabled
    public static String requestAsset(AssetRequestWrapper assetRequestWrapper){
        return AssetService.requestAsset(assetRequestWrapper);
    }
}