public class AP01Account {
    public static List<Order> getOrdersOfAccounts(List<Account> accounts){
        Map<Id,Account> mapAccounts = new Map<Id,Account>(accounts);
        return [SELECT AccountId, TotalAmount FROM Order WHERE AccountId IN :mapAccounts.keySet() ];
    }

    public static void updateChiffreAffaireWithListOfOrders(boolean initCA,map<Id,Account> mapAccounts,List<Order> orders){
        // Reinitialisation du CA si demandé
        for (Account acc : mapAccounts.values()){
            acc.Chiffre_d_affaires__c = 0;
        }
        // Pour chaque commande, mise à jour du chiffre d'affaire du compte associé à la commande
        for(Order ord : orders){
            Account acc = mapAccounts.get(ord.AccountId);
            if (acc != null && acc.Chiffre_d_affaires__c != null) {
                acc.Chiffre_d_affaires__c = acc.Chiffre_d_affaires__c + ord.TotalAmount;
            } else {
                System.debug('Error in AP01Account : Account id = '+ ord.AccountId + 'not found');
            }
        }
    }

}