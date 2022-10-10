@isTest
private class testUpdateAccountCA {
    @testSetup static void createData() {
        // create the accounts
        Account acc1 = new Account(Name = 'Test Account 1',Phone = '0101010101');
        insert acc1;
    }

    @isTest static void updateAccountCAForOneAccountWithMoreThanHundredOrders() {
        // create the account
        Account acc = new Account(Name = 'Test Account',Phone = '0000000000');
        acc.Chiffre_d_affaires__c = 0;
        insert acc;

        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Chemise Verte longue XYX', 
            Family = 'Chemise');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 100, IsActive = true);
        insert customPrice;

        // create 200 orders of 10*100 for the account
        List<Order> orders = new List<Order>();  
        for (Integer i=0;i<200;i++) {
            orders.add(new Order(AccountId = acc.Id,EffectiveDate = Date.newInstance(2022,10,01), Status ='Draft', Pricebook2Id = customPB.Id));
        }
        insert orders;
        List<OrderItem> orderItems = new List<OrderItem>();  
        for (Order ord : orders) {
            orderItems.add(new OrderItem (OrderId = ord.Id, Quantity=10, PricebookEntryId = customPrice.Id, UnitPrice = 100));
        }
        insert orderItems;

        // change quantity in orderItems
        for (OrderItem orditem : orderItems) {
            orditem.Quantity = 20;
        }
        update orderItems;
        
        Test.startTest();
        update orders;
        Test.stopTest();
        Account newAcc = [SELECT Id, Chiffre_d_affaires__c FROM Account WHERE Id = :acc.Id];
        // 200 orders * 20 orderitems * 100 € = 400000 €
        System.assertEquals(400000,newAcc.Chiffre_d_affaires__c,'Le CA est erroné');
    }
}