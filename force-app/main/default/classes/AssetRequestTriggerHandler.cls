public with sharing class AssetRequestTriggerHandler {
    public static void afterUpdate(List<Asset_Request__c> newList , Map<Id , Asset_Request__c> oldMap){
        AssetAllocationService.allocateAssets(newList, oldMap);
    }
      
}