public with sharing class AssetService {
    
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

        if(employee.Status__c == AssetConstants.EMPLOYEE_STATUS_INACTIVE){
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

        if(asset.Status__c != AssetConstants.ASSET_STATUS_AVAILABLE){
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
        assetRequest.Status__c = AssetConstants.REQUEST_STATUS_PENDING;
        assetRequest.Request_Date__c = System.today();
        return assetRequest;
    }

    private static void saveRequest(Asset_Request__c request){
        upsert request;
    }

    public static List<Employee__c> getActiveEmployees(){
        return AssetSelector.getActiveEmployees();
    }

    public static List<Asset__c> getAvailableAssets(){
        return AssetSelector.getAvailableAssets();
    }

    public static List<Asset_Request__c> getPendingRequests(){
        return AssetSelector.getPendingRequests();
    }

    public static void updateRequestStatus(Id requestId, String status){
        Asset_Request__c request = AssetSelector.getRequestById(requestId);
        validateRequest(request);
        updateRequest(request, status);
        saveRequest(request);
    }

    private static void validateRequest(Asset_Request__c request){
        if(request == null){
            throw new AuraHandledException(
                System.Label.Request_Not_Found
            );
        }

        if(request.Status__c != AssetConstants.REQUEST_STATUS_PENDING){
            throw new AuraHandledException(
                System.Label.Request_Already_Processed
            );
        }
    }

    private static void updateRequest(Asset_Request__c request,String status){
        request.Status__c = status;
        request.Approved_By__c = UserInfo.getUserId();
        request.Approval_Date__c = System.today();
    }

}