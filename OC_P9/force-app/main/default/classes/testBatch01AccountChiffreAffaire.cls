@isTest
private class testBatch01AccountChiffreAffaire {
    @testSetup static void createData() {
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

        // Create 200 accounts with 1 order of 1000 wit status 'Draft' and a CA of 0
        List<Account> accounts = TestDataFactory.createAccountsWithOrders(200,'Test Batch 200 Accounts',0,1000, customPBId, customPBEId);
     }

     @isTest static void testBatchOnOneHundredOfTwoHundredAccounts() {
        // Activate orders for 100 of 200 accounts
        Map<Id,Account> mapAccountstoUpdate = new Map<ID,Account>(TestDataFactory.activateOrdersOfAccounts(100));

        Test.startTest();
        ID batchprocessid = Database.executeBatch(new Batch01AccountChiffreAffaire());
        Test.stopTest();
        // Get the Accounts updated
        List<Account> accountsUpdated = [SELECT Name, Chiffre_d_Affaires__c FROM Account WHERE ID IN :mapAccountstoUpdate.keySet() AND Name LIKE 'Test Batch 200 Accounts'];
        List<Account> accountsNotUpdated = [SELECT Name, Chiffre_d_Affaires__c FROM Account WHERE ID NOT IN :mapAccountstoUpdate.keySet() AND Name LIKE 'Test Batch 200 Accounts'];
        // The CA must be equal to 1000 for each account with order activated
        for (Account acc :accountsUpdated) {
            System.assertEquals(1000,acc.Chiffre_d_Affaires__c,'CA invalide pour le compte : '+acc.Name);
        }
        // The CA must be equal to 0 for each account without order activated
        for (Account acc :accountsNotUpdated) {
            System.assertEquals(0,acc.Chiffre_d_Affaires__c,'CA invalide pour le compte : '+acc.Name);
        }
    }
}