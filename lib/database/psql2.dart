// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:postgresql2/pool.dart';
import 'package:postgresql2/postgresql.dart';

/// https://stackoverflow.com/questions/64210167/unable-to-connect-to-postgres-db-due-to-the-authentication-type-10-is-not-suppor
/*
select pg_reload_conf();

show data_directory;
pg_ctl reload -D C:/Program Files/PostgreSQL/13/data
 */

//typedef SqlBoolResult = ({bool result, String? error});
//typedef SqlObjectResult<T> = ({T? result, String? error});

///=============================================================================
class Psql2 {
  static final _regCls = RegExp("'::");
  Connection? _psqConnection;
  Pool? _pool;
  bool _isPool = false;
  bool autoClosePoolConnection = false;
  String _url = '';
  int _maxConnection = 10;
  List<Connection> _poolConnections = [];
  Function(dynamic message)? onSqlMessage;

  Connection get _connection => _psqConnection!;

  Future open({
    required String dbName,
    required String user,
    required String pass,
    int port = 5432,
    String? server,
    bool usePool = false,
    bool autoClosePoolConnection = false,
    int minPool = 2,
    int maxPool = 10,
    Function(Connection connection)? onPoolOpen,
    Function(dynamic message)? onSqlMessage,
    }) async {///\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    if(server == null) {
      _url = 'postgres://$user:$pass@localhost:$port/$dbName';
    }
    else {
      _url = 'postgres://$user:$pass@$server:$port/$dbName';
    }

    _isPool = usePool;
    this.onSqlMessage = onSqlMessage;
    _maxConnection = minPool;

