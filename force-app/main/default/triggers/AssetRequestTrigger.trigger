trigger AssetRequestTrigger on Asset_Request__c (before insert , after update) {
    if(Trigger.operationType == TriggerOperation.AFTER_UPDATE){
        AssetRequestTriggerHandler.afterUpdate(Trigger.new , Trigger.oldMap);
    }
}