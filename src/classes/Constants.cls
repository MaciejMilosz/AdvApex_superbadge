/**
 * Created by mmilo on 9/4/2018.
 */

public with sharing class Constants {
    public static final Integer DEFAULT_ROWS = 5;
    public static final String SELECT_ONE = System.Label.Select_One;
    public static final String INVENTORY_LEVEL_LOW = System.Label.Inventory_level_low;
    public static final List<Schema.PicklistEntry > PRODUCT_FAMILY = Product2.Family.getDescribe().getPicklistValues();
    public static final String DRAFT_ORDER_STATUS = 'Draft';
    public static final String ACTIVATED_ORDER_STATUS = 'Activated';
    public static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    public static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    public static final Id STANDARD_PRICEBOOK_ID = '01s1t0000022QxNAAU';
}