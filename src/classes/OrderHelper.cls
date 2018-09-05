public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS){
                orderIds.add(newList[i].Id);
            }
        }
        if(!orderIds.isEmpty()){
            RollUpOrderItems(orderIds);
        }
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        Set<Id> prodIds = new Set<Id>();
        for(OrderItem oi : [SELECT Id, Product2Id FROM OrderItem WHERE OrderId IN :activatedOrderIds]){
            //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
            prodIds.add(oi.Product2Id);
        }
        System.debug('-V- prodIds: ' + prodIds);
        productMap = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN :prodIds]);
        for(AggregateResult ar : [SELECT Product2Id, SUM(Quantity) q FROM OrderItem WHERE Product2Id IN :productMap.keySet() AND Order.Status = :Constants.ACTIVATED_ORDER_STATUS GROUP BY Product2Id]){
            Id prodId = (Id) ar.get('Product2Id');
            Product2 prod = productMap.get(prodId);
            System.debug('-V- id: ' + prod.Id + '  q = ' + Integer.valueOf(ar.get('q')));
            prod.Quantity_Ordered__c = Integer.valueOf(ar.get('q'));
            productMap.put(prodId, prod);
        }
        if(!productMap.isEmpty()){
            update productMap.values();
        }

        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset

        //ToDo: Perform an update on the records in the productMap
    }

}