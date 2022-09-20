
import 'package:get/get.dart';

class Controller extends GetxController{
  var currentUser = {}.obs;
  setCurrentUser(username)=>currentUser(username);


  // var baseUrl = ''.obs;
  // var db = ''.obs;
  // var isLoggedIn = false.obs;
  
 
  // loggedIn()=>isLoggedIn(true);
  // loggedOut()=>isLoggedIn(false);
  
  // loading(v) {
  //   isLoading(v);
  //   update();
  // }


  // saveSaleOrder(so){
  //   saleOrder(so);
  // }

  // saveSaleOrderLine(sol){
  //   saleOrderLine(sol);
  // }

  // addSaleOrderLines(sol){
  //   saleOrderLines.insert(0,sol);
  // }

  // void updateSaleOrderLines(int index, SaleOrderLineModel currentSaleOrderLine) {
  //   saleOrderLines[index] = currentSaleOrderLine;
  // }

}