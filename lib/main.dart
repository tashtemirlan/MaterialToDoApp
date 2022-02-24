import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) =>runApp(
       MaterialApp(
        theme: ThemeData(
          colorScheme: ThemeData().colorScheme.copyWith(primary: const Color.fromRGBO(120, 132, 241, 1)),
        ),
          debugShowCheckedModeBanner: false, //hide debug banner
          home: GetDataFromDB())
  ));
}

//after we catch up all data go to First class =>
class GetDataFromDB extends StatelessWidget{
  List<String> data = <String>[];
  List<bool> completed =<bool>[];

  @override
  Widget build(BuildContext context) {

    Future<int> GetData() async {

      //create db =>
      // Get a location using getDatabasesPath
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'data.db');

      //delete database =>
      //await deleteDatabase(path);

      // open the database
      Database database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            // When creating the db, create the table
            await db.execute(
                'CREATE TABLE Data ('
                    'id INTEGER PRIMARY KEY, '
                    'task TEXT,'
                    'completed INTEGER'
                    ')');
          });

      // Get the records
      List<Map> list = await database.rawQuery('SELECT * FROM Data');
      for(int i=0 ; i<list.length;i++){
        String dataStringu = list[i].toString();
        String workingstring = dataStringu.substring(1,dataStringu.length-1).replaceAll(":", "").replaceAll("{", "").replaceAll("}", "");
        for (String a in workingstring.split(", ")) {

          if(a.substring(0,1)=="t"){
            data.add(a.substring(5,a.length));
          }
          if(a.substring(0,1)=="c"){
            String comp = a.substring(10,a.length);
            if(comp=="0"){
              completed.add(false);
            }
            else{
              completed.add(true);
            }
          }
        }
      }
      return 1;
    }
    void getDatases() async {
      await GetData().then((value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>
          First(data, completed)),(route)=>false));
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    getDatases();
   return Container(width: width,height: height, color: Colors.white,);
  }

}

class First extends StatefulWidget{
  final List<String> data;
  final List<bool> completed;

  First(this.data,this.completed);

  @override
  FirstState createState ()=> FirstState(data,completed);
}

class FirstState extends State<First>{
  final List<String> dataList;
  final List<bool> completed;

  FirstState(this.dataList,this.completed);

  bool changed = false;
  TextEditingController task = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(padding: EdgeInsets.only(left: width/20 , right: width/20 , top: height*0.05),
              child:
                  Container(width: width*0.9, height: height*0.335,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25) ,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(padding: EdgeInsets.only(left: 20),child:
                        SizedBox(width: width*0.9-20, height: height*0.25,
                          child: TextFormField(
                              minLines: 1, maxLines: 10,
                              controller: task, keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  hintStyle: TextStyle(fontSize: 16 , color: Colors.grey),
                                  hintText: "Введите Задачу", labelText: "Новая Задача" , labelStyle: TextStyle(fontSize: 16, color: Colors.grey)),
                              style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 16 , fontWeight: FontWeight.bold , color: Colors.black)),validator: (String?value){
                            if(value == null ||value.isEmpty){
                              return "PLEASE ENTER YOUR LOGIN OR EMAIL";}
                            return null;})
                          ,)),
                        SizedBox(width: width*0.45, height: 40,
                          child: ElevatedButton(
                              child: Text("Создать" ,
                              style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 16, color: Colors.white))),
                              onPressed:() async {
                                //add to list data =>
                                if(task.text.isNotEmpty){
                                  //add code to add value to DB
                                  //open our database =>
                                  // Get a location using getDatabasesPath
                                  var databasesPath = await getDatabasesPath();
                                  String path = join(databasesPath, 'data.db');

                                  // open the database
                                  Database database = await openDatabase(path, version: 1,
                                      onCreate: (Database db, int version) async {});
                                  String data = task.text;
                                  // Insert some records in a transaction
                                  await database.transaction((txn) async {
                                    int id1 = await txn.rawInsert(
                                        'INSERT INTO Data(task, completed) VALUES("$data", 0)');
                                  }).then((value) =>
                                      setState(() async {
                                        dataList.add(task.text);
                                        completed.add(false);
                                        task.text="";
                                        changed = true;
                                        //show that task added successfully =>
                                        Fluttertoast.showToast(
                                            msg: "Задача добавлена",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 14.0
                                        );
                                        changed = false;
                                        //repeat our setState =>
                                        setState(() {

                                        });
                                      })
                                  );
                                }
                              },
                              style:ElevatedButton.styleFrom(
                                  primary: const Color.fromRGBO(120, 132, 241, 1) ,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                              )
                          ),
                        )
                      ],
                    )
                  ),
                  //here appear button =>
            ),
            Padding(padding: EdgeInsets.only(left: width/20 , right: width/20 ),
              child: Container(width: width, height: height*0.5515 ,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(25) ,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                ),
                child: (changed)?Task(dataList, completed):Task(dataList, completed),
              )
            )
            //here we will build up our list where will be all tasks
          ],
        )
    );
  }
}
class Task extends StatefulWidget{
  final List<String> data;
  final List<bool> complete;

