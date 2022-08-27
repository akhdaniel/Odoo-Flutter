
class SaleOrderLineModel {
  SaleOrderLineModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.saleOrderId,
    required this.uomId,
    required this.qty,
    required this.unitPrice,
    required this.priceSubtotal,
  });

  int id;
  String name;
  int productId;
  int saleOrderId;
  int uomId;
  String qty;
  String priceSubtotal;
  double unitPrice;


  static fromJson(record){
    print('load order line from json');
    return SaleOrderLineModel(
      id: record['id'], 
      name: record['name'], 
      productId: (record['product_id'] is List)?record['product_id'][0]:0, 
      saleOrderId: (record['order_id'] is List)?record['order_id'][0]:0, 
      uomId: (record['uom_id'] is List)?record['uom_id'][0]:0, 
      qty: record['product_uom_qty'], 
      unitPrice: record['price_unit'],
      priceSubtotal: record['price_subtotal'],
    );
  }

  @override
  String toString() {
    return "{'id': $id, 'name':'$name', 'productId':$productId, 'saleOrderId':$saleOrderId, 'qty':'$qty', 'unitPrice':$unitPrice, 'priceSubtotal':'$priceSubtotal', 'uomId':$uomId}";
  }

  toJson() {
    return {
      'id': id, 
      'name':name, 
      'productId':productId, 
      'saleOrderId':saleOrderId, 
      'qty':qty, 
      'unitPrice': unitPrice, 
      'priceSubtotal':priceSubtotal, 
      'uomId':uomId, 
    };

  }  
}

