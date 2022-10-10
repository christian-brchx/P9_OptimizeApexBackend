trigger CalculMontant on Order (before update) {
    for (Order ord : trigger.new) {
		ord.NetAmount__c = ord.TotalAmount - ord.ShipmentCost__c;
    }
}