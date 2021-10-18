import 'dart:async';
import 'package:mysql1/mysql1.dart';

Future ConnectDB() async {
  final condb = await MySqlConnection.connect(ConnectionSettings(host: 'localhost', port: 3306, user: 'root', db: 'db_deteksibendaberbahaya', password: ''));
}
