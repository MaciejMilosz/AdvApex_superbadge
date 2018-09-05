@isTest
private class OrderTests {

    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(5);
    }

    @IsTest
    static void orderExtension_unitTest() {
        PageReference pageRef = Page.OrderEdit;
        Test.setCurrentPage(pageRef);
        Order o = [SELECT Id, Status FROM Order LIMIT 1];
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(o);
        OrderExtension ext = new OrderExtension(stdcontroller);
        System.assertEquals(5, ext.orderItemList.size());
        ext.OnFieldChange();
        ext.SelectFamily();
        ext.Save();
        ext.First();
        ext.Next();
        ext.Previous();
        ext.Last();
        ext.GetHasPrevious();
        ext.GetHasNext();
        ext.GetTotalPages();
        ext.GetPageNumber();
        List<SelectOption> options = ext.GetFamilyOptions();
    }

    static testMethod void triggerTest(){
        Test.startTest();
        SetupTestData();
        List<Order> orders = [SELECT Id, Status FROM Order];
        for(Order o : orders){
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update orders;
        List<Product2> product2s = [SELECT Id, Quantity_Ordered__c FROM Product2];
        System.debug('-V- id: ' + product2s[0].Id + ' -V- ' + product2s[0].Quantity_Ordered__c);
        System.assert(product2s[0].Quantity_Ordered__c != 0);
        Test.stopTest();
    }

    static testMethod void OrderUpdate_UnitTest(){
        Test.startTest();
        List<Order> orders = [SELECT Id, Status FROM Order];
        List<Product2> product2s = [SELECT Id, Quantity_Ordered__c FROM Product2 ORDER BY Name ASC];
        for(Order o : orders){
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update orders;
        List<Product2> product2sAfterUpdate = [SELECT Id, Quantity_Ordered__c FROM Product2 ORDER BY Name ASC];
        for(Integer i = 0 ; i <= product2s.size()-1; i++){
            TestDataFactory.VerifyQuantityOrdered(product2s[i], product2sAfterUpdate[i], 5);
        }
        Test.stopTest();
    }
}