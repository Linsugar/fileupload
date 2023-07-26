import 'dart:convert';
import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:fileupload/Untils/SqlUse.dart';
import 'package:fileupload/Untils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fileupload/Untils/Wind.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


late Database NewBase;
var logger = Logger();
late SqliteUntil sql;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  NewBase = await databaseFactory.openDatabase("my.db");
  logger.d(NewBase.path);
  sql = SqliteUntil(NewBase);
  DartVLC.initialize();
  WindowUtil.init(width: 1200.0, height: 800.0);
  WindowUtil.setResizable(false);
  logger.d("初始化");
  runApp(ProviderScope(child: MyApp(),));

}






class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      theme: ThemeData(
        primarySwatch: Colors.blue,),
      home: MyHomePage(),
    );
  }
}




// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       builder: EasyLoading.init(),
//       theme: ThemeData(
//           primarySwatch: Colors.blue,),
//       home: MyHomePage(),
//     );
//   }
// }





class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});
  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logger.d("debug 调用");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var IsShowRight = ref.watch(TestProvider);
    var IsShowCenter = ref.watch(EventProvider);
    logger.d("IsShowRight:${IsShowRight}");
    logger.d("IsShowCenter:${IsShowCenter}");
    return   Row(
      children: [
        Left(),
        CenterWidget(),
        IsShowRight.isEmpty?SizedBox():WidgetRight()


      ],
    );
  }


}



final leftProvider = StateProvider.autoDispose((ref) => 20000);
final ActiveProvider = StateProvider.autoDispose((ref) => true);

class Left extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var value = ref.watch(todosProvider);
    var leftState = ref.watch(leftProvider);
    var ActiveState = ref.watch(ActiveProvider);
    logger.d("状态：${leftState}");
    List<String> keyList = [];
    logger.d("value:${value}");

    if (value.isNotEmpty){
      var result = jsonDecode(value[0]["typename"].toString());
      Iterable<String> keys = result.keys;
      keyList = keys.toList();
    }
    // TODO: implement build
    return Expanded(
      flex: 2,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  Row(
                    children: [
                      SelectableText("回调地址：http://localhost:8555/call",style:GetTypeText(15,Colors.black)),
                      Container(
                        height: 30,

                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.black)
                            ),
                            onPressed: ()async{
                              if(ActiveState){
                                // var path2 = sql.database;
                                // logger.d(path2);
                                // var patah = await sql.initDB();
                                // logger.d(patah.path);
                                WindowUtil.StartEXE(NewBase.path);
                                ref.read(ActiveProvider.notifier).state = false;
                              }else{
                                logger.d("开始杀掉进程");
                                WindowUtil.StartEXE("quit");
                                ref.read(ActiveProvider.notifier).state = true;
                              }
                              logger.d("重置");
                            }, child: Text(ActiveState?"启动":"启动中",style:GetTypeText(13,Colors.white),)),
                      )

                    ],),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      SelectableText("上传文件地址：http://localhost:8555/uploadFile",style:GetTypeText(15,Colors.black))
                    ],),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: ()async{
                          var value = await sql.QuerySqlLimit("Abilities");
                          ref.read(todosProvider.notifier).addTodo(value);
                        },
                        child:FaIcon(FontAwesomeIcons.arrowsRotate,size: 30,)),
                      SizedBox(width: 20,),
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: 430,
              child:value.isEmpty?Center(child: Text("暂无数据,请刷新",style:GetTypeText(20,Colors.black)),):ListView.separated(
                  itemBuilder: (BuildContext context,int index){
                    return Container(
                      height:50,

                      child: Center(
                        child: ListTile(
                          leading: FaIcon(FontAwesomeIcons.hippo,color: Colors.blue[200],),
                          title: Text(keyList[index],style:GetTypeText(15,Colors.red)),
                          trailing: InkWell(onTap: ()async{
                            var result = await sql.QuerySql("Event",keyList[index]);
                            ref.read(leftProvider.notifier).state = index;
                            ref.read(EventProvider.notifier).addTodo(result);
                            ref.read(centerProvider.notifier).state = 20000;
                          },child: FaIcon(FontAwesomeIcons.folderOpen,color: leftState==index?Colors.blue:Colors.blueGrey,)),
                        ),
                      ),
                    );
                  }, separatorBuilder: (BuildContext context,int index){
                return SizedBox(
                  height: 5,
                );
              }, itemCount: keyList.length),
            ),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 40,
                    width: 70,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black)
                        ),
                        onPressed: (){
                          logger.d("重置");
                          ref.read(TestProvider.notifier).addTodo({});
                        }, child: Text("重置",style:GetTypeText(15,Colors.white))),
                  ),

                  Container(
                    height: 40,
                    width: 130,
                    child: ElevatedButton(

                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black)
                        ),
                        onPressed: ()async{
                          ShowToast.ShowToastText("该功能暂不可用");
                         // await sql.QuerySql("Event","CoverlessTruck");
                        }, child: Text("打扫系统文件",style:GetTypeText(15,Colors.white),)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );;
  }

}

