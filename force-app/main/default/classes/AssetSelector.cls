public with sharing class AssetSelector {
    public AssetSelector() {

    }

    public static Employee__c getEmployeeById(Id empployeeId){
        Employee__c employee = [SELECT Id, Name, Status__c, Manager__c FROM Employee__c WHERE Id = :empployeeId LIMIT 1];
        return employee;
    }

    public static Asset__c getAssetById(Id assetId){
        Asset__c asset = [SELECT Id, Name, Status__c FROM Asset__c WHERE Id = :assetId LIMIT 1];
        return asset;
    }

    public static Boolean hasPendingRequest(Id employeeId, Id assetId){
        List<Asset_Request__c> pendingRequests = [SELECT Id FROM Asset_Request__c WHERE Employee__c = :employeeId AND Asset__c = :assetId AND Status__c = :AssetConstants.REQUEST_STATUS_PENDING];
        return !pendingRequests.isEmpty();
    }
}