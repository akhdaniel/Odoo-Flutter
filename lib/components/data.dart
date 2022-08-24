import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:convert' as convert;

import '../controllers.dart';
import '../shared_prefs.dart';
final Controller c = Get.find();

class BackendService {
  static Future<List<Map<String, String>>> getSuggestions(String query) async {
    if (query.isEmpty && query.length < 3) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }
    var url = Uri.https('api.datamuse.com', '/sug', {'s': query});

    var response = await http.get(url);
    List<Suggestion> suggestions = [];
    if (response.statusCode == 200) {
      Iterable json = convert.jsonDecode(response.body);
      suggestions =
          List<Suggestion>.from(json.map((model) => Suggestion.fromJson(model)));

      print('Number of suggestion: ${suggestions.length}.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return Future.value(suggestions
        .map((e) => {'name': e.word, 'score': e.score.toString()})
        .toList());
  }
  
  static Future<List<Map<String, String>>> getMasterData(String object, String query) async {
    if (query.isEmpty && query.length < 3) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }
    OdooSession? session ;
    OdooClient? client ;
        
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    var domain = [['name','ilike',query]];
    
    var response = await client.callKw({
      'model': object,
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': ['id','name'],
      },
    });

    List<Master> masters = List<Master>.from(response.map((model) => Master.fromJson(model)));

    return Future.value(masters
        .map((e) => {'name': e.name, 'id': e.id.toString()})
        .toList());

  }
}

class Suggestion {
  final int score;
  final String word;

  Suggestion({
    required this.score,
    required this.word,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      word: json['word'],
      score: json['score'],
    );
  }
}
class Master {
  final int id;
  final String name;

  Master({
    required this.id,
    required this.name,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      name: json['name'],
      id: json['id'],
    );
  }
}