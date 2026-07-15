public with sharing class EmployeeDashboardWrapper {
     @AuraEnabled
    public Integer totalRequests = 0;

    @AuraEnabled
    public Integer pendingRequests = 0;

    @AuraEnabled
    public Integer approvedRequests = 0;

    @AuraEnabled
    public Integer rejectedRequests = 0;

    @AuraEnabled
    public List<Asset_Request__c> requests;
}