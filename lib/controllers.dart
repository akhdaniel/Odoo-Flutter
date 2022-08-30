
import 'package:get/get.dart';

class Controller extends GetxController{
  var currentUser = ''.obs;
  var baseUrl = ''.obs;
  var db = ''.obs;
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var objectName = ''.obs;

  var showAddNew = false.obs;

  RxMap saleOrder = {}.obs;
  RxMap saleOrderLine = {}.obs;
  RxList saleOrderLines = [].obs;


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

}