@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        //TestDataFactory.InsertTestData(5);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Product2());
        Product2Extension ext = new Product2Extension(sc);
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());

        ext.addRows();
        System.assertEquals(Constants.DEFAULT_ROWS*2, ext.productsToInsert.size());
        for(Integer i = 0; i < 5; i++){
            ext.productsToInsert[i].productRecord.Name = 'dish';
            ext.productsToInsert[i].productRecord.Family = 'Side';
            ext.productsToInsert[i].productRecord.isActive = true;
            ext.productsToInsert[i].productRecord.Initial_Inventory__c = 5;
            ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 5;
        }
        ext.Save();
        List<Product2> product2s = [SELECT Id FROM Product2];
        System.assertEquals(5, product2s.size());
        System.assert(ext.GetInventory() != null);
        System.assert(ext.getFamilyOptions() != null);
        Test.stopTest();
    }

    @IsTest
    static void Product2Trigger_UnitTest(){
        Test.startTest();
        Product2 p = new Product2();
        p.Name = 'TestProduct';
        p.Family = 'Side';
        p.IsActive = true;
        p.Quantity_Ordered__c = 50;
        p.Initial_Inventory__c = 100;
        insert p;

        CollaborationGroup c = new CollaborationGroup();
        c.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        c.Description = 'test';
        c.CollaborationType = 'Public';
        insert c;

        p.Quantity_Ordered__c=96;
        update p;
        Test.stopTest();
    }

}