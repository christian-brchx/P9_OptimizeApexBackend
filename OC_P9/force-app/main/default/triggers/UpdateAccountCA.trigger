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
    
    AP01Account.updateChiffreAffaireWithListOfOrders(false,new Map<Id,Account>(listAccounts),trigger.new);
    update listAccounts;

    System.debug('End UpdateAccountCA : number of orders updated : ' + trigger.new.size());
}