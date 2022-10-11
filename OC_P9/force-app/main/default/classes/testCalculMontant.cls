@isTest
private class testCalculMontant {
    @testSetup static void createData() {
        // create the accounts
        Account acc1 = new Account(Name = 'Test Account 1',Phone = '0101010101');
        insert acc1;
    }

    @isTest static void calculMontantForMoreThanOneOrder() {
        // create one account with a CA of 0
        Account acc = TestDataFactory.createAccount(0);

        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');

        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

        // create 2 orders of for the account with shipmentcost of 10
        List<Order> orders = TestDataFactory.createOrdersOnAccount(acc.Id, 2, customPBId, 10);

        // create orderItems on orders with quantity of 1O and unitPrice of 100
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsOnOrders(orders, 10, 100, customPBEId);

        // change quantity in orderItems
        for (OrderItem orditem : orderItems) {
            orditem.Quantity = 20;
        }
        update orderItems;
      
        Test.startTest();
        update orders;
        Test.stopTest();
        orders = [SELECT Name, NetAmount__c FROM ORDER];
        // 2 orders with NetAmount = 20 * 100 - 10 = 1990
        System.assertEquals(2,orders.size(),'2 commandes devraient avoir été créées');
        for (Order ord : orders) { 
            System.assertEquals(1990,ord.NetAmount__c,'Le montant net est erroné pour la commande '+ord.Name);
        }
    }
}