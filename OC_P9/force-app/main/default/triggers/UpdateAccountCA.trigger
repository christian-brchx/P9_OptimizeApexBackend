trigger UpdateAccountCA on Order (after update) {
    System.debug('Begin UpdateAccountCA');
	
    // stockage des Ids de comptes liés aux commandes mises à jour
    set<Id> setAccountIds = new set<Id>();
    for(Order ord : trigger.new){
        setAccountIds.add(ord.accountId);
    }
    
    // Lecture des comptes liés aux commandes mises à jour
    List<Account> listAccounts = [SELECT Id, Chiffre_d_affaires__c FROM Account WHERE Id IN :setAccountIds];
    Map<Id,Account> mapAccounts = new Map<Id,Account>(listAccounts);
    
    // Pour chaque commande, mise à jour du chiffre d'affaire du compte associé à la commande
    for(Order ord : trigger.new){
        Account acc = mapAccounts.get(ord.AccountId);
        if (acc != null) {
            acc.Chiffre_d_affaires__c = acc.Chiffre_d_affaires__c + ord.TotalAmount;
        } else {
            System.debug('Error in UpdateAccountCA : Account id = '+ ord.AccountId + 'not found');
        }
    }
    update listAccounts;

    System.debug('End UpdateAccountCA : number of orders updated : ' + trigger.new.size());
}