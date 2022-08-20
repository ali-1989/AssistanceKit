import 'dart:convert';

import 'package:assistance_kit/api/helpers/boolHelper.dart';
import 'package:assistance_kit/api/logger/logger.dart';
import 'package:postgresql2/pool.dart';
import 'package:postgresql2/postgresql.dart';

/// https://stackoverflow.com/questions/64210167/unable-to-connect-to-postgres-db-due-to-the-authentication-type-10-is-not-suppor
/*
select pg_reload_conf();

show data_directory;
pg_ctl reload -D C:/Program Files/PostgreSQL/13/data
 */

class Psql2 {
  static final _regCls = RegExp("'::");
  late Connection _connection;
  Pool? _pool;
  bool _isPrepare = false;

  Future open({
    required String dbName,
    required String user,
    required String pass,
    int port = 5432,
    bool pool = false,
    int minPool = 1,
    int maxPool = 10,
    }) async{
    final uri = 'postgres://$user:$pass@localhost:$port/$dbName';

    if(!pool) {
      _connection = await connect(uri, timeZone: 'UTC', connectionTimeout: Duration(seconds: 12), );
      _isPrepare = true;
    }
    else{
      _pool = Pool(uri, minConnections: minPool, maxConnections: maxPool,
          timeZone: 'UTC', connectionTimeout: Duration(seconds: 12), idleTimeout: Duration(seconds: 30)
        , maxLifetime: Duration(seconds: 90), restartIfAllConnectionsLeaked: true,);

      _pool!.messages.listen(print);
      _isPrepare = true;
      await _pool!.start();
    }
  }

  bool isOpen(){
    if(!_isPrepare) {
      return false;
    }

    if(_pool == null) {
      return _connection.state == ConnectionState.socketConnected;
    }

    return _pool!.state == PoolState.running;
  }

  void close(){
    if(_isPrepare) {
      if(_pool == null) {
        _connection.close();
      }
      else {
        _pool!.stop();
      }
    }
  }

  TransactionState transactionState(){
    if(!_isPrepare || _pool != null) {
      return TransactionState.unknown;
    }

    return _connection.transactionState;
  }

  Future<T> transaction<T>(Future<T> Function() operation){
    if(_isPrepare) {
      return _connection.runInTransaction<T>(operation);
    }

    return Future.value(null);
  }

  dynamic getCursorValue(List<Row>? cursor, String cName){
    if(cursor == null){
      return null;
    }

    final firstRow = cursor[0];
    return firstRow.toMap()[cName];
  }

  /// queryCall('select color from tb where id = @id', {'id': 5})
  /// queryCall('select color from tb where id in @list:array::text[]', ['10','20','30'])
  Future<List<Row>?> queryCall(String query, {dynamic values, bool autoClose = false}) async {
    if(!_isPrepare) {
      return Future.value(null);
    }

    try {
      if (_pool == null) {
        return _connection.query(query, values).toList();
      }

      final c = await _pool!.connect();
      final res = await c.query(query, values).toList();

      if (autoClose) {
        c.close();
      }

      return res;
    }
    catch (e){
      Logger.L.logToAll('Database query: $e\n $query');
    }

    return Future.value(null);
  }

  Future<Stream<Row>?> queryBigData(String query, {dynamic values}) async{
    if(!_isPrepare) {
      return Future.value(null);
    }

    if(_pool == null){
      return _connection.query(query, values);
    }

    final c = await _pool!.connect();
    final res = c.query(query, values);

    return res;
  }

  Future<List<T>?> queryMapping<T>(String query, {
    dynamic values, bool autoClose = false, required T Function(Row row) mapFn,
    }) async {

    if(!_isPrepare) {
      return Future.value(null);
    }

    if(_pool == null){
      return _connection.query(query, values).map<T>(mapFn).toList();
    }

    final c = await _pool!.connect();
    final res = c.query(query, values).map<T>(mapFn).toList();

    if(autoClose) {
      c.close();
    }

    return res;
  }

  Future<int?> execution(String query, {dynamic values, bool autoClose = false}) async{
    if(!_isPrepare) {
      return Future.value(null);
    }

    try {
      if (_pool == null) {
        return await _connection.execute(query, values);
      }

      final c = await _pool!.connect();
      final res = await c.execute(query, values);

      if (autoClose) {
        c.close();
      }

      return res;
    }
    catch (e){
      Logger.L.logToAll('Database execute: $e\n $query');
      return null;
    }
  }

