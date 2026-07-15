public with sharing class EmployeeDashboardSelector {
    public static List<Asset_Request__c> getAllRequests(){
        return [ SELECT Id,
                Asset__c,
                Asset__r.Name,
                Employee__c,
                Employee__r.Name,
                Status__c,
                Priority__c,
                Reason__c,
                Request_Date__c
            FROM Asset_Request__c
            ORDER BY Request_Date__c DESC];
    }
}