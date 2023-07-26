import 'package:fileupload/Untils/utils.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import '../main.dart';

class SqliteUntil{
  // final DatabaseFactory dbFactory;
  Database? db;

  SqliteUntil(this.db){
    db = this.db;
     // this.initSql();
  }

  initSql()async{
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    NewBase = await databaseFactory.openDatabase("my.db");
    db = this.db;
  }

  void CreateSql()async{
    await NewBase.execute(''' CREATE TABLE Config (id INTEGER PRIMARY KEY, dbPath TEXT,Port TEXT) ''');
  }




  Future<List<Map<String, Object?>>> QuerySql(String value,String? name)async{
    if (name==null){
      var result = await NewBase.query(value);
      print("结果： ${result}");
      print("大小：${result.length}");
      return result;
    }
    var result = await NewBase.query(value,where: 'typename=?',orderBy: "id DESC",whereArgs: [name]);
    print("查询条：${result}");
    print("条件大小：${result.length}");
    ShowToast.ShowToastText("查询成功，请使用");

    return result;

  }
  Future<List<Map<String, Object?>>> QuerySqlLimit(String value)async{
      var result = await NewBase.query(value,orderBy: "id DESC",limit: 1);
      print("结果： ${result}");
      print("大小：${result.length}");
      ShowToast.ShowToastText("更新成功，请使用");
      return result;
  }

  void InsertSql(String dbPath,String Port)async{
    await NewBase.insert('Config', <String, Object?>{'dbPath': dbPath,'Port':Port});
  }





}





class DBHelper {


  //定义了一个静态变量---_dbHelper，保存DBHelper类的单例实例
  static DBHelper? _dbHelper;

  //定义了一个静态方法---getInstance()获取DBHelper的单例实例
  //如果_dbHelper为空，就创建一个新的DBHelper实例
  static DBHelper getInstance() {
    if (_dbHelper == null) {
      _dbHelper = DBHelper();
    }
    return _dbHelper!;
  }

  //_db是一个Database类型的成员，用于存储数据库实例
  Database? db;

  //数据库中的表
  static final String _ALLTask = "_ALLTask"; //所有任务

  //database是一个异步getter，它返回数据库实例。如果_db为空，就调用initDB方法初始化数据库。
  Future<Database> get database async {
    if (db != null) {
      return db!;
    }
    db = await initDB();
    return db!;
  }
  //初始化数据库
 Future<Database> initDB()async{
    logger.d("初始化数据库：");
    //1、初始化数据库
    sqfliteFfiInit();

    //2、获取databaseFactoryFfi对象
    var databaseFactory = databaseFactoryFfi;
    //
    // var databasePath = await getDatabasesPath();
    // var dbPath = path.join(databasePath, 'my_database.db');
    var OkPath = "my.db";
    //3、创建数据库
    return await databaseFactory.openDatabase(
      //数据库路径
      OkPath
    );
  }





  Future<List<Map<String, Object?>>> QuerySql(String value,String? name)async{
    if (name==null){
      var result = await db!.query(value);
      print("结果： ${result}");
      print("大小：${result.length}");
      return result;
    }
    var result = await db!.query(value,where: 'typename=?',orderBy: "id DESC",whereArgs: [name]);
    print("查询条：${result}");
    print("条件大小：${result.length}");
    ShowToast.ShowToastText("查询成功，请使用");

    return result;

  }
  Future<List<Map<String, Object?>>> QuerySqlLimit(String value)async{
    var result = await db!.query(value,orderBy: "id DESC",limit: 1);
    print("结果： ${result}");
    print("大小：${result.length}");
    ShowToast.ShowToastText("更新成功，请使用");
    return result;
  }


}