  String _genUpdateSetStatement(List<String> columns, List<dynamic> values){
    if(columns.isEmpty) {
      return '';
    }

    var set = '';

    for(var i = 0; i < columns.length; i++){
      final key = columns[i];
      final val = values[i];

      if(val == null){
        set += '$key = null, ';
      }

      else if(val is String) {
        if(val.contains(_regCls)){
          set += '$key = $val, ';
        }
        else {
          set += "$key = '$val', ";
        }
      }
      else {
        if(val is List){
          if(val is List<int>){
            set += "$key = '{${listToSequenceNum(val, onEmpty: '')}}'::int[], ";
          }
          else if(val is List<Map>){
            set += "$key = '${listToPgArrayWithoutClass(val)}'::JSONB, ";
          }
        }
        else if(val is Map){
          if(val.isEmpty){
            set += "$key = '{}'::JSONB, ";
          }
          else {
            set += "$key = '${json.encode(val)}'::JSONB, ";
          }
        }
        else {
          set += '$key = $val, ';
        }
      }
    }

    return set.substring(0, set.length-2);
  }

  String _genUpdateSetStatementKv(Map<String, dynamic> setKv){
    if(setKv.isEmpty) {
      return '';
    }

    var set = '';

    for(var e in setKv.entries){
      final key = e.key;
      final val = e.value;

      if(val == null){
        set += '$key = null,';
      }

      else if(val is String) {
        if(val.contains(_regCls)) {
          set += '$key = $val,';
        }
        else {
          set += "$key = '$val',";
        }
      }
      else {
        if(val is List){
          if(val is List<int>){
            set += "$key = '{${listToSequenceNum(val, onEmpty: '')}}'::int[], ";
          }
          else if(val is List<Map>){
            set += "$key = '${listToPgArrayWithoutClass(val)}'::JSONB, ";
          }
        }
        else if(val is Map){
          if(val.isEmpty){
            set += "$key = '{}'::JSONB, ";
          }
          else {
            set += "$key = '${json.encode(val)}'::JSONB, ";
          }
        }
        else {
          set += '$key = $val,';
        }
      }
    }

    return set.substring(0, set.length-1);
  }

  String _joinValue(List list) {
    final iterator = list.iterator;

    if (!iterator.moveNext()) {
      return '';
    }

    final buffer = StringBuffer();
    var val = iterator.current;

    if(val == null){
      buffer.write('null');
    }

    else if(val is String) {
      if(val.contains(_regCls)) {
        buffer.write(val);
      }
      else {
        buffer.write("'$val'");
      }
    }
    else {
      if(val is List){
        if(val is List<int>){
          buffer.write("'{${listToSequenceNum(val, onEmpty: '')}}'::int[]");
        }
        else if(val is List<Map>){
          buffer.write("'{${listToPgArrayWithoutClass(val)}}'::JSONB");
        }
      }
      else if(val is Map){
        if(val.isEmpty){
          buffer.write("'{}'::JSONB");
        }
        else {
          buffer.write("'${json.encode(val)}'::JSONB");
        }
      }
      else {
        buffer.write(val);
      }
    }

    while (iterator.moveNext()) {
      val = iterator.current;
      buffer.write(',');

      if(val == null){
        buffer.write('null');
      }

      else if(val is String) {
        if(val.contains(_regCls)) {
          buffer.write(val);
        }
        else {
          buffer.write("'$val'");
        }
      }
      else {
        if(val is List){
          if(val is List<int>){
            buffer.write("'{${listToSequenceNum(val, onEmpty: '')}}'::int[]");
          }
          else if(val is List<Map>){
            buffer.write("'{${listToPgArrayWithoutClass(val)}}'::JSONB");
          }
        }
        else if(val is Map){
          if(val.isEmpty){
            buffer.write("'{}'::JSONB");
          }
          else {
            buffer.write(castToJsonb(val));
          }
        }
        else {
          buffer.write(val);
        }
      }
    }

    return buffer.toString();
  }

