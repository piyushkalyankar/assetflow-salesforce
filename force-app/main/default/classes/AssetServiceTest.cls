@isTest
public with sharing class AssetServiceTest {
  
    @testSetup
    static void setupTestData(){
        Employee__c manager = TestDataFactory.createManager();
        Employee__c employee = TestDataFactory.createEmployee(manager.Id);
        Asset__c asset = TestDataFactory.createAsset();
    }

    @isTest
    static void testRequestAsset_Success(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = [SELECT Id FROM Asset__c WHERE Name = 'Test Asset' LIMIT 1];

        AssetRequestWrapper requestWrapper = new AssetRequestWrapper(employee.Id, asset.Id, 'High', 'Test Reason');
      
        requestWrapper.reason = 'Test Reason';

        Test.startTest();
        String requestId = AssetService.requestAsset(requestWrapper);
        Test.stopTest();
        Asset_Request__c assetRequest = [SELECT Id, Employee__c, Asset__c, Priority__c, Reason__c, Status__c FROM Asset_Request__c WHERE Id = :requestId LIMIT 1];
        System.assertNotEquals(null, requestId, 'Request ID should not be null');
        System.assertEquals('Pending', assetRequest.Status__c, 'Asset request status should be Pending');
        System.assertEquals(requestWrapper.employeeId, assetRequest.Employee__c, 'Employee ID should match');
        System.assertEquals(requestWrapper.assetId, assetRequest.Asset__c, 'Asset ID should match');
    }

    @isTest
    static void testInactiveEmployeeRequest(){
        Employee__c manager = TestDataFactory.createManager();
        Employee__c inactiveEmployee = TestDataFactory.createEmployee('Inactive', manager.Id);
        Asset__c asset = [SELECT Id FROM Asset__c WHERE Name = 'Test Asset' LIMIT 1];

        AssetRequestWrapper requestWrapper = new AssetRequestWrapper(inactiveEmployee.Id, asset.Id, 'High', 'Test Reason');

        Test.startTest();
        try {
            AssetService.requestAsset(requestWrapper);
            System.assert(false, 'Expected an exception for inactive employee');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected an AuraHandledException to be thrown');
        }
        Test.stopTest();
    }

    @isTest
    static void testManagerAssignment(){
        Employee__c employee = [Select Id From Employee__c WHERE Name = 'Test Manager' LIMIT 1];
        Asset__c asset = [SELECT Id FROM Asset__c WHERE Name = 'Test Asset' LIMIT 1];
        try{
            AssetRequestWrapper requestWrapper = new AssetRequestWrapper(employee.Id, asset.Id, 'High', 'Test Reason');
            Test.startTest();
            AssetService.requestAsset(requestWrapper);
            Test.stopTest();
            System.assert(false, 'Expected an exception for employee without manager');
        }
        catch(AuraHandledException e){
            System.assertNotEquals(null, e.getMessage(), 'Expected Manager Not Assigned exception');
        }
    }

    @isTest
    static void testAssetNotAvailableRequest(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c unavailableAsset = TestDataFactory.createAsset();
        unavailableAsset.Status__c = 'Assigned';
        update unavailableAsset;

        AssetRequestWrapper requestWrapper = new AssetRequestWrapper(employee.Id, unavailableAsset.Id, 'High', 'Test Reason');

        Test.startTest();
        try {
            AssetService.requestAsset(requestWrapper);
            System.assert(false, 'Expected an exception for unavailable asset');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected Asset Not Available exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testDuplicateRequest(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = [SELECT Id FROM Asset__c WHERE Name = 'Test Asset' LIMIT 1];

        TestDataFactory.createAssetRequest(employee.Id, asset.Id);

        AssetRequestWrapper requestWrapper = new AssetRequestWrapper(employee.Id, asset.Id, 'High', 'Test Reason');

        Test.startTest();
        try {
            AssetService.requestAsset(requestWrapper);
            System.assert(false, 'Expected an exception for duplicate request');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Expected Duplicate Request exception');
        }
        Test.stopTest();
    }
}