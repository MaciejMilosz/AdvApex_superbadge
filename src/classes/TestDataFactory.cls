/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        cg.CollaborationType = 'Public';
        return cg;
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> retList = new List<Product2>();
        List<String> pFamily = new List<String>();
        for(Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY){
            pFamily.add(ple.getValue());
        }
        for(Integer i = 0; i < cnt; i++){
            Product2 p = new Product2();
            p.Name = 'test_' + String.valueOf(i);
            p.IsActive = true;
            p.Initial_Inventory__c = 10;
            if(i >= pFamily.size()){
                p.Family = pFamily[0];
            }else {
                p.Family = pFamily[i];
            }
            retList.add(p);
        }
        return retList;
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> retList = new List<PricebookEntry>();
        for(Product2 p : prods){
            PricebookEntry pe = new PricebookEntry();
            pe.IsActive = true;
            pe.Product2Id = p.Id;
            pe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pe.UnitPrice = Integer.valueOf(Math.random()*10);
            retList.add(pe);
        }
        return retList;
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> retList = new List<Account>();
        for(Integer i = 0 ; i < cnt; i++){
            Account a = new Account();
            a.Name = 'Acme#' + String.valueOf(i);
            retList.add(a);
        }
        return retList;
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> retList = new List<Contact>();
        for(Integer i = 0; i< cnt; i++){
            Contact c = new Contact();
            c.FirstName = 'Bob#' + String.valueOf(i);
            c.LastName ='Johnson#' + String.valueOf(i);
            c.AccountId = accts[i].Id;
            retList.add(c);
        }
        return retList;
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> retList = new List<Order>();
        for(Integer i = 0; i< cnt; i++){
            Order o = new Order();
            o.Name = 'order#'+String.valueOf(i);
            o.Status = 'Draft';
            o.EffectiveDate = System.today();
            o.AccountId = accts[i].Id;
            o.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            retList.add(o);
        }
        return retList;
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        List<OrderItem> retList = new List<OrderItem>();
        for(Integer i = 0; i< cnt; i++){
            OrderItem oi = new OrderItem();
            oi.PricebookEntryId = pbes[i].Id;
            oi.OrderId = ords[i].Id;
            oi.Quantity = Constants.DEFAULT_ROWS;
            oi.UnitPrice = 5;
            retList.add(oi);
        }
        return retList;
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        List<Product2> product2s = TestDataFactory.ConstructProducts(cnt);
        insert product2s;
        List<PricebookEntry> pricebookentries = TestDataFactory.ConstructPricebookEntries(product2s);
        insert pricebookentries;
        List<Account> accounts = TestDataFactory.ConstructAccounts(cnt);
        insert accounts;
        List<Contact> contacts = TestDataFactory.ConstructContacts(cnt, accounts);
        insert contacts;
        List<Order> orders = TestDataFactory.ConstructOrders(cnt, accounts);
        insert orders;
        List<OrderItem> items = TestDataFactory.ConstructOrderItems(cnt, pricebookentries, orders);
        insert items;
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.

    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered);
    }


}