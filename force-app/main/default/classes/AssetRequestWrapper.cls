public with sharing class AssetRequestWrapper {
    @AuraEnabled public Id employeeId;
    @AuraEnabled public Id assetId;
    @AuraEnabled public String priority;
    @AuraEnabled public String reason;

    public AssetRequestWrapper() {}

    public AssetRequestWrapper(Id employeeId, Id assetId, String priority, String reason) {
        this.employeeId = employeeId;
        this.assetId = assetId;
        this.priority = priority;
        this.reason = reason;
    }
}