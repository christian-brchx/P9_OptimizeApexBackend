@isTest
private class testBatch01AccountChiffreAffaire {
    @testSetup static void createData() {
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

        // Create 200 accounts with 1 order of 1000 wit status 'Draft'
        List<Account> accounts = TestDataFactory.createAccountsWithOrders(200,'Test Batch Account',0,1000, customPBId, customPBEId);
     }

     @isTest static void testBatchOnOneHundredOfTwoHundredAccounts() {
        // Activate orders for 150 of 200 accounts
        Map<Id,Account> mapAccountstoUpdate = new Map<ID,Account>(TestDataFactory.activateOrdersOfAccounts(150));

        Test.startTest();
        ID batchprocessid = Database.executeBatch(new Batch01AccountChiffreAffaire());
        Test.stopTest();
        // Get the Accounts
        List<Account> accountsToCheck = [SELECT Name, Chiffre_d_Affaires__c FROM Account WHERE ID IN :mapAccountstoUpdate.keySet()];
        //System.AssertEquals(database.countquery('SELECT COUNT() FROM Account WHERE Chiffre_d_affaires__c = 1000'),150);        
        // The CA must be equal to 1000 for each account
        for (Account acc :accountsToCheck) {
            System.assertEquals(1000,acc.Chiffre_d_Affaires__c,'CA invalide pour le compte : '+acc.Name);
        }
    }
}