    if(usePool) {
      _pool = Pool(_url, timeZone: 'UTC', connectionTimeout: Duration(seconds: 12), applicationName: '::AssistanceKit::',
          minConnections: minPool, maxConnections: maxPool,
          idleTimeout: Duration(minutes: 5), // idle between 2 request
          maxLifetime: Duration(minutes: 5), // whole Lifetime of a connection
          restartIfAllConnectionsLeaked: true,
          onOpen: onPoolOpen
      );

      if(onSqlMessage != null){
        _pool!.messages.listen(onSqlMessage);
      }

      this.autoClosePoolConnection = autoClosePoolConnection;
      await _pool!.start();
    }
    else {
      await _connect();
    }
  }

  Future<void> _connect() async {
    if(_isPool){
      return;
    }

    if(_psqConnection != null){
      if(_psqConnection!.state == ConnectionState.idle || _psqConnection!.state == ConnectionState.busy){
        return;
      }
    }

    _psqConnection = await connect(_url, timeZone: 'UTC', connectionTimeout: Duration(seconds: 12), debugName: '::AssistanceKit::');
    _psqConnection!.messages.listen(onSqlMessage);
  }

  bool isOpen(){
    if(_isPool) {
      if(_pool != null){
        return _pool!.state == PoolState.running;
      }
    }
    else {
      if(_psqConnection != null) {
        return _connection.state != ConnectionState.closed || _connection.state != ConnectionState.notConnected;
      }
    }

    return false;
  }

  void close(){
    if(_isPool) {
      _pool?.stop();
    }
    else {
      _psqConnection?.close();
    }
  }

  PoolState? poolState(){
    if(_pool == null) {
      return null;
    }

    return _pool!.state;
  }

  Future<Connection> _getPoolConnection() async {
   _poolConnections.removeWhere((conn) {
      return conn.state == ConnectionState.closed || conn.state == ConnectionState.notConnected;
    });

    Connection? result;

    for(final c in _poolConnections){
        if(c.state == ConnectionState.idle){
          result = c;
          break;
        }
    }

    if(result == null){
      if(_poolConnections.length >= _maxConnection){
        return _poolConnections.first;
      }

      result = await _pool!.connect();
      _poolConnections.add(result);
    }

    return result;
  }

  TransactionState transactionState(){
    if(_isPool || !isOpen()) {
      return TransactionState.unknown;
    }

    return _connection.transactionState;
  }

  Future<T> transaction<T>(Future<T> Function() operation){
    if(isOpen() && !_isPool) {
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

  /// values: queryCall('SELECT color FROM tb WHERE id = @id',  values : {'id': 5})
  /// values: queryCall('SELECT color FROM tb WHERE id IN (@0, @1, @2)',  values: ['10','20','30'])
  Future<PsqlResult<T>> queryCall<T>(String query, {dynamic values}) async {
    if(!isOpen()) {
      await _connect();

      if(!isOpen()) {
        return PsqlResult().._setException(Exception('psql is not connected.'), null);
      }
    }

    final ret = PsqlResult<T>();
    ret._query = query;

    try {
      if (!_isPool) {
        ret._queryRowResult = await _connection.query(query, values).toList();
      }
      else {
        final poolConn = await _getPoolConnection();
        ret._queryRowResult = await poolConn.query(query, values).toList();

        if (autoClosePoolConnection) {
          poolConn.close();
        }
      }
    }
    catch (e, st){
      ret._setException(e, st);
    }

    return ret;
  }

  /// return 1 if correct doing and return 0 if not doing.
  Future<PsqlResult<T>> execution<T>(String query, {dynamic values}) async{
    if(!isOpen()) {
      await _connect();

      if(!isOpen()) {
        return PsqlResult().._setException(Exception('psql is not connected.'), null);
      }
    }

    final ret = PsqlResult<T>();
    ret._query = query;

    try {
      if (!_isPool) {
        ret._executeResult = await _connection.execute(query, values);
      }
      else {
        final c = await _getPoolConnection();
        ret._executeResult = await c.execute(query, values);

        if (autoClosePoolConnection) {
          c.close();
        }
      }
    }
    catch (e, st){
      ret._setException(e, st);
    }

    return ret;
  }

  Future<Stream<Row>?> queryStreaming(String query, {dynamic values}) async{
    if(!isOpen()) {
      await _connect();

      if(!isOpen()) {
        return Future.value(null);
      }
    }

    if(!_isPool){
      return _connection.query(query, values);
    }

    final c = await _getPoolConnection();
    final res = c.query(query, values);

    return res;
  }

  Future<List<T>?> queryMapping<T>(String query, {dynamic values, required T Function(Row row) mapFn}) async {
    if(!isOpen()) {
      await _connect();

      if(!isOpen()) {
        return Future.value(null);
      }
    }

    if(!_isPool){
      return _connection.query(query, values).map<T>(mapFn).toList();
    }

    final c = await _getPoolConnection();
    final res = c.query(query, values).map<T>(mapFn).toList();

    if(autoClosePoolConnection) {
      c.close();
    }

    return res;
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
        buffer.write("\$token\$$val\$token\$");
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

  /// sample: insert(myDbName, ['user_id', 'type'], [123456789, 2]);
  Future<PsqlResult<T>> insert<T>(String tbName, List<String> columns, List<dynamic> values) async {
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)});';

    return execution<T>(query);
  }

  ///  kv['alternatives'] = "'${PublicAccess.psql2.listToValue(alternatives)}'::text[]";
  ///  kv['properties'] = "'${JsonHelper.mapToJson(props)}'::jsonb";
  Future<PsqlResult<T>> insertKv<T>(String tbName, Map<String, dynamic> setKv) async {
    return insert<T>(tbName, setKv.keys.toList(), setKv.values.toList());
  }

  Future<PsqlResult<T>> insertKvReturning<T>(String tbName, Map<String, dynamic> setKv, String returnKey) async {
    final k = setKv.keys.toList();
    final v = setKv.values.toList();

    final q = 'INSERT INTO $tbName (${k.join(',')}) values(${_joinValue(v)}) RETURNING $returnKey;';

    return await queryCall<T>(q);

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
  Future<PsqlResult<T>> insertIgnore<T>(String tbName, List<String> columns, List<dynamic> values, {String conflictExp = ''}) async{
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) '
        ' ON CONFLICT $conflictExp DO NOTHING;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> insertBulk<T>(String tableName, List<Map<String, dynamic>> rows) async {
      if (rows.isEmpty) {
        return PsqlResult<T>();
      }

      final columns = rows.first.keys.toList();
      final colPart = columns.map((c) => '"$c"').join(", ");

      String toSqlValue(dynamic value) {
        if (value == null) return 'NULL';
        if (value is num || value is bool) return value.toString();

        if (value is DateTime) {
          return "'${value.toIso8601String()}'";
        }

        if (value is String) {
          final escaped = value.replaceAll("'", "''");
          return "'$escaped'";
        }

        final escaped = value.toString().replaceAll("'", "''");
        return "'$escaped'";
      }

      final valuesPart = rows.map((row) {
        final vals = columns.map((col) => toSqlValue(row[col])).join(", ");
        return "($vals)";
      }).join(",\n");

      return queryCall<T>('INSERT INTO $tableName ($colPart) VALUES $valuesPart;');
    }

  /// if be ignore, isExecuted() is false.
  Future<PsqlResult<T>> insertIgnoreWhere<T>(String tbName, Map<String, dynamic> kv, {required String where, String? returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist<T>(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(!r.exist()){
      r._existResult = false;
      return r;
    }

    var q = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING';

    if(returning != null){
      q += ' RETURNING $returning;';
      return queryCall<T>(q);
    }
    else {
      q += ';';
      return execution<T>(q);
    }
  }

  Future<PsqlResult<T>> insertByAt<T>(String tbName, List<String> columns, Map<String, dynamic> values) async{
    final a = values.keys.map((key) {return '@$key';}).toList();
    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${a.join(',')});';

    return execution<T>(query, values: values);
  }

  /// conflict : (col1, col2)   < for unique columns
  /// conflict : ON CONSTRAINT constraint_name
  /// setStatement: SET clm = EXCLUDED.clm
  /// setStatement: SET clm = 50
  Future<PsqlResult<T>> upsert<T>(String tbName, List<String> columns, List<dynamic> values,{required String conflict, String? setStatement}) async {
    setStatement ??= _genUpdateSetStatement(columns, values);

    final query = '''INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) 
         ON CONFLICT $conflict DO UPDATE $setStatement;''';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> upsertWhere<T>(String tbName, List<String> columns, List<dynamic> values,{required String where}) async{
    final r = await exist<T>(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return await update<T>(tbName, _genUpdateSetStatement(columns, values), where);
    }

    final query = 'INSERT INTO $tbName (${columns.join(',')}) values(${_joinValue(values)}) ON CONFLICT DO NOTHING;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> upsertKvWhere<T>(String tbName, Map<String, dynamic> kv, {required String updateWhere}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist<T>(tbName, updateWhere);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return update<T>(tbName, _genUpdateSetStatement(col, val), updateWhere);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> upsertKvReturning<T>(String tbName, Map<String, dynamic> kv, {required String where, required String returning}) async{
    final col = kv.keys.toList();
    final val = kv.values.toList();

    final r = await exist<T>(tbName, where);

    if(r.hasError()){
      return r;
    }

    if(r.exist()){
      return updateReturning(tbName, _genUpdateSetStatement(col, val), where, returning);
    }

    final query = 'INSERT INTO $tbName (${col.join(',')}) values(${_joinValue(val)}) ON CONFLICT DO NOTHING RETURNING $returning;';
    return queryCall<T>(query);
  }

  Future<PsqlResult<T>> update<T>(String tbName, String setStatement, String? where) async{
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution<T>(query);
  }

  /// > UPDATE country SET name = 'iran' WHERE iso = 'ir' RETURNING name,iso;
  Future<PsqlResult<T>> updateReturning<T>(String tbName, String setStatement, String? where, String returning) async {
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where RETURNING $returning;';
    return queryCall<T>(query);
  }

  /// sample: updateKv(DbNames.T_Users, value, ' userId = $userId')
  Future<PsqlResult<T>> updateKv<T>(String tbName, Map<String, dynamic> setKv, String? where, {bool concatJson = false}) async{
    return update<T>(tbName, _genUpdateSetStatementKv(setKv, concatJson: concatJson), where);
  }

  Future<PsqlResult<T>> updateByAtSign<T>(String tbName, String setStatement, String? where, Map<String, dynamic> values) async {
    where ??= '1 = 1';

    final query = 'UPDATE $tbName SET $setStatement WHERE $where;';
    return execution<T>(query, values: values);
  }

  Future<PsqlResult<T>> updateKvByAtSign<T>(String tbName, Map<String, dynamic> setKv, String? where) async{
    var set = '';

    for(final e in setKv.entries){
      set += '${e.key} = @${e.key},';
    }

    set = set.substring(0, set.length-1);

    return updateByAtSign<T>(tbName, set, where, setKv);
  }

  /// use isExecuted() for result.
  Future<PsqlResult<T>> exist<T>(String tbName, String whereCondition) async {
    final q = 'SELECT EXISTS (SELECT * FROM $tbName WHERE $whereCondition LIMIT 1);';

    final res = await queryCall<T>(q);

    if(res.hasError()){
      return res;
    }

    if(res.rowsCount() < 1 || res.firstRow()['exists'] == false){
      res._existResult = false;
    }
    else {
      res._existResult = true;
    }

    return res;
  }

  /// sample: SELECT EXISTS (SELECT ...)
  Future<PsqlResult<T>> existQuery<T>(String que) async {
    if(!que.contains('SELECT EXISTS')){
      que = ' SELECT EXISTS ($que)';
    }

    final res = await queryCall<T>(que);

    if(res.hasError()){
      return res;
    }

    res._existResult = res.rowsCount() > 0;

    return res;
  }

  /// SELECT id FROM tb WHERE parent_id = 10;
  /// return int or 'RETURNING' value
  Future<PsqlResult<T>> delete<T>(String tbName, String? where) async {
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> deleteReturning<T>(String tbName, String? where, {required String? returning}) async {
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where RETURNING $returning;';
    return queryCall<T>(query);
  }

  Future<PsqlResult<T>> deleteByAt<T>(String tbName, String? where, Map<String, dynamic> values) async{
    where ??= '1 = 1';

    final query = 'DELETE FROM $tbName WHERE $where;';
    return execution<T>(query, values: values);
  }

  Future<PsqlResult<T>> deleteTableCascade<T>(String tbName) async{
    final query = 'DROP TABLE IF EXISTS $tbName CASCADE;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> truncateTableCascade<T>(String tbName) async{
    final query = 'TRUNCATE TABLE $tbName RESTART IDENTITY CASCADE;';
    return execution<T>(query);
  }

  Future<PsqlResult<T>> dropAllTable<T>() async{
    final query = '''
      DO \$\$
			DECLARE tablenames text;
					BEGIN
					   tablenames := (SELECT string_agg('"' || tablename || '"', ',') FROM pg_tables WHERE schemaname = 'public');
					   EXECUTE 'DROP TABLE ' || tablenames || ' CASCADE';
					END; \$\$
    ''';

    return execution<T>(query);
  }

  Future<PsqlResult<T>> getColumnNames<T>(String tableName) async{
    final query = '''
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = '$tableName';
    ''';

    return queryCall<T>(query);
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
typedef ModelBuilder<T> = T Function(Map<String, dynamic> data);

class PsqlResult<T> {
  static void Function(PsqlResult psqlResult)? onError;

  String? _query;
  Object? _exception;
  StackTrace? stackTrace;
  List<Row>? _queryRowResult;
  bool? _existResult;
  int? _executeResult;
  T? data;
  ModelBuilder<T>? _modelBuilder;

  PsqlResult();

  String? get query => _query;

  T get noNullData {
    if(data != null){
      return data!;
    }

    if(_modelBuilder != null){
      return _modelBuilder!.call(firstRow()) as T;
    }

    return data!;
  }

  void _setException(Object exception, StackTrace? stackTrace){
    _exception = exception;
    this.stackTrace = stackTrace;

    onError?.call(this);
  }

  bool hasError(){
    return _exception != null;
  }

  bool isEmpty(){
    return (_queryRowResult == null || _queryRowResult!.isEmpty) && _executeResult == null;
  }

  bool hasErrorOrEmpty(){
    return hasError() || isEmpty();
  }

  Object? getError(){
    return _exception;
  }

  String? getErrorText(){
    return _exception?.toString();
  }

  int rowsCount(){
    if(_queryRowResult == null || hasError()){
      return -1;
    }

    return _queryRowResult!.length;
  }

  Map<String, dynamic> firstRow(){
    if(isEmpty()){
      return <String, dynamic>{};
    }

    return _queryRowResult!.first.toMap(); // as Map<String, dynamic>
  }

  List<Map<String, dynamic>> rows(){
    final res = <Map<String, dynamic>>[];

    for(final i in _queryRowResult!){
      res.add(i.toMap());
    }

    return res;
  }

  /// this is for (Insert, Update, Delete, Exist), if doing return 1.
  bool isExecuted(){
    return !hasError() && _executeResult != null;
  }

  bool isExecutedSuccess(){
    return !hasError() && _executeResult != null && _executeResult! > 0;
  }

  /*SqlBoolResult buildBoolResult(bool item){
    return (result: item, error: getError()?.toString());
  }

  SqlObjectResult<T> buildObjectResult<T>(T? obj){
    return (result: obj, error: getError()?.toString());
  }*/

  bool exist(){
    return !hasError() && _existResult != null && _existResult == true;
  }

  /// return first column of first record.
  dynamic getReturnValue(){
    return _queryRowResult!.first.toList().first;
  }

  dynamic getReturning(String key){
    return _queryRowResult!.first.toMap()[key];
  }

  void setBuilderModel(ModelBuilder<T> builder){
    _modelBuilder = builder;
  }

  void buildData({ModelBuilder<T>? builder, Map<String, dynamic>? myData}){
    _modelBuilder ??= builder;
    data = _modelBuilder!.call(myData?? firstRow());
  }

  T toModel({ModelBuilder<T>? builder}){
    _modelBuilder ??= builder;
    return _modelBuilder!.call(firstRow());
  }

  List<T> map({ModelBuilder<T>? builder}){
    _modelBuilder ??= builder;
    return rows().map((elm) => _modelBuilder!.call(elm)).toList();
  }

  /// note: column name must be lowercase.
  T? getColumn<T>(String columnName) {
    if(hasError() || rowsCount() < 1){
      return null;
    }

    final clm = _queryRowResult!.first.toMap() [columnName];

    if(clm == null){
      return null;
    }

    return clm as T;
  }
}
