trigger UpdateAccountCA on Order (after update) {
    System.debug('Begin UpdateAccountCA');
	
    // Récupération des comptes liés aux commandes mises à jour
    Map<Id,Account> mapAccounts = new Map<Id,Account>(AP01Account.getAccountsOfOrders(trigger.new));
    
    AP01Account.updateChiffreAffaireWithListOfOrders(false,mapAccounts,trigger.new);

    System.debug('End UpdateAccountCA : number of orders updated : ' + trigger.new.size());
}