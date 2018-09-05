/**
 * @name orderTrigger
 * @description
**/
trigger OrderTrigger on Order (after update) {
    if(Trigger.new != null && Trigger.isAfter && Trigger.isUpdate) {
        try {
            OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
        } catch (Exception e) {
            System.debug('-V- exc: ' + e.getMessage() + ' | ' + e.getStackTraceString());
        }
    }
}