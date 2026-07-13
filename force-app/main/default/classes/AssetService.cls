public with sharing class AssetService {
    public AssetService() {

    }

    public static String requestAsset(AssetRequestWrapper assetRequestWrapper) {
        // Validate Employee
        Employee__c employee = validateEmployee(assetRequestWrapper.employeeId);

        // Validate Asset
        Asset__c asset = validateAsset(assetRequestWrapper.assetId);

        // Check Duplicate Request
        validateDuplicateRequest(assetRequestWrapper.employeeId, assetRequestWrapper.assetId);

        // Prepare Request Record
        Asset_Request__c assetRequest = buildAssetRequest(assetRequestWrapper);

        // Save Request
        saveRequest(assetRequest);

        // Return Created Record Id
        return assetRequest.Id;
    }

    private static Employee__c validateEmployee(Id employeeId) {
        Employee__c employee = AssetSelector.getEmployeeById(employeeId);
        if(employee == null){
            throw new AuraHandledException(System.label.Employee_Not_Found);
        }

        if(employee.Status__c == 'Inactive'){
            throw new AuraHandledException(System.label.Employee_Inactive);
        }

        if(employee.Manager__c == null){
            throw new AuraHandledException(System.label.Manager_Not_Assigned);
        }

        return employee;
    }

    private static Asset__c validateAsset(Id assetId){
        Asset__c asset = AssetSelector.getAssetById(assetId);
        if(asset == null){
            throw new AuraHandledException(System.label.Asset_Not_Found);
        }

        if(asset.Status__c != 'Available'){
            throw new AuraHandledException(System.label.Asset_Not_Available);
        }

        return asset;
    }

    private static void validateDuplicateRequest(Id employeeId, Id assetId){
        if(AssetSelector.hasPendingRequest(employeeId, assetId)){
            throw new AuraHandledException(System.label.Duplicate_Request);
        }
    }

    private static Asset_Request__c buildAssetRequest(AssetRequestWrapper assetRequestWrapper){
        Asset_Request__c assetRequest = new Asset_Request__c();
        assetRequest.Employee__c = assetRequestWrapper.employeeId;
        assetRequest.Asset__c = assetRequestWrapper.assetId;
        assetRequest.Priority__c = assetRequestWrapper.priority;
        assetRequest.Reason__c = assetRequestWrapper.reason;
        assetRequest.Status__c = 'Pending';
        assetRequest.Request_Date__c = System.today();
        return assetRequest;
    }

    private static void saveRequest(Asset_Request__c request){
        insert request;
    }
   
}