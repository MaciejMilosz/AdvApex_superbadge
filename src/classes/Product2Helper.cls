public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    public static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncment = new List<Product2>();
        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String, Inventory_Setting__mdt> inventorySettingMap = new Map<String, Inventory_Setting__mdt>();
        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for(Inventory_Setting__mdt is : [SELECT Id, DeveloperName, Low_Quantity_Alert__c FROM Inventory_Setting__mdt]){
            inventorySettingMap.put(is.DeveloperName, is);
        }
        //ToDo: Loop through the Products in newList
        // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
        // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
        //      add it to the needsAnnouncement list
        for(Product2 p : newList){
            if(p.Initial_Inventory__c - p.Quantity_Ordered__c < inventorySettingMap.get(p.Family).Low_Quantity_Alert__c){
                needsAnnouncment.add(p);
            }
        }
        //ToDo: Pass records to the postAlerts method
        System.debug('-V- needsAnnouncment size: ' + needsAnnouncment.size());
        PostAlerts(needsAnnouncment);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
            // expires in a day
            // does not notify users via email.
            // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
            ConnectApi.MessageBodyInput mbi = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            mbi.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            textSegmentInput.text = p.Name + Constants.INVENTORY_LEVEL_LOW;
            mbi.messageSegments.add(textSegmentInput);

            ConnectApi.AnnouncementInput ai = new ConnectApi.AnnouncementInput();
            ai.sendEmails = false;
            ai.expirationDate = System.today()+1;
            ai.body = mbi;
            //ai.parentId = COLLABORATION_GROUP[0].Id;
            toPost.add(ai);
        }
        System.debug('-V- toPost: ' + toPost);
        AnnouncementQueueable q = new AnnouncementQueueable();
        q.toPost = toPost;
        System.enqueueJob(q);
//        AnnouncementQueueable.PostAnnouncements(toPost);

        //AnnouncementQueueable aq = new AnnouncementQueueable();

        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
    }
}