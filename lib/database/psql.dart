import 'package:postgres/postgres.dart';

class Psql {
  late PostgreSQLExecutionContext _sql;
  late PostgreSQLConnection _connection;
  bool _isPrepare = false;

  void open({required String dbName, required String user, required String pass, int port = 5432}) async{
    _connection = PostgreSQLConnection('localhost', port, dbName,
        username: user, password: pass, timeZone: 'UTC', useSSL: false, timeoutInSeconds: 12, isUnixSocket: false);

    _isPrepare = true;
    _sql = await _connection.open();
  }

  bool isOpen(){
    return _isPrepare && !_connection.isClosed;
  }

  Future close(){
    if(_isPrepare) {
      return _connection.close();
    }

    return Future.value(null);
  }

  void cancelTransaction(){
    if(_isPrepare) {
      return _connection.cancelTransaction();
    }
  }

  Future transaction(List<String> queries){
    if(_isPrepare) {
      return _connection.transaction((ctx) async {
        for(var q in queries){
          await ctx.query(q);
        }
      });
    }

    return Future.value(null);
  }

  /*Future<PostgreSQLExecutionContext> _getSql() async{
    return await _connection.open();
  }*/

  Future<List<List<dynamic>>> query(String query, {Map<String, dynamic>? values, bool allowReuse = false}) async{
    if(_isPrepare) {
      return _sql.query(query, substitutionValues: values, allowReuse: allowReuse);
    }

    return Future.value(null);
  }

  Future<int>? execution(String query, {Map<String, dynamic>? values}){
    if(_isPrepare) {
      return _sql.execute(query, substitutionValues: values);
    }

    return null;
  }

  PostgreSQLExecutionContext get sql => _sql;
  PostgreSQLConnection get connection => _connection;
}