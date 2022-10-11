@isTest
private class testUpdateAccountCA {
    @testSetup static void createData() {
        // create the accounts
        Account acc1 = new Account(Name = 'Test Account 1',Phone = '0101010101');
        insert acc1;
    }

    @isTest static void updateAccountCAForOneAccountWithMoreThanHundredOrders() {

       // create one account with a CA of 0
       Account acc = TestDataFactory.createAccount(0);

       // Insert a test product.
       Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');

       // Create a custom price book
       Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
       
       // Create a price book entry with a custom price.
       Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

       // create 200 orders of for the account with shipmentcost of 10
       List<Order> orders = TestDataFactory.createOrdersOnAccount(acc.Id, 200, customPBId, 10);

       // create orderItems on each order with quantity of 1O and unitPrice of 100
       List<OrderItem> orderItems = TestDataFactory.createOrderItemsOnOrders(orders, 10, 100, customPBEId);

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