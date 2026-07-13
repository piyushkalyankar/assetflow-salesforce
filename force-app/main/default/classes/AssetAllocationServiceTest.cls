@isTest
public with sharing class AssetAllocationServiceTest {
    
    @testSetup
    static void setupTestData(){
        Employee__c manager = TestDataFactory.createManager();
        Employee__c employee = TestDataFactory.createEmployee(manager.Id);
    }

    /**
     * Test 1: Successful asset allocation on request approval
     * Scenario: Request transitions from PENDING to APPROVED
     * Expected: Asset status updated to ALLOCATED and history record created
     */
    @isTest
    static void testSuccessfulAssetAllocation(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = TestDataFactory.createAsset();
        Asset_Request__c request = TestDataFactory.createAssetRequest(employee.Id, asset.Id);

        Test.startTest();
        request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        request.Approval_Remarks__c = 'Approved for deployment';
        update request;
        Test.stopTest();

        // Verify asset status was updated
        Asset__c updatedAsset = [SELECT Status__c FROM Asset__c WHERE Id = :asset.Id LIMIT 1];
        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, updatedAsset.Status__c, 'Asset status should be ALLOCATED');

        // Verify history record was created
        Asset_History__c history = [SELECT Id, Old_Status__c, New_Status__c, Remarks__c FROM Asset_History__c WHERE Asset__c = :asset.Id LIMIT 1];
        System.assertNotEquals(null, history.Id, 'History record should be created');
        System.assertEquals(AssetConstants.ASSET_STATUS_AVAILABLE, history.Old_Status__c, 'Old status should be from asset');
        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, history.New_Status__c, 'New status should be ALLOCATED');
        System.assertEquals('Approved for deployment', history.Remarks__c, 'Remarks should match');
    }

    /**
     * Test 2: Request with null asset reference
     * Scenario: Asset_Request__c has null Asset__c field
     * Expected: Request should be skipped, no allocation occurs
     */
    @isTest
    static void testRequestWithNullAsset(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset_Request__c request = new Asset_Request__c(
            Employee__c = employee.Id,
            Asset__c = null,
            Status__c = AssetConstants.REQUEST_STATUS_PENDING
        );
        insert request;

        Test.startTest();
        request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        update request;
        Test.stopTest();

        // Verify no history records were created
        List<Asset_History__c> historyRecords = [SELECT Id FROM Asset_History__c WHERE Asset_Request__c = :request.Id];
        System.assertEquals(0, historyRecords.size(), 'No history should be created for null asset');
    }

    /**
     * Test 3: Request status not transitioning to APPROVED
     * Scenario: Request status changes but not to APPROVED (e.g., PENDING -> REJECTED)
     * Expected: No asset allocation occurs
     */
    @isTest
    static void testRequestStatusNotApproved(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = TestDataFactory.createAsset();
        Asset_Request__c request = TestDataFactory.createAssetRequest(employee.Id, asset.Id);

        Test.startTest();
        request.Status__c = 'Rejected';
        update request;
        Test.stopTest();

        // Verify asset status was not updated
        Asset__c unchangedAsset = [SELECT Status__c FROM Asset__c WHERE Id = :asset.Id LIMIT 1];
        System.assertEquals(AssetConstants.ASSET_STATUS_AVAILABLE, unchangedAsset.Status__c, 'Asset status should remain AVAILABLE');

        // Verify no history record was created
        List<Asset_History__c> historyRecords = [SELECT Id FROM Asset_History__c WHERE Asset__c = :asset.Id];
        System.assertEquals(0, historyRecords.size(), 'No history should be created for non-approved request');
    }

    /**
     * Test 4: Request already in APPROVED status (no transition)
     * Scenario: Request status is already APPROVED before update
     * Expected: No allocation occurs (only transitions trigger allocation)
     */
    @isTest
    static void testRequestAlreadyApproved(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = TestDataFactory.createAsset();
        Asset_Request__c request = new Asset_Request__c(
            Employee__c = employee.Id,
            Asset__c = asset.Id,
            Status__c = AssetConstants.REQUEST_STATUS_APPROVED
        );
        insert request;

        Test.startTest();
        request.Approval_Remarks__c = 'Updated remarks';
        update request;
        Test.stopTest();

        // Verify asset status was not updated
        Asset__c unchangedAsset = [SELECT Status__c FROM Asset__c WHERE Id = :asset.Id LIMIT 1];
        System.assertEquals(AssetConstants.ASSET_STATUS_AVAILABLE, unchangedAsset.Status__c, 'Asset should not be allocated');

        // Verify no history record was created
        List<Asset_History__c> historyRecords = [SELECT Id FROM Asset_History__c WHERE Asset__c = :asset.Id];
        System.assertEquals(0, historyRecords.size(), 'No history should be created for non-transition');
    }

    /**
     * Test 5: Multiple requests in single batch
     * Scenario: Multiple PENDING requests approved in same transaction
     * Expected: All assets allocated and history records created for each
     */
    @isTest
    static void testMultipleRequestsInBatch(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset1 = TestDataFactory.createAsset();
        Asset__c asset2 = TestDataFactory.createAsset();
        Asset__c asset3 = TestDataFactory.createAsset();

        Asset_Request__c request1 = TestDataFactory.createAssetRequest(employee.Id, asset1.Id);
        Asset_Request__c request2 = TestDataFactory.createAssetRequest(employee.Id, asset2.Id);
        Asset_Request__c request3 = TestDataFactory.createAssetRequest(employee.Id, asset3.Id);

        Test.startTest();
        request1.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        request2.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        request3.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        update new List<Asset_Request__c>{request1, request2, request3};
        Test.stopTest();

        // Verify all assets were allocated
        List<Asset__c> allocatedAssets = [SELECT Status__c FROM Asset__c WHERE Id IN :new List<Id>{asset1.Id, asset2.Id, asset3.Id}];
        System.assertEquals(3, allocatedAssets.size(), 'All three assets should exist');
        for(Asset__c asset : allocatedAssets){
            System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, asset.Status__c, 'All assets should be ALLOCATED');
        }

        // Verify all history records were created
        List<Asset_History__c> historyRecords = [SELECT Asset__c FROM Asset_History__c WHERE Asset__c IN :new List<Id>{asset1.Id, asset2.Id, asset3.Id}];
        System.assertEquals(3, historyRecords.size(), 'Three history records should be created');
    }

    /**
     * Test 6: Null approval remarks
     * Scenario: Approval_Remarks__c field is null during allocation
     * Expected: Allocation succeeds with null remarks in history
     */
    @isTest
    static void testAllocationWithNullRemarks(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = TestDataFactory.createAsset();
        Asset_Request__c request = TestDataFactory.createAssetRequest(employee.Id, asset.Id);

        Test.startTest();
        request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        request.Approval_Remarks__c = null;
        update request;
        Test.stopTest();

        // Verify asset was allocated
        Asset__c updatedAsset = [SELECT Status__c FROM Asset__c WHERE Id = :asset.Id LIMIT 1];
        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, updatedAsset.Status__c, 'Asset should be ALLOCATED');

        // Verify history record was created with null remarks
        Asset_History__c history = [SELECT Remarks__c FROM Asset_History__c WHERE Asset__c = :asset.Id LIMIT 1];
        System.assertEquals(null, history.Remarks__c, 'Remarks should be null');
    }

    /**
     * Test 7: History record captures correct audit information
     * Scenario: Verify all history record fields are populated correctly
     * Expected: Asset, Employee, Request, Timestamp, and Status fields match request data
     */
    @isTest
    static void testHistoryRecordAuditInfo(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = TestDataFactory.createAsset();
        Asset_Request__c request = TestDataFactory.createAssetRequest(employee.Id, asset.Id);

        Test.startTest();
        request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        request.Approval_Remarks__c = 'Test approval';
        update request;
        Test.stopTest();

        // Verify history record contains correct relationships
        Asset_History__c history = [
            SELECT Asset__c, Employee__c, Asset_Request__c, Changed_By__c, Changed_On__c, Old_Status__c, New_Status__c
            FROM Asset_History__c 
            WHERE Asset__c = :asset.Id 
            LIMIT 1
        ];

        System.assertEquals(asset.Id, history.Asset__c, 'Asset reference should match');
        System.assertEquals(employee.Id, history.Employee__c, 'Employee reference should match');
        System.assertEquals(request.Id, history.Asset_Request__c, 'Request reference should match');
        System.assertNotEquals(null, history.Changed_By__c, 'Changed_By should be set to user ID');
        System.assertNotEquals(null, history.Changed_On__c, 'Changed_On timestamp should be set');
        System.assertEquals(AssetConstants.ASSET_STATUS_AVAILABLE, history.Old_Status__c, 'Old status should be from previous asset status');
        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, history.New_Status__c, 'New status should be ALLOCATED');
    }

    /**
     * Test 8: Empty request list
     * Scenario: Trigger fired with empty newList (edge case)
     * Expected: No queries or DML operations occur
     */
    @isTest
    static void testEmptyRequestList(){
        Test.startTest();
        // Call with empty list
        AssetAllocationService.allocateAssets(new List<Asset_Request__c>(), new Map<Id, Asset_Request__c>());
        Test.stopTest();

        // Verify no history records were created
        List<Asset_History__c> historyRecords = [SELECT Id FROM Asset_History__c];
        System.assertEquals(0, historyRecords.size(), 'No history should be created for empty list');
    }

    /**
     * Test 9: Asset status tracking in history
     * Scenario: Asset with non-standard initial status
     * Expected: History captures the actual previous asset status
     */
    @isTest
    static void testHistoryTracksAssetStatus(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        Asset__c asset = new Asset__c(
            Name = 'Pre-allocated Asset',
            Status__c = 'In Maintenance'
        );
        insert asset;

        Asset_Request__c request = new Asset_Request__c(
            Employee__c = employee.Id,
            Asset__c = asset.Id,
            Status__c = AssetConstants.REQUEST_STATUS_PENDING
        );
        insert request;

        Test.startTest();
        request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        update request;
        Test.stopTest();

        // Verify history captures the "In Maintenance" status
        Asset_History__c history = [SELECT Old_Status__c FROM Asset_History__c WHERE Asset__c = :asset.Id LIMIT 1];
        System.assertEquals('In Maintenance', history.Old_Status__c, 'Old status should be the asset\'s previous status');
    }

    /**
     * Test 10: Bulk update performance
     * Scenario: Large batch of requests processed simultaneously
     * Expected: All updates succeed within governor limits
     */
    @isTest
    static void testBulkProcessing(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        
        List<Asset__c> assets = new List<Asset__c>();
        List<Asset_Request__c> requests = new List<Asset_Request__c>();

        // Create 100 assets and requests
        for(Integer i = 0; i < 100; i++){
            Asset__c asset = new Asset__c(
                Name = 'Bulk Asset ' + i,
                Status__c = AssetConstants.ASSET_STATUS_AVAILABLE
            );
            assets.add(asset);
        }
        insert assets;

        for(Asset__c asset : assets){
            Asset_Request__c request = new Asset_Request__c(
                Employee__c = employee.Id,
                Asset__c = asset.Id,
                Status__c = AssetConstants.REQUEST_STATUS_PENDING
            );
            requests.add(request);
        }
        insert requests;

        Test.startTest();
        for(Asset_Request__c request : requests){
            request.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;
        }
        update requests;
        Test.stopTest();

        // Verify all assets were allocated
        List<Asset__c> allocatedAssets = [SELECT Status__c FROM Asset__c WHERE Name LIKE 'Bulk Asset%'];
        System.assertEquals(100, allocatedAssets.size(), 'All 100 assets should be found');
        for(Asset__c asset : allocatedAssets){
            System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, asset.Status__c, 'All assets should be ALLOCATED');
        }

        // Verify all history records were created
        Integer historyCount = [SELECT COUNT() FROM Asset_History__c WHERE Asset__c IN (SELECT Id FROM Asset__c WHERE Name LIKE 'Bulk Asset%')];
        System.assertEquals(100, historyCount, '100 history records should be created');
    }

    /**
     * Test 11: Mixed transitions in batch
     * Scenario: Batch with mix of status transitions and non-transitions
     * Expected: Only approved transitions are processed
     */
    @isTest
    static void testMixedTransitionsInBatch(){
        Employee__c employee = [SELECT Id FROM Employee__c WHERE Name = 'Test Employee' LIMIT 1];
        
        Asset__c asset1 = TestDataFactory.createAsset();
        Asset__c asset2 = TestDataFactory.createAsset();
        Asset__c asset3 = TestDataFactory.createAsset();

        Asset_Request__c request1 = TestDataFactory.createAssetRequest(employee.Id, asset1.Id);
        Asset_Request__c request2 = TestDataFactory.createAssetRequest(employee.Id, asset2.Id);
        Asset_Request__c request3 = TestDataFactory.createAssetRequest(employee.Id, asset3.Id);

        Test.startTest();
        request1.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;  // Will allocate
        request2.Status__c = 'Rejected';                              // Won't allocate
        request3.Status__c = AssetConstants.REQUEST_STATUS_APPROVED;  // Will allocate
        update new List<Asset_Request__c>{request1, request2, request3};
        Test.stopTest();

        // Verify selective allocation
        Asset__c allocatedAsset1 = [SELECT Status__c FROM Asset__c WHERE Id = :asset1.Id LIMIT 1];
        Asset__c rejectedAsset2 = [SELECT Status__c FROM Asset__c WHERE Id = :asset2.Id LIMIT 1];
        Asset__c allocatedAsset3 = [SELECT Status__c FROM Asset__c WHERE Id = :asset3.Id LIMIT 1];

        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, allocatedAsset1.Status__c, 'Asset 1 should be allocated');
        System.assertEquals(AssetConstants.ASSET_STATUS_AVAILABLE, rejectedAsset2.Status__c, 'Asset 2 should remain available');
        System.assertEquals(AssetConstants.ASSET_STATUS_ALLOCATED, allocatedAsset3.Status__c, 'Asset 3 should be allocated');

        // Verify only 2 history records were created
        Integer historyCount = [SELECT COUNT() FROM Asset_History__c WHERE Asset__c IN :new List<Id>{asset1.Id, asset2.Id, asset3.Id}];
        System.assertEquals(2, historyCount, 'Only 2 history records should be created');
    }
}