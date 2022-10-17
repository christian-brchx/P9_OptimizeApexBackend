global class Batch01AccountChiffreAffaire implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
        System.Debug('Batch01AccountChiffreAffaire.start');
        return Database.getQueryLocator('SELECT Account.Id, Account.Name, Account.Chiffre_d_affaires__c FROM Account WHERE Account.Id IN (SELECT AccountID FROM Order WHERE Status = \'Activated\')');
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
       List<Order> orders = AP01Account.getOrdersOfAccounts(scope);
       AP01Account.updateChiffreAffaireWithListOfOrders(true,new Map<Id,Account>(scope),AP01Account.getOrdersOfAccounts(scope));
       System.Debug('Batch01AccountChiffreAffaire.execute Nb Account ='+scope.size());
       update scope;
    }    
    
    global void finish(Database.BatchableContext info){     
       
    } 
}