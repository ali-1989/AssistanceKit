import 'dart:convert';

import 'package:assistance_kit/api/logger/logger.dart';
import 'package:assistance_kit/api/helpers/textHelper.dart';
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
    String? server,
    bool pool = false,
    int minPool = 1,
    int maxPool = 10,
    }) async {
    String uri;

    if(server == null) {
      uri = 'postgres://$user:$pass@localhost:$port/$dbName';
    }
    else {
      uri = 'postgres://$user:$pass@$server:$port/$dbName';
    }

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

  static dynamic cursorValue(List<Row>? cursor, String columnName){
    if(cursor == null){
      return null;
    }

    final firstRow = cursor[0];
    return firstRow.toMap()[columnName];
  }

  /// values: queryCall('select color from tb WHERE id = @id',  values : {'id': 5})
  /// values: queryCall('select color from tb WHERE id IN (@0, @1, @2)',  values: ['10','20','30'])
  Future<PsqlResult> queryCall(String query, {dynamic values, bool autoClose = false}) async {
    if(!_isPrepare) {
      return PsqlResult()..setException(Exception('psql is not prepared.'));
    }

    final ret = PsqlResult();

    try {
      if (_pool == null) {
        ret._rowResult = await _connection.query(query, values).toList();
      }
      else {
        final c = await _pool!.connect();
        ret._rowResult = await c.query(query, values).toList();

        if (autoClose) {
          c.close();
        }
      }
    }
    catch (e, tr){
      String msg = '[psql2] error (queryCall method): $e\n  ===> query: $query';
      msg += '\n  ===> Trace: ${TextHelper.subByCharCountSafe(tr.toString(), 300)}';

      Logger.L.logToAll(msg);
      ret.stackTrace = tr;
      ret.setException(e);
    }

    return ret;
  }

  Future<Stream<Row>?> queryStreaming(String query, {dynamic values}) async{
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

  /// return 1 if correct doing and return 0 if not doing.
  Future<PsqlResult> execution(String query, {dynamic values, bool autoClose = false}) async{
    if(!_isPrepare) {
      return PsqlResult()..setException(Exception('psql is not prepare.'));
    }

    final ret = PsqlResult();

    try {
      if (_pool == null) {
        ret._intResult = await _connection.execute(query, values);
      }
      else {
        final c = await _pool!.connect();
        ret._intResult = await c.execute(query, values);

        if (autoClose) {
          c.close();
        }
      }
    }
    catch (e, tr){
      String msg = '[psql2] error (execution method): $e\n  ===> query:$query';
      msg += '\n   ===> Trace: ${TextHelper.subByCharCountSafe(tr.toString(), 300)}';

      Logger.L.logToAll(msg);
      ret.stackTrace = tr;
      ret.setException(e);
    }

    return ret;
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

  String _genUpdateSetStatementKv(Map<String, dynamic> setKv, {bool concatJson = false}){
    if(setKv.isEmpty) {
      return '';
    }

    var result = '';

    for(final e in setKv.entries){
      final key = e.key;
      final val = e.value;

      if(val == null){
        result += '$key = null,';
      }

      else if(val is String) {
        if(val.contains(_regCls)) {
          result += '$key = $val,';
        }
        else {
          result += "$key = '$val',";
        }
      }
      else {
        if(val is List){
          if(val is List<int>){
            result += "$key = '{${listToSequenceNum(val, onEmpty: '')}}'::int[],";
          }
          else if(val is List<Map>){
            result += "$key = '${listToPgArrayWithoutClass(val)}'::JSONB,";
          }
        }
        else if(val is Map){
          if(val.isEmpty){
            result += "$key = '{}'::JSONB,";
          }
          else {
            if(concatJson) {
              result += "$key = jsonb_concat($key, '${json.encode(val)}'::JSONB),";
            }
            else {
              result += "$key = '${json.encode(val)}'::JSONB,";
            }
          }
        }
        else {
          result += '$key = $val,';
        }
      }
    }

    return result.substring(0, result.length-1);
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

  Future<PsqlResult> insert(String tbName, List<String> columns, List<dynamic> values) async {
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)});';

    return execution(query);
  }

  ///  kv['alternatives'] = "'${PublicAccess.psql2.listToValue(alternatives)}'::text[]";
  ///  kv['properties'] = "'${JsonHelper.mapToJson(props)}'::jsonb";
  Future<PsqlResult> insertKv(String tbName, Map<String, dynamic> setKv) async {
    return insert(tbName, setKv.keys.toList(), setKv.values.toList());
  }

  Future<PsqlResult> insertKvReturning(String tbName, Map<String, dynamic> setKv, String returnKey) async {
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
  /// conflictExp: (c1, c2,...)                   ColumnName must unique for conflict
  /// conflictExp: (ColumnNames) WHERE ...
  Future<PsqlResult> insertIgnore(String tbName, List<String> columns, List<dynamic> values, {String conflictExp = ''}) async{
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) '
        ' ON CONFLICT $conflictExp DO NOTHING;';
    return execution(query);
  }

  /**
   * if be ignore, isExecuted is false.
   */
  Future<PsqlResult> insertIgnoreWhere(String tbName, Map<String, dynamic> kv, {required String where, String? returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(!r.exist()){
      r._intResult = 0;
      return r;
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

  Future<PsqlResult> insertByAt(String tbName, List<String> columns, Map<String, dynamic> values) async{
    final a = values.keys.map((key) {return '@$key';}).toList();
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${a.join(',')});';

    return execution(query, values: values);
  }

  /// conflict : (col1, col2)   < for unique columns
  /// conflict : ON CONSTRAINT constraint_name
  /// setStatement: SET cName = EXCLUDED.cName
  /// setStatement: SET cName = 50
  Future<PsqlResult> upsert(String tbName, List<String> columns, List<dynamic> values,{required String conflict, String? setStatement}) async {
    setStatement ??= _genUpdateSetStatement(columns, values);

    final query = '''INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) 
         ON CONFLICT $conflict DO UPDATE $setStatement;''';
    return execution(query);
  }

  Future<PsqlResult> upsertWhere(String tbName, List<String> columns, List<dynamic> values,{required String where}) async{
    final r = await exist(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return await update(tbName, _genUpdateSetStatement(columns, values), where);
    }

    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) ON CONFLICT DO NOTHING;';
    return execution(query);
  }

  Future<PsqlResult> upsertKvWhere(String tbName, Map<String, dynamic> kv, {required String where}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return update(tbName, _genUpdateSetStatement(col, val), where);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING;';
    return execution(query);
  }

  Future<PsqlResult> upsertKvReturning(String tbName, Map<String, dynamic> kv, {required String where, required String returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return updateReturning(tbName, _genUpdateSetStatement(col, val), where, returning);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING RETURNING $returning;';
    return queryCall(query);
  }

  Future<PsqlResult> update(String tbName, String setStatement, String? where) async{
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution(query);
  }

  /// UPDATE country set name = 'iran' where iso = 'ir' RETURNING name,iso ;
  Future<PsqlResult> updateReturning(String tbName, String setStatement, String? where, String returning) async {
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where RETURNING $returning;';
    return queryCall(query);
  }

  Future<PsqlResult> updateByAt(String tbName, String setStatement, String? where, Map<String, dynamic> values) async {
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution(query, values: values);
  }

  /// updateKv(DbNames.T_Users, value, ' userId = $userId')
  Future<PsqlResult> updateKv(String tbName, Map<String, dynamic> setKv, String? where, {bool concatJson = false}) async{
    return update(tbName, _genUpdateSetStatementKv(setKv, concatJson: concatJson), where);
  }

  Future<PsqlResult> updateKvByAt(String tbName, Map<String, dynamic> setKv, String? where) async{
    var set = '';
    for(final e in setKv.entries){
      set += '${e.key} = @${e.key},';
    }

    set = set.substring(0, set.length-1);

    return updateByAt(tbName, set, where, setKv);
  }

  Future<PsqlResult> exist(String tbName, String whereCondition) async{
    final q = 'SELECT EXISTS (SELECT * FROM $tbName WHERE $whereCondition LIMIT 1);';

    final res = await queryCall(q);

    if(res.hasError()){
      return res;
    }

    if(res.rowsCount() < 1 || res.firstRow()['exists'] == false){
      res._intResult = 0;
    }
    else {
      res._intResult = 1;
    }

    return res;
  }

  // que: SELECT EXISTS (SELECT ...)
  Future<PsqlResult> existQuery(String que) async {
    final res = await queryCall(que);

    if(res.hasError()){
      return res;
    }

    res._intResult = res.rowsCount() > 0? 1 : 0;

    return res;
  }

  /// note: column name must be lowercase
  Future<PsqlResult> getColumn(String querySt, String columnName) async {
    final cursor = await queryCall(querySt);

    if(cursor.hasError() || cursor.rowsCount() < 1){
      return cursor;
    }

    cursor._oneResult = cursor.firstRow()[columnName];

    return cursor;
  }

  /// SELECT id FROM tb WHERE parent_id = 10;
  /// return int or 'RETURNING' value
  Future<PsqlResult> delete(String tbName, String? where) async {
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where;';
    return execution(query);
  }

  Future<PsqlResult> deleteReturning(String tbName, String? where, {required String? returning}) async {
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where RETURNING $returning;';
    return queryCall(query);
  }

  Future<PsqlResult> deleteByAt(String tbName, String? where, Map<String, dynamic> values) async{
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where;';
    return execution(query, values: values);
  }

  Future<PsqlResult> deleteTableCascade(String tbName) async{
    final query = 'DROP TABLE IF EXISTS $tbName CASCADE;';
    return execution(query);
  }

  Future<PsqlResult> truncateTableCascade(String tbName) async{
    final query = 'TRUNCATE TABLE $tbName RESTART IDENTITY CASCADE;';
    return execution(query);
  }

  Future<PsqlResult> dropAllTable() async{
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

  Future<PsqlResult> getColumnNames(String tableName) async{
    final query = '''
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = '$tableName';
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
///=============================================================================
class PsqlResult {
  static void Function(PsqlResult psqlResult)? onError;

  Object? _exceptionObj;
  StackTrace? stackTrace;
  List<Row>? _rowResult;
  dynamic _oneResult;
  int? _intResult;

  PsqlResult();

  void setException(Object exception){
    _exceptionObj = exception;

    onError?.call(this);
  }

  bool hasError(){
    return _exceptionObj != null;
  }

  bool _empty(){
    return !(_rowResult != null && _rowResult!.isNotEmpty) && _intResult == null;
  }

  bool hasErrorOrEmpty(){
    return hasError() || _empty();
  }

  Object? getError(){
    return _exceptionObj;
  }

  int rowsCount(){
    if(_rowResult == null || hasError()){
      return 0;
    }

    return _rowResult!.length;
  }

  Map<String, dynamic> firstRow(){
    if(_rowResult == null || _rowResult!.isEmpty){
      return <String, dynamic>{};
    }

    return _rowResult!.first.toMap() as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> rows(){
    final res = <Map<String, dynamic>>[];

    for(final i in _rowResult!){
      res.add(i.toMap() as Map<String, dynamic>);
    }

    return res;
  }

  /**
   * this is for (Insert, Update, Delete), if doing return 1.
   */
  bool isExecuted(){
    return !hasError() && _intResult != null && _intResult! > 0;
  }

  bool exist(){
    return isExecuted();
  }

  dynamic returnValue(){
    return _rowResult!.first.toList().first;
  }

  T columnValue<T>(){
    return _oneResult as T;
  }
}