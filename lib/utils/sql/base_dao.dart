import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visits_app/utils/sql/db_helper.dart';
import 'package:visits_app/utils/sql/entity.dart';

// Data Access Object
abstract class BaseDAO<T extends Entity?> {
  Future<Database?> get db => DatabaseHelper.getInstance().db;

  String get tableName;

  T fromMap(Map<String, dynamic> map);

  Future<int> save(T entity) async {
    try {
      var dbClient = await db;
      var id = await dbClient!.insert(tableName, entity!.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('id: $id');
      return id;
    } catch (e) {
      if(kDebugMode){
        print("Insert error: (table $tableName) --> $e");
      }
      return 0;
    }
  }

  Future<List<T>> query(String sql, [List<dynamic>? arguments]) async {
    try {
      final dbClient = await db;
      final list = await dbClient!.rawQuery(sql, arguments);

      return list.map<T>((json) => fromMap(json)).toList();
    } catch (e) {
      print("ERRO NA QUERY");
      print("Query error: (tabela $tableName) --> $e");
      return [];
    }
  }

  Future<List<T>> findAll() async {
    List<T> list = await query('select * from $tableName');
    return list;
  }

  Future<T?> findById(int? id) async {
    List<T> list = await query('select * from $tableName where id = ?', [id]);
    return list != null && list.length > 0 ? list.first : null;
  }

  Future<T?> findBy(String field, dynamic value) async {
    List<T> list =
        await query('select * from $tableName where $field = ?', [value]);
    return list.length > 0 ? list.first : null;
  }

  Future<List<T>> findByList(String field, dynamic value) async {
    List<T> list = await query('select * from $tableName where $field = ?', [value]);
    return list;
  }

  Future<T?> findByName(String? name) async {
    List<T> list = await query('select * from $tableName where name = ?', [name]);

    return list.length > 0 ? list.first : null;
  }

  Future<T?> findByDisplayName(String name) async {
    List<T> list = await query('select * from $tableName where display_name = ?', [name]);

    return list.length > 0 ? list.first : null;
  }

  Future<bool> exists(int id) async {
    T? c = await findById(id);
    var exists = c != null;
    return exists;
  }

  Future<int?> count() async {
    final dbClient = await db;
    final list = await dbClient!.rawQuery('select count(*) from $tableName');
    return Sqflite.firstIntValue(list);
  }

  Future<int> delete(int? id) async {
    var dbClient = await db;
    return await dbClient!.rawDelete('delete from $tableName where id = ?', [id]);
  }

  Future<int> deleteAll() async {
    var dbClient = await db;
    return await dbClient!.rawDelete('delete from $tableName');
  }

  Future<int> update(int? id, {required dynamic values}) async {
    var dbClient = await db;
    return await dbClient!.update(tableName, values, where: "id = ?", whereArgs: [id]);
  }
}
