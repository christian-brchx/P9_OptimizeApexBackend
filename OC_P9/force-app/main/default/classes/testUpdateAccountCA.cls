@isTest
private class testUpdateAccountCA {

    @testSetup static void createData() {
       // Insert a test product.
       Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
       // Create a custom price book
       Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
       // Create a price book entry with a custom price.
       Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

       // create one account with a CA of 0 and 200 orders of 10 * 100
       Account acc200 = TestDataFactory.createAccount('Test Account 200 orders',0);
       // create 200 orders for the account with shipmentcost of 10
       List<Order> orders200 = TestDataFactory.createOrdersOnAccount(acc200.Id, 200, customPBId, 10);
       // create orderItems on each order with quantity of 1O and unitPrice of 100
       List<OrderItem> orderItems200 = TestDataFactory.createOrderItemsOnOrders(orders200, 10, 100, customPBEId);

       // create one account with a CA of 0 and 10 orders
       Account acc10 = TestDataFactory.createAccount('Test Account 10 orders',0);
       // create 10 orders for the account with shipmentcost of 10
       List<Order> orders10 = TestDataFactory.createOrdersOnAccount(acc10.Id, 10, customPBId, 10);
       // create orderItems on each order with quantity of 1O and unitPrice of 100
       List<OrderItem> orderItems10 = TestDataFactory.createOrderItemsOnOrders(orders10, 10, 100, customPBEId);
    }

    @isTest static void updateAccountCAForMoreThanHundredOrders() {
        // Get the Account
        Account acc200 = [SELECT Id FROM Account WHERE Name = 'Test Account 200 orders'];
        // Get the orders of the account
        Map<Id,Order> mapOrders = new Map<Id,Order>([SELECT Id FROM Order WHERE AccountId = :acc200.Id]);
        Set<Id> ordersId = mapOrders.keySet();
        // Get the orderItemsof the orders
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId IN :ordersId];
        // change quantity in orderItems
        for (OrderItem orditem : orderItems) {
            orditem.Quantity = 20;
        }
        update orderItems;
        
        Test.startTest();
        update mapOrders.values();
        Test.stopTest();
        Account newAcc200 = [SELECT Id, Chiffre_d_affaires__c FROM Account WHERE Id = :acc200.Id];
        // 200 orders * 20 orderitems * 100 € = 400000 €
        System.assertEquals(400000,newAcc200.Chiffre_d_affaires__c,'Le CA est erroné');
    }

    @isTest static void updateAccountCAForTwoAccounts() {
        // Get the Account 200
        Account acc200 = [SELECT Id FROM Account WHERE Name = 'Test Account 200 orders'];
        // Get the Account 10
        Account acc10 = [SELECT Id FROM Account WHERE Name = 'Test Account 10 orders'];
        
        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();

        // Get one order of Account 200
        orders.add([SELECT Id FROM Order WHERE AccountId = :acc200.Id LIMIT 1]);
        // Get the orderItem of the order
        orderItems.add([SELECT Id, Quantity FROM OrderItem WHERE OrderId = :orders[0].Id]);

        // Get one order of Account 10
        orders.add([SELECT Id FROM Order WHERE AccountId = :acc10.Id LIMIT 1]);
        // Get the orderItem of the order
        orderItems.add([SELECT Id, Quantity FROM OrderItem WHERE OrderId = :orders[1].Id]);

        // change quantity in orderItems
        for (OrderItem orditem : orderItems) {
            orditem.Quantity = 20;
        }
        update orderItems;
        
        Test.startTest();
        update orders;
        Test.stopTest();
        Account newAcc200 = [SELECT Id, Name, Chiffre_d_affaires__c FROM Account WHERE Id = :acc200.Id];
        Account newAcc10 = [SELECT Id, Name, Chiffre_d_affaires__c FROM Account WHERE Id = :acc10.Id];
        // CA of each Account must be equal to : 20 * 100 = 2000
        System.assertEquals(2000,newAcc200.Chiffre_d_affaires__c,'Le CA est erroné pour le compte :'+newAcc200.Name);
        System.assertEquals(2000,newAcc10.Chiffre_d_affaires__c,'Le CA est erroné pour le compte :'+newAcc10.Name);
    }
}