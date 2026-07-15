public with sharing class EmployeeDashboardController {
   @AuraEnabled(cacheable=true)
    public static EmployeeDashboardWrapper getEmployeeDashboard() {

        EmployeeDashboardWrapper wrapper = new EmployeeDashboardWrapper();

        List<Asset_Request__c> requests = EmployeeDashboardSelector.getAllRequests();

        wrapper.requests = requests;
        wrapper.totalRequests = requests.size();

        for (Asset_Request__c request : requests) {

            if (request.Status__c == AssetConstants.REQUEST_STATUS_PENDING) {
                wrapper.pendingRequests++;
            }
            else if (request.Status__c == AssetConstants.REQUEST_STATUS_APPROVED) {
                wrapper.approvedRequests++;
            }
            else if (request.Status__c == AssetConstants.REQUEST_STATUS_REJECTED) {
                wrapper.rejectedRequests++;
            }
        }

        return wrapper;
    }
}