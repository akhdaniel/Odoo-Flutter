import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Controller extends GetxController{
  var currentUser = ''.obs;
  // var currentSession = {}.obs;
  var baseUrl = ''.obs;
  var db = ''.obs;
  var isLoggedIn = false.obs;

  // setCurrentSession(session)=>currentSession(session);
  setCurrentUser(username)=>currentUser(username);
  setDb(newDb)=>db(newDb);
  setBaseUrl(newBaseUrl)=>baseUrl(newBaseUrl);

  loggedIn()=>isLoggedIn(true);
  loggedOut()=>isLoggedIn(false);

}