  Future<int?> insert(String tbName, List<String> columns, List<dynamic> values) async{
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)});';

    return execution(query);
  }

  ///  kv['alternatives'] = "'${PublicAccess.psql2.listToValue(alternatives)}'::text[]";
  ///  kv['properties'] = "'${JsonHelper.mapToJson(props)}'::jsonb";
  Future<int?> insertKv(String tbName, Map<String, dynamic> setKv) async{
    return insert(tbName, setKv.keys.toList(), setKv.values.toList());
  }

  Future<List?> insertKvReturning(String tbName, Map<String, dynamic> setKv, String returnKey) async {
    final k = setKv.keys.toList();
    final v = setKv.values.toList();

    final q = 'INSERT INTO $tbName (${k.join(',')}) values(${_joinValue(v)}) RETURNING $returnKey;';

    return await queryCall(q);

    /*if(res != null && res.isNotEmpty){
      return res[0].toList()[0];
    }

    if(cursor is List){
      final m = cursor.elementAt(0).toMap();
    */
  }

  /// conflictExp: can empty
  /// conflictExp: ON CONSTRAINT constraint_name
  /// conflictExp: (ColumnNames)                   ColumnName must unique for conflict
  /// conflictExp: (ColumnNames) WHERE ...
  Future<int?> insertIgnore(String tbName, List<String> columns, List<dynamic> values, {String conflictExp = ''}) async{
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) '
        ' ON CONFLICT $conflictExp DO NOTHING;';
    return execution(query);
  }

  /// return 0 if fail
  Future<dynamic> insertIgnoreWhere(String tbName, Map<String, dynamic> kv, {required String where, String? returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    if(await exist(tbName, where)){
      return 0;
    }

    var q = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING';

    if(returning != null){
      q += ' RETURNING $returning;';
      return queryCall(q);
    }
    else {
      q += ';';
      return execution(q);
    }
  }

  Future<int?> insertByAt(String tbName, List<String> columns, Map<String, dynamic> values) async{
    final a = values.keys.map((key) {return '@$key';}).toList();
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${a.join(',')});';

    return execution(query, values: values);
  }

  /// setStatement: cName = EXCLUDED.cName
  /// setStatement: cName = 50
  Future<int?> upsert(String tbName, List<String> columns, List<dynamic> values,{
    required String conflictColumns, required String setStatement}) async{
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) '
        ' ON CONFLICT ($conflictColumns) DO UPDATE set $setStatement;';
    return execution(query);
  }

  Future<int?> upsertWhere(String tbName, List<String> columns, List<dynamic> values,{required String where}) async{
    if(await exist(tbName, where)){
      return update(tbName, _genUpdateSetStatement(columns, values), where);
    }

    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) ON CONFLICT DO NOTHING;';
    return execution(query);
  }

  Future<int?> upsertWhereKv(String tbName, Map<String, dynamic> kv, {required String where}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    if(await exist(tbName, where)){
      return update(tbName, _genUpdateSetStatement(col, val), where);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING;';
    return execution(query);
  }

  Future<List?> upsertWhereKvReturning(String tbName, Map<String, dynamic> kv, {required String where, required String returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    if(await exist(tbName, where)){
      return updateReturning(tbName, _genUpdateSetStatement(col, val), where, returning);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING RETURNING $returning;';
    return queryCall(query);
  }

  Future<int?> upsertValues(String tbName, List<String> columns, List<dynamic> values,{required String conflictColumns}) async{
    final set = _genUpdateSetStatement(columns, values);

    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) '
        ' ON CONFLICT ($conflictColumns) DO UPDATE set $set;';
    return execution(query);
  }

  Future<int?> update(String tbName, String setStatement, String? where) async{
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution(query);
  }

  // UPDATE country set name = 'iran' where iso = 'ir' RETURNING name,iso ;
  Future<List?> updateReturning(String tbName, String setStatement, String? where, String returning) async{
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where RETURNING $returning;';
    return queryCall(query);
  }

  Future<int?> updateByAt(String tbName, String setStatement, String? where, Map<String, dynamic> values) async{
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution(query, values: values);
  }

  /// updateKv(DbNames.T_Users, value, ' userId = $userId')
  Future<int?> updateKv(String tbName, Map<String, dynamic> setKv, String? where) async{
    return update(tbName, _genUpdateSetStatementKv(setKv), where);
  }

  Future<int?> updateKvByAt(String tbName, Map<String, dynamic> setKv, String? where) async{
    var set = '';
    for(final e in setKv.entries){
      set += '${e.key} = @${e.key},';
    }

    set = set.substring(0, set.length-1);

    return updateByAt(tbName, set, where, setKv);
  }

  Future<bool> exist(String tbName, String whereCondition) async{
    final q = 'SELECT EXISTS (SELECT * FROM $tbName WHERE $whereCondition LIMIT 1);';

    return queryCall(q).then((value) {
      if(value != null && value.isNotEmpty){
        final res = value.elementAt(0)[0];

        return BoolHelper.isTrue(res);
      }

      return false;
    });
  }

  // que: SELECT EXISTS (SELECT ...)
  Future<bool> existQuery(String que) async{
    return queryCall(que).then((value) {
      if(value != null && value.isNotEmpty){
        final res = value.elementAt(0)[0];

        return BoolHelper.isTrue(res);
      }

      return false;
    });
  }

  /// note: column name must be lowercase
  Future<dynamic> getColumn(String querySt, String columnName) async {
    final cursor = await queryCall(querySt);

    if (cursor == null || cursor.isEmpty) {
      return null;
    }

    final m = cursor.elementAt(0).toMap();
    return m[columnName];
  }

  // return int or 'RETURNING' value
  Future delete(String tbName, String? where, {String? returning}) async {
    where ??= '1 = 1';

    var query = 'DELETE FROM $tbName WHERE $where';

    if(returning == null) {
      return execution(query + ';');
    }
    else {
      query += ' RETURNING $returning;';
      return queryCall(query);
    }
  }

  Future<int?> deleteByAt(String tbName, String? where, Map<String, dynamic> values) async{
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where;';
    return execution(query, values: values);
  }

  Future<int?> deleteTableCascade(String tbName) async{
    final query = 'DROP TABLE IF EXISTS $tbName CASCADE;';
    return execution(query);
  }

  Future<int?> truncateTableCascade(String tbName) async{
    final query = 'TRUNCATE TABLE $tbName RESTART IDENTITY CASCADE;';
    return execution(query);
  }

  Future<int?> dropAllTable() async{
    final query = '''
      DO \$\$
			DECLARE tablenames text;
					BEGIN
					   tablenames := (SELECT string_agg('"' || tablename || '"', ',') FROM pg_tables WHERE schemaname = 'public');
					   EXECUTE 'DROP TABLE ' || tablenames || ' CASCADE';
					END; \$\$
    ''';

    return execution(query);
  }

  Future<List<Row>?> getColumsName(String tabelName) async{
    final query = '''
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = '$tabelName';
    ''';

    return queryCall(query);
  }

  Pool? get pool => _pool;
  Connection get connection => _connection;
  ///================ tools =====================================================
  static String? castToJsonb(dynamic mapOrListOrJs, {bool nullIfNull = true}){
    if(mapOrListOrJs == null){
      if(nullIfNull){
        return null;
      }

      return "'{}'::JSONB";
    }

    if(mapOrListOrJs is Map || mapOrListOrJs is List){
      final js = json.encode(mapOrListOrJs);

      return "'$js'::JSONB";
    }

    return "'$mapOrListOrJs'::JSONB";
  }

  ///  kv['alternatives'] = "'${psql2.listToPgArrayWithoutClass(alternatives)}'::text[]";
  static String listToPgArrayWithoutClass(List list){
    if(list.isEmpty){
      return "'{}'";
    }

    var res = '{';

    for(final d in list){
      if(d is String) {
        res += '"$d",';
      }
      else {
        res += '$d,';
      }
    }

    res = res.substring(0, res.length-1);

    return res + '}';
  }

  static String listToPgTextArray(List list){
    if(list.isEmpty){
      return "'{}'::text[]";
    }

    return "'${listToPgArrayWithoutClass(list)}'::text[]";
  }

  static String listToPgIntArray(List list){
    if(list.isEmpty){
      return "'{}'::int[]";
    }

    return "'${listToPgArrayWithoutClass(list)}'::int[]";
  }

  static String listToSequence(Iterable input, {String onEmpty = '-1'}) {
    if(input.isEmpty){
      return onEmpty;
    }

    var res = '';

    for(final i in input){
      if(i is String){
        res += '"$i", ';
      }
      else {
        res += '$i, ';
      }
    }

    res = res.substring(0, res.length-2);

    return res;
  }

  static String listToSequenceNum(Iterable input, {String onEmpty = '-1'}) {
    if(input.isEmpty){
      return onEmpty;
    }

    var res = '';

    for(final i in input){
      res += '$i, ';
    }

    res = res.substring(0, res.length-2);

    return res;
  }
}