  const Task(this.data,this.complete);
  TaskState createState()=>TaskState(data, complete);
}
class TaskState extends State<Task>{
  final List<String> dataList;
  final List<bool> complete;

  TaskState(this.dataList,this.complete);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListView.builder(padding: EdgeInsets.all(0),scrollDirection: Axis.vertical,shrinkWrap: false,
        itemCount: dataList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int idx){
          if(idx==-1){
            return Container(width: 0,height: 0);
          }
          else{
            return _ourTask(dataList[idx],complete[idx],width, height , idx);
          }
        });
  }
  _ourTask(String data, bool completed,double width , double height , int position){

    TextEditingController task = TextEditingController();
    //set data to our text controller =>
    task.text=data;
    //set that we type to changing text start from the end =>
    task.selection = TextSelection.fromPosition(TextPosition(offset: task.text.length));

    return Padding(padding: EdgeInsets.only(top: height*0.025 , left: width/20 , right: width/20),
        child: Container(
          width: width*0.9, height: data.length.toDouble()/2+54,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: width*0.8-80,
              child:(completed)?AutoSizeText(
                    data,
                    style:  GoogleFonts.comicNeue(textStyle: TextStyle(fontSize: 18, color: (completed)?Colors.grey:Colors.black), decoration: TextDecoration.lineThrough) , )
                    :
                  TextFormField(
                      keyboardType: TextInputType.text,
                      controller: task,
                      minLines: 1,
                      maxLines: 1000,
                      onEditingComplete: () async {
                        //do when editing is complete =>
                        //add code to work with DB =>

                        var databasesPath = await getDatabasesPath();
                        String path = join(databasesPath, 'data.db');

                        // open the database
                        Database database = await openDatabase(path, version: 1,
                            onCreate: (Database db, int version) async {});

                        //now we should update our row in our database
                        int rightpos = position +1;
                        String datatoupdate = task.text;
                        // Update some record
                        int count = await database.rawUpdate(
                            'UPDATE Data SET task = ? WHERE id = ?',
                            ['$datatoupdate', '$rightpos']);
                        setState(() {
                          dataList[position]=task.text;
                          //show that task saved successfully =>
                          Fluttertoast.showToast(
                              msg: "Изменения Сохранены",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 14.0
                          );
                        });
                      },
                      decoration: const InputDecoration(
                        enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 16 , fontWeight: FontWeight.bold , color: Colors.black)),validator: (String?value){
                    if(value == null ||value.isEmpty){
                      return "PLEASE ENTER YOUR LOGIN OR EMAIL";}
                    return null;}
                    ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                      GestureDetector(
                        onTap: () async {
                          //make task completed =>
                          if(completed){
                            //don't do anything =>
                          }
                          else{
                            bool newval = !completed;
                            //open our database =>
                            // Get a location using getDatabasesPath
                            var databasesPath = await getDatabasesPath();
                            String path = join(databasesPath, 'data.db');

                            // open the database
                            Database database = await openDatabase(path, version: 1,
                                onCreate: (Database db, int version) async {});

                            //now we should update our row in our database =>
                            int rightpos = position +1;
                            // Update some record
                            int count = await database.rawUpdate(
                                'UPDATE Data SET completed = ? WHERE id = ?',
                                ['1', '$rightpos']);
                            setState(() {
                              complete[position]=newval;
                              //show that task completed successfully =>
                              Fluttertoast.showToast(
                                  msg: "Задача выполнена",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 14.0
                              );
                              //add here code for working with db
                            });
                          }
                        },
                        child: Padding(padding: const EdgeInsets.only(left: 5) , child:Icon(
                            (completed)?Icons.check_circle_outline_sharp: Icons.circle_outlined ,
                            size: 34,
                            color: (completed)?const Color.fromRGBO(0, 231, 119, 1):const Color.fromRGBO(215, 223, 226, 1)),
                      )),
                      GestureDetector(
                        onTap: () async {
                          //delete that element =>
                          //open our database =>
                          // Get a location using getDatabasesPath
                          var databasesPath = await getDatabasesPath();
                          String path = join(databasesPath, 'data.db');

                          // open the database
                          Database database = await openDatabase(path, version: 1,
                              onCreate: (Database db, int version) async {});

                          //now we should update our row in our database =>

                          String datatodelete = task.text;
                          // Delete a record
                          int count = await database
                              .rawDelete('DELETE FROM Data WHERE task = ?', ['$datatodelete']);

                          setState(() {
                            dataList.removeAt(position);
                            complete.removeAt(position);
                            //show that task deleted successfully =>
                            Fluttertoast.showToast(
                                msg: "Задача удалена",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 2,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 14.0
                            );
                            //add code to delete value from DB
                          });
                        },
                        child: const Padding(padding: EdgeInsets.only(left: 5) , child: Icon(Icons.delete_outline , size: 34,),),
                      ),
                ],
              ),
            ],
          ),
        )
    );
  }
}