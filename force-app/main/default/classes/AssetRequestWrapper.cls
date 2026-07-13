public with sharing class AssetRequestWrapper {
    public Id employeeId;
    public Id assetId;
    public String priority;
    public String reason;
    
    public AssetRequestWrapper(Id employeeId, Id assetId, String priority, String reason) {
        this.employeeId = employeeId;
        this.assetId = assetId;
        this.priority = priority;
        this.reason = reason;

    }
}