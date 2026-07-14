public with sharing class AssetController {
    public AssetController() {

    }

    @AuraEnabled
    public static String requestAsset(Map<String, Object> assetRequest) {
        Id employeeId = (Id) assetRequest.get('employeeId');
        Id assetId = (Id) assetRequest.get('assetId');
        String priority = (String) assetRequest.get('priority');
        String reason = (String) assetRequest.get('reason');

        AssetRequestWrapper wrapper = new AssetRequestWrapper(employeeId, assetId, priority, reason);
        return AssetService.requestAsset(wrapper);
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getActiveEmployees(){
        return AssetService.getActiveEmployees();
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset__c> getAvailableAssets(){
        return AssetService.getAvailableAssets();
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset_Request__c> getPendingRequests(){
        return AssetService.getPendingRequests();
    }

    @AuraEnabled
    public static void updateRequestStatus(Id requestId, String status){
        AssetService.updateRequestStatus(requestId , status);
    }
}