
import 'package:flutter_auth/models/sale_order_line.dart';
import 'package:get/get.dart';

class Controller extends GetxController{
  var currentUser = ''.obs;
  var baseUrl = ''.obs;
  var db = ''.obs;
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var objectName = ''.obs;

  var showAddNew = false.obs;


  var enableEditing = false.obs;

  setEnableEditing(val){
    enableEditing(val);
  }

  RxMap saleOrder = {}.obs;
  RxMap saleOrderLine = {}.obs;
  RxList saleOrderLines = [].obs; // reactive

  setCurrentUser(username)=>currentUser(username);
  setDb(newDb)=>db(newDb);
  setBaseUrl(newBaseUrl)=>baseUrl(newBaseUrl);
  setObjectName(name)=>objectName(name);

  loggedIn()=>isLoggedIn(true);
  loggedOut()=>isLoggedIn(false);
  
  loading(v) {
    isLoading(v);
    update();
  }


  saveSaleOrder(so){
    saleOrder(so);
  }

  saveSaleOrderLine(sol){
    saleOrderLine(sol);
  }

  addSaleOrderLines(sol){
    saleOrderLines.insert(0,sol);
  }

  void updateSaleOrderLines(int index, SaleOrderLineModel currentSaleOrderLine) {
    saleOrderLines[index] = currentSaleOrderLine;
  }

}