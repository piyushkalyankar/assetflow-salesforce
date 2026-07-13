public with sharing class AssetAllocationService {
    public static void allocateAssets(List<Asset_Request__c> newList, Map<Id, Asset_Request__c> oldMap){
        List<Asset__c> assetToUpdate = new List<Asset__c>();
        List<Asset_History__c> assetHistoryToInsert = new List<Asset_History__c>();
        Set<Id> assetIds = new Set<Id>();

        for(Asset_Request__c request : newList){
            if(request.Asset__c != null){
                assetIds.add(request.Asset__c);
            }
        }

        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>([SELECT Id, Status__c FROM Asset__c WHERE Id IN :assetIds]);

        for(Asset_Request__c request : newList){
            Asset_Request__c oldRequest = oldMap.get(request.Id);
            
            if( request.Asset__c != null && 
                oldRequest.Status__c == AssetConstants.REQUEST_STATUS_PENDING && 
                request.Status__c == AssetConstants.REQUEST_STATUS_APPROVED){
                
                Asset__c asset = new Asset__c(
                    Id = request.Asset__c,
                    Status__c = AssetConstants.ASSET_STATUS_ALLOCATED
                );
                assetToUpdate.add(asset);

                Asset_History__c assetHistory = new Asset_History__c(
                    Asset__c = request.Asset__c,
                    Employee__c = request.Employee__c,
                    Asset_Request__c = request.Id,
                    Changed_On__c = System.now(),
                    Changed_By__c = UserInfo.getUserId(),
                    Old_Status__c = assetMap.get(request.Asset__c).Status__c,
                    New_Status__c = AssetConstants.ASSET_STATUS_ALLOCATED,
                    Remarks__c = request.Approval_Remarks__c 
                );
                assetHistoryToInsert.add(assetHistory);
            }
        }
    
        if(!assetToUpdate.isEmpty()){
            update assetToUpdate;
        }
        if(!assetHistoryToInsert.isEmpty()){
            insert assetHistoryToInsert;
        }
    }
}