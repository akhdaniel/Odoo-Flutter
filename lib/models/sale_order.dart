
class SaleOrderModel {
  SaleOrderModel({
    required this.id,
    required this.name,
    required this.partnerId,
    required this.paymentTermId,
    required this.currencyId,
    required this.orderDate,
    required this.amountTotal,
    required this.state,
    required this.orderLineIds,
    required this.orderLines,
    required this.lastUpdate,
  });

  int id;
  String name;
  List partnerId;
  List currencyId;
  List paymentTermId;
  String orderDate;
  String state;
  double amountTotal;
  List orderLineIds;
  List orderLines;
  String lastUpdate;


  static fromJson(record){
    print('load from json');
    return SaleOrderModel(
      id: record['id'], 
      name: record['name'], 
      partnerId: record['partner_id'] , 
      currencyId: record['currency_id'], 
      paymentTermId: record['payment_term_id'], 
      orderDate: record['date_order'], 
      amountTotal: record['amount_total'],
      state: record['state'],
      orderLineIds: record['order_line'],
      lastUpdate: record['__last_update'],
      orderLines: [],
    );
  }

  @override
  String toString() {
    return "{'id': $id, 'name':'$name', 'partnerId':$partnerId, 'currencyId':$currencyId, 'paymentTermId':$paymentTermId, 'orderDate':'$orderDate', 'amountTotal':$amountTotal, 'state':'$state', 'orderLines':$orderLines}";
  }

  toJson() {
    return {
      'id': id, 
      'name':name, 
      'partnerId':partnerId, 
      'paymentTermId':paymentTermId, 
      'currencyId':currencyId, 
      'orderDate':orderDate, 
      'amountTotal': amountTotal, 
      'state':state, 
      'orderLineIds':orderLineIds,
      'orderLines':orderLines
    };

  }

  static SaleOrderModel newSaleOrder() {
    return SaleOrderModel(
      id: 0, 
      name: '', 
      partnerId: [], 
      paymentTermId: [], 
      currencyId: [], 
      orderDate: '', 
      amountTotal: 0, 
      state:'', 
      orderLineIds: [], 
      orderLines: [], 
      lastUpdate:''
    );
  }  
}

