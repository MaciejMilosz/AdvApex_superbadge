/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    public Integer offset {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<Id,OrderItem>();
        offset = 0;
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        changeStandardSetControllerQuery();
        for(OrderItem oi : orderRecord.OrderItems){
            orderItemMap.put(oi.Product2Id, oi);
        }
        orderItemListData();
        countPieData();
    }

    public void changeStandardSetControllerQuery(){
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c FROM PricebookEntry WHERE IsActive = TRUE';
        if (String.isNotBlank(selectedFamily) && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        query += ' ORDER BY Name';
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    public void orderItemListData(){
        orderItemList = new List<OrderItem>();
        for(SObject obj : standardSetController.getRecords()){
            System.debug('-V- obj: ' + obj);
            PricebookEntry pe = (PricebookEntry) obj;
            if(orderItemMap.containsKey(pe.Product2Id)){
                orderItemList.add(orderItemMap.get(pe.Product2Id));
            }else{
                OrderItem oi = new OrderItem();
                oi.PricebookEntryId = pe.Id;
                oi.Product2Id = pe.Product2Id;
                oi.Product2 = pe.Product2;
                oi.UnitPrice = pe.UnitPrice;
                oi.Quantity = 0;
                orderItemList.add(oi);
                orderItemMap.put(pe.Product2Id, oi);
            }
        }
    }
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection


    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        for(OrderItem oi : orderItemList){
            orderItemMap.put(oi.Product2Id, oi);
        }
        //      and populate pieData
        //      and populate total

        countPieData();
    }

    public void countPieData(){
        System.debug('-V- old piedata: ' + pieData);
        System.debug('-V- old total: ' + total);
        pieData = new List<ChartHelper.ChartData>();
        total = 0;
        for(OrderItem oi : orderItemMap.values()){
            if(oi.Quantity > 0) {
                pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.UnitPrice * oi.Quantity));
                total += oi.UnitPrice * oi.Quantity;
            }
        }
        System.debug('-V- new piedata: ' + pieData);
        System.debug('-V- new total: ' + total);
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        changeStandardSetControllerQuery();
        orderItemListData();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        System.Savepoint sp = Database.setSavepoint();
        try{
            if(orderRecord.Pricebook2Id == null)
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            upsert orderRecord;
            List<OrderItem> toUpsert = new List<OrderItem>();
            List<OrderItem> toDelete = new List<OrderItem>();
            for(OrderItem oi : orderItemList){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null) {
                        oi.OrderId = orderRecord.Id;
                    }
                    toUpsert.add(oi);
                }else if(oi.Id != null){
                    toDelete.add(oi);
                }
            }
            if(!toUpsert.isEmpty())
                upsert toUpsert;
            if(!toDelete.isEmpty())
                delete toDelete;
        }catch (Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }

    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        orderItemListData();
    }

    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        orderItemListData();
    }

    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        orderItemListData();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        orderItemListData();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer) Math.ceil(standardSetController.getResultSize()/(Decimal) Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> retList = new List<SelectOption>();
        retList.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            retList.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return retList;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }
}