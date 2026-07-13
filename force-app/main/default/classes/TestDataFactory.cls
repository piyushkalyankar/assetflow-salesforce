@isTest
public with sharing class TestDataFactory {
    public static Employee__c createEmployee(){
        Employee__c employee = new Employee__c(
            Name = 'Test Employee',
            Status__c = 'Active',
            Manager__c = createManager().Id);
        insert employee;
        return employee;
    }

    public static Employee__c createEmployee(Id managerId){
        Employee__c employee = new Employee__c(
            Name = 'Test Employee',
            Status__c = 'Active',
            Manager__c = managerId);
        insert employee;
        return employee;       
    }

    public static Employee__c createEmployee(String status , Id managerId){
        Employee__c employee = new Employee__c(
            Name = 'Test Employee',
            Status__c = status,
            Manager__c = managerId
        );
        insert employee;
        return employee;
    }

    public static Employee__c createManager(){
        Employee__c manager = new Employee__c(
            Name = 'Test Manager',
            Status__c = 'Active'
        );
        insert manager;
        return manager;
    }

    public static Asset__c createAsset(){
        Asset__c asset = new Asset__c(
            Name = 'Test Asset',
            Status__c = 'Available'
        );
        insert asset;
        return asset;
    }

    public static Asset_Request__c createAssetRequest(Id employeeId, Id assetId){
        Asset_Request__c assetRequest = new Asset_Request__c(
            Employee__c = employeeId,
            Asset__c = assetId,
            Status__c = 'Pending'
        );
        insert assetRequest;
        return assetRequest;
    }
}