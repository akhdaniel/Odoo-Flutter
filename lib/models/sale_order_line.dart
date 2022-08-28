
class SaleOrderLineModel {
  SaleOrderLineModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.saleOrderId,
    required this.uomId,
    required this.qty,
    required this.priceUnit,
    required this.priceSubtotal,
  });

  int id;
  String name;
  List productId;
  List saleOrderId;
  List uomId;
  double qty;
  double priceSubtotal;
  double priceUnit;

  static newOrderLine(){
    return {
      'id': 0, 
      'name': '', 
      'product_id': [0,''], 
      'order_id': [0,''], 
      'product_uom': [0,''], 
      'product_uom_qty': 0.0, 
      'price_unit': 0.0,
      'price_subtotal': 0.0,
    };
  }

  static fromJson(record){
    print('load order line from json');

    return SaleOrderLineModel(
      id: record['id'], 
      name: record['name'], 
      productId: record['product_id'], 
      saleOrderId: record['order_id'] , 
      uomId: record['product_uom'], 
      qty: record['product_uom_qty'], 
      priceUnit: record['price_unit'],
      priceSubtotal: record['price_subtotal'],
    );
  }

  @override
  String toString() {
    return "{'id': $id, 'name':'$name', 'productId':$productId, 'saleOrderId':$saleOrderId, 'qty':'$qty', 'priceUnit':$priceUnit, 'priceSubtotal':'$priceSubtotal', 'uomId':$uomId}";
  }

  toJson() {
    return {
      'id': id, 
      'name':name, 
      'product_id':productId, 
      'order_id':saleOrderId,
      'product_uom_qty':qty, 
      'price_unit': priceUnit, 
      'price_subtotal':priceSubtotal, 
      'product_uom':uomId, 
    };

  }  
}

