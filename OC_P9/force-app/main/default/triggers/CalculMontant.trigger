trigger CalculMontant on Order (before update) {
    System.debug('Begin CalculMontant');
    for (Order ord : trigger.new) {
		ord.NetAmount__c = ord.TotalAmount - ord.ShipmentCost__c;
    }
    System.debug('End CalculMontant : number of orders updated : ' + trigger.new.size());
}