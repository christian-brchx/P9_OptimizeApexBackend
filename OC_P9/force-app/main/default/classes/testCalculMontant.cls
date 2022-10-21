@isTest
private class testCalculMontant {

    @testSetup static void createData() {
        // create one account with a CA of 0
        Account acc = TestDataFactory.createAccount('Test Account',0);
 
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);
 
        // create 2 orders for the account with shipmentcost of 10
        List<Order> orders = TestDataFactory.createOrdersOnAccount(acc.Id, 2, customPBId, 10);
 
        // create orderItems on each order with quantity of 1O and unitPrice of 100
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsOnOrders(orders, 10, 100, customPBEId);
     }

     @isTest static void calculateNetAmountForTwoOrders() {
        // Get 2 orders created
        Map<Id,Order> mapOrders = new Map<Id,Order>([SELECT Id FROM Order LIMIT 2]);
        // Get the orderITems created
        List<OrderItem> orderItems = [SELECT OrderId, Quantity FROM OrderItem WHERE OrderId IN :mapOrders.keySet()];
        // change quantity in orderItems
        for (OrderItem orditem : orderItems) {
            orditem.Quantity = 20;
        }
        update orderItems;
      
        Test.startTest();
        update mapOrders.values();
        Test.stopTest();
        
        // Get the 2 orders after update
        List<Order> neworders = [SELECT Name, NetAmount__c FROM ORDER WHERE ID IN :mapOrders.keySet()];
        // 2 orders with NetAmount = 20 * 100 - 10 = 1990
        System.assertEquals(2,neworders.size(),'2 commandes devraient avoir été mises à jour');
        for (Order ord : neworders) { 
            System.assertEquals(1990,ord.NetAmount__c,'Le montant net est erroné pour la commande '+ord.Name);
        }
    }
}