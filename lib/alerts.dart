import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'globals.dart' as global;
class alerts extends StatefulWidget{
  @override
  _alertsState createState() => _alertsState();
}
class _alertsState extends State<alerts>{
  bool isAnyAlert = false;
  DatabaseReference _ref;
  List alertList =[];

  final FirebaseDatabase database = FirebaseDatabase();
  @override
  void initState() {
    super.initState();
    getAlerts();
  }
  getAlerts(){
    _ref = database.reference().child('alerts');
    _ref.child(global.UserId).once().then((DataSnapshot snapshot) {
      
      if(snapshot.value != null){
        var data = json.encode(snapshot.value);
        Map<dynamic, dynamic> map = json.decode(data);
        for(var v in map.values){
          alertList.add(v);

        }
        setState(() {
          isAnyAlert = true;
          alertList.reversed;
        });

      }
      else{
        print("No Alerts");
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alerts")
      ),
      body: isAnyAlert ? Container(
        child: ListView.builder(
          itemCount: alertList?.length,
            itemBuilder: (_,index){
              return ListTile(
                title: Text(alertList[index]['center_name']),
                subtitle: Text(alertList[index]['date_created']),
                trailing: alertList[index]['isAlerted'] ? Icon(Icons.check,color: Colors.green,)
                    :Icon(Icons.priority_high_outlined,color:Colors.red),
              );
            }),
      ):Container(
        child: Center(child:Text("No Alerts Available")),
      )
    );
  }

}