final centerProvider = StateProvider.autoDispose((ref) => 20000);

class CenterWidget extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var value = ref.watch(EventProvider);
    var centerState = ref.watch(centerProvider);
   // logger.d("center:${value}");
    // TODO: implement build
    return Expanded(
      flex: 2,
      child:value.isEmpty?Center(child: Text("请选择类型",style:GetTypeText(20,Colors.black)),): Container(
        child: ListView.separated(itemBuilder: (context,index){
          return InkWell(
            onTap: ()async{
              ref.read(TestProvider.notifier).addTodo(value[index]);
              ref.read(IamgeProvider).clear();
              ref.read(IamgeProvider.notifier).addTodo(value[index]["PhotoPath"].toString());
              ref.read(IamgeProvider.notifier).addTodo(value[index]["PreviewPath"].toString());
              ref.read(LocalProvider.notifier).addTodo(value[index]["localVideoPath"].toString());
              ref.read(centerProvider.notifier).state = index;
            },
            child: Container(
              color: centerState==index?Colors.red:Colors.white,
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 3,child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(value[index]["PhotoPath"].toString())),
                            fit: BoxFit.cover
                        )
                    ),
                  )),
                  SizedBox(width: 10,),
                  Expanded(flex: 7,child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("相机ID：${value[index]["cameraId"]}",style: GetTypeText(13,Colors.black),),
                        Text("事件类型：${value[index]["typename"]}",style: GetTypeText(13,Colors.black)),
                        Text("发生时间：${value[index]["EventTime"]}",style: GetTypeText(13,Colors.black)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );

        }, separatorBuilder: (context,index){
          return Divider();
        }, itemCount: value.length),
      ),
    );
  }

}


class WidgetRight extends ConsumerWidget{

  final player = Player(id: 69420,commandlineArguments: ['--no-video']);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.d("WidgetRight");
    var value = ref.watch(TestProvider);
    logger.d("value:${value}");
    var ImageList = ref.watch(IamgeProvider);
    var localvideo = ref.watch(LocalProvider);
    final network = Media.file(File(localvideo));
    player.open(network,autoStart: true);

    return  Expanded(flex: 3,child:Column(
      children: [
        Expanded(flex: 4,child: Container(child: Swiper(
          itemBuilder: (BuildContext context,int index){
            return Image.file(File(ImageList[index]),fit: BoxFit.fill,);
          },
          itemCount: ImageList.length,
          pagination: SwiperPagination(),
          control: SwiperControl(),
        ),
        ),),
        SizedBox(height: 10,),
        Expanded(flex: 5,child: Column(children: [
          Video(
            player: player,
            height: 300.0,
            width: 540.0,
            scale: 1.0, // default
            showControls: true, // default
          ),
        ],)),
        SizedBox(height: 5,),
        Expanded(flex: 2,child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("相机ID：${value["cameraId"]}",style: GetTypeText(13,Colors.black),),
            Text("事件类型：${value["typename"]}",style: GetTypeText(13,Colors.black)),
            Text("发生时间：${value["EventTime"]}",style: GetTypeText(13,Colors.black)),
          ],
        ))

      ],
    ));
  }

}



class TodosNotifier extends StateNotifier<List<Map<String, Object?>>> {
  TodosNotifier() : super([]);

  void addTodo(List<Map<String, Object?>> todo) {
    state = todo;
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, List<Map<String, Object?>>>((ref) {
  return TodosNotifier();
});


class EventNotifier extends StateNotifier<List<Map<String, Object?>>> {
  EventNotifier() : super([]);

  void addTodo(List<Map<String, Object?>> todo) {
    state = todo;
  }
}

final EventProvider = StateNotifierProvider<EventNotifier, List<Map<String, Object?>>>((ref) {
  return EventNotifier();
});




class TestNotifier extends StateNotifier<Map<String, Object?>> {
  TestNotifier() : super({});

  void addTodo(Map<String, Object?> todo) {
    state = todo;
  }
}

final TestProvider = StateNotifierProvider<TestNotifier, Map<String, Object?>>((ref) {
  return TestNotifier();
});




class ImageNotifier extends StateNotifier<List<String>> {
  ImageNotifier() : super([]);

  void addTodo(String todo) {
    state = [...state,todo];
  }
}

final IamgeProvider = StateNotifierProvider<ImageNotifier, List<String>>((ref) {
  return ImageNotifier();
});



class LocalNotifier extends StateNotifier<String> {
  LocalNotifier() : super("");
  void addTodo(String todo) {
    state = todo;
  }
}

final LocalProvider = StateNotifierProvider<LocalNotifier, String>((ref) {
  return LocalNotifier();
});

