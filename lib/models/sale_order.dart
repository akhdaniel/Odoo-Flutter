
class SaleOrderModel {
  SaleOrderModel({
    required this.id,
    required this.name,
    required this.partnerId,
    required this.paymentTermId,
    required this.orderDate,
    required this.amountTotal,
    required this.state,
    required this.orderLines,
  });

  int id;
  String name;
  int partnerId;
  int paymentTermId;
  String orderDate;
  String state;
  double amountTotal;
  List orderLines;


  static fromJson(record){
    return SaleOrderModel(
      id: record['id'], 
      name: record['name'], 
      partnerId: (record['partner_id'] is List)?record['partner_id'][0]:0, 
      paymentTermId: (record['payment_term_id'] is List)?record['payment_term_id'][0]:0, 
      orderDate: record['date_order'], 
      amountTotal: record['amount_total'],
      state: record['state'],
      orderLines: record['order_line'],
    );
  }

  @override
  String toString() {
    return "{'id': $id, 'name':'$name', 'partnerId':$partnerId, 'paymentTermId':$paymentTermId, 'orderDate':'$orderDate', 'amountTotal':$amountTotal, 'state':$state, 'orderLines':$orderLines}";
  }

  void setPartnerId(value ){
    partnerId = value ;
  }
  void setPaymentTermId(value ){
    paymentTermId = value ;
  }

  void saveSaleOrder(){
    print(this.toString());
    print(paymentTermId);
    print(partnerId);
  }
  void editSaleOrder(){
    print('edit');
  }
  void confirmSaleOrder(){
    print('confirm');
  }  
}

