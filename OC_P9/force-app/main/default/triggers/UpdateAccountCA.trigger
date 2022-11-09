trigger UpdateAccountCA on Order (after update) {
    System.debug('Begin UpdateAccountCA');
	
    // stockage des Ids de comptes liés aux commandes mises à jour
    set<Id> setAccountIds = new set<Id>();
    for(Order ord : trigger.new){
        setAccountIds.add(ord.accountId);
    }
    
    // Récupération des comptes liés aux commandes mises à jour
    Map<Id,Account> mapAccounts = new Map<Id,Account>(AP01Account.getAccountsOfOrders(setAccountIds));
    
    AP01Account.updateChiffreAffaireWithListOfOrders(false,mapAccounts,trigger.new);

    System.debug('End UpdateAccountCA : number of orders updated : ' + trigger.new.size());
}