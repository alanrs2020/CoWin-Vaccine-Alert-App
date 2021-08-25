import 'dart:convert';

import 'package:cowinapp/pincode.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as global;
// ignore: camel_case_types
class district extends StatefulWidget{
  @override
 districtState  createState() => districtState();

}
// ignore: camel_case_types
class districtState extends State<district>{
  List states =["Select"];
  List districts = ["Select"];
  List sessionList = [];
  List sessionListSearch = [];
  Map<dynamic, dynamic> districtMap = new Map();
 // Map<String,String> districtMap = Map();
  String dropdownValue = 'Select';
  String downValue = "Select";
  bool stateSelected = false;
  bool stateLoaded = false;
  bool searchState = false;
  bool searching = false;
  DatabaseReference _ref;
  var SessionUrl;
  final FirebaseDatabase database = FirebaseDatabase();

  Map<dynamic, dynamic> sessionMap = new Map();

  final searchConroller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    searchConroller.addListener(() {
      String text = searchConroller.text.toLowerCase();

      if(text.length >0){

        for(var i=0;i<sessionList.length;i++){
          if(sessionList[i]['name'].toLowerCase().contains(text))
            {
              setState(() {
                sessionListSearch?.clear();
                sessionListSearch.add(sessionList[i]);
                searching = true;
              });
            }else{
            setState(() {
              //sessionListSearch?.clear();
             // searching = false;
            });
          }
        }
      }else{
        setState(() {
          searching =false;
        });
      }
     // if(searchState && searchConroller.state == ){


    });
    getStates();

  }
  @override
  void setState(fn) {
    super.setState(fn);

  }

  void getStates() async{
    var url = Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if(response.statusCode.toString() == "200"){
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      //print(result['states']);
      var state = result['states'];
      for(var i=0;i<state.length;i++){

        print("$i" +state[i]['state_name']);
       setState(() {
         states.add(state[i]['state_name']);
         print("List "+states[i]);
         stateLoaded = true;
       });

      }
    }else{
      print("Error Occurred");
    }

  }
  void getDistricts(stateId) async{
    var url = Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/districts/$stateId');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if(response.statusCode.toString() == "200"){
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      //print(result['states']);
      var district = result['districts'];

      for(var i=0;i<district.length;i++){

      //  print("$i" +district[i]['district_name']);
        setState(() {
          districts.add(district[i]['district_name']);

          districtMap[district[i]['district_name']] = district[i]['district_id'];

          //districtsId.add(district[i]['district_id']);
         // print("List "+districts[i]);
          stateSelected = true;
        });

      }
      print(districtMap);
    }else{
      print("Error Occurred");
    }

  }
   getSession(districtId) async{
    String date = DateTime.now().day.toString()+"-"+DateTime.now().month.toString()+"-"+DateTime.now().year.toString();
    print(date);
    SessionUrl = Uri.parse('https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtId&date=$date');
    var response = await http.get(SessionUrl);
    print('Response status: ${response.statusCode}');
    if(response.statusCode.toString() == "200"){
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      //print(result['states']);
      var session = result['centers'];


        if(session != null){
         // print(session[1]);
          return session;
        }else{

          print("No Session found");
          return null;
        }



    }else{
      print("Error Occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search By District",style:TextStyle(color:Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: !searchState ?
      Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("images/bg.jpg"), fit: BoxFit.cover),
          ),
          padding: EdgeInsets.all(10),
          child: stateLoaded ?Column(
            children: [
              InputDecorator(
                decoration: InputDecoration(

                  labelText: 'State',
                  labelStyle: Theme.of(context).primaryTextTheme.caption.copyWith(color: Colors.black),
                  border: const OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    isDense: true, // Reduces the dropdowns height by +/- 50%
                    icon: Icon(Icons.keyboard_arrow_down),
                    value: dropdownValue,
                    items: states.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (selectedItem) => setState(() {
                      dropdownValue = selectedItem;
                      int state_id = states.indexOf(selectedItem);
                      districts?.clear();
                      districts.add("Select");
                      districtMap?.clear();
                      print(state_id-1);
                      getDistricts(state_id-1);

                    }
                    ),
                  ),
                ),
              ),
              stateSelected ? InputDecorator(
                decoration: InputDecoration(
                  labelText: 'District',
                  labelStyle: Theme.of(context).primaryTextTheme.caption.copyWith(color: Colors.black),
                  border: const OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    isDense: true, // Reduces the dropdowns height by +/- 50%
                    icon: Icon(Icons.keyboard_arrow_down),
                    value: downValue != null ? downValue:"Select",
                    items: districts.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (selectedItem) => setState(() => downValue = selectedItem,
                    ),
                  ),
                ),
              ):
              Container(),
              downValue != 'Select' ?
              TextButton(onPressed: ()async{
                int districtId = districtMap[downValue];
                sessionList?.clear();
                sessionList = await getSession(districtId);
                setState(() {

                  searchState = true;
                });
              },
                child: Container(
                  height: 50,
                  width: 100,
                  color: Colors.redAccent,
                  child: Center(
                    child: Text("Search",style: TextStyle(color: Colors.white),),
                  ),
                ),

              ):
              Text("Select State & District")
            ],
          ):
          Center(
              child:CircularProgressIndicator()
          )
      ):
         sessionList != null ?
         Container(
           padding: EdgeInsets.all(10),
           child: Column(
             children: [
               TextField(
                 controller: searchConroller,
                 decoration: InputDecoration(
                   hintText: "Search",
                   icon: Icon(Icons.search),
                   border: OutlineInputBorder(),

                 ),
               ),
               Expanded
                 (

                 child: !searching ? ListView.builder(
                   itemCount: sessionList?.length,
                   itemBuilder: (_,index){
                     var fee = sessionList[index]['fee_type'];
                     if(fee == "Free")
                       fee= "Free";
                     else
                       fee = sessionList[index]['vaccine_fees'][0]['fee'];
                     return _SessionContainer(sessionList[index]['name'], sessionList[index]['state_name'], sessionList[index]['district_name'],
                         sessionList[index]['pincode'], sessionList[index]['address'],
                         sessionList[index]['block_name'],sessionList[index]['fee_type'],
                         fee,sessionList[index]['sessions'][0]['vaccine'],
                         sessionList[index]['sessions'][0]['available_capacity_dose1'],sessionList[index]['sessions'][0]['available_capacity_dose2'],
                         sessionList[index]['sessions'][0]['min_age_limit'],sessionList[index]['sessions'][0]['date']);

                   },
                 ):sessionListSearch != null ? ListView.builder(
                   itemCount: sessionListSearch?.length,
                   itemBuilder: (_,index){
                     var fee = sessionListSearch[index]['fee_type'];
                     if(fee == "Free")
                       fee= "Free";
                     else
                        sessionListSearch[index]['fee'] == null ?
                        fee = sessionListSearch[index]['vaccine_fees'][0]['fee']:
                        fee = sessionListSearch[index]['fee'];
                     return _SessionContainer(sessionListSearch[index]['name'], sessionListSearch[index]['state_name'], sessionListSearch[index]['district_name'],
                         sessionListSearch[index]['pincode'], sessionListSearch[index]['address'],
                         sessionListSearch[index]['block_name'],sessionListSearch[index]['fee_type'],
                         fee,sessionListSearch[index]['sessions'][0]['vaccine'],
                         sessionListSearch[index]['sessions'][0]['available_capacity_dose1'],sessionListSearch[index]['sessions'][0]['available_capacity_dose2'],
                         sessionListSearch[index]['sessions'][0]['min_age_limit'],sessionListSearch[index]['sessions'][0]['date']);

                   },
                 ):Container(child:Text("No center found"))
               )
             ],
           )
         ):
             Container(
               child:Text("No centers available"),
             )
    );
  }


Widget _SessionContainer(name,state,district,pinCode,address,blockName,feeType,fee,vaccine,dose1,dose2,age,date){
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.topLeft,
        child: Column(

          
          children: [
            Text(date),
            Row(children: <Widget>[
              Text("Name ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(name),
            ]),
            Row(children: <Widget>[
              Text("State ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(state),
            ]),
            Row(children: <Widget>[
              Text("District ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(district),
            ]),
            Row(children: <Widget>[
              Text("Pincode ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("$pinCode"),
            ]),
            Row(children: <Widget>[
              Text("Address ", style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(child: Text(address)),
            ]),

            Row(children: <Widget>[
              Text("Block Name ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(blockName),
            ]),
            Row(children: <Widget>[
              Text("Age ", style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(child: Text("$age +")),
            ]),
            Row(children: <Widget>[
              Text("Vaccine ", style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(child: Text(vaccine)),
            ]),
            Row(children: <Widget>[
              Text("Dose 1 ", style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(child: Text("$dose1")),
            ]),
            Row(children: <Widget>[
              Text("Dose 2 ", style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(child: Text("$dose2")),
            ]),
            Row(children: <Widget>[
              Text("Fee ", style: TextStyle(fontWeight: FontWeight.bold)),
              feeType == "Paid"?
              Text("$feeType \u{20B9} $fee",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)):
              Text("$feeType",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green))
            ]),
           dose1 == 0 && dose2 == 0 ?
           Row(
               children: <Widget>[
                 Container(
                     height:40,
                     width:90,
                     color: Colors.red,
                     child: Center(
                       child: TextButton(
                         child: Text("Booked",style: TextStyle(color: Colors.white)),
                         onPressed: (){

                         },
                       ),
                     )
                 ),
                 Container(
                     height:40,
                     width:90,
                     color: Colors.black87,
                     child: Center(
                       child: TextButton(
                         child: Text("Notify Me",style: TextStyle(color: Colors.white)),
                         onPressed: (){
                           print(global.UserId);
                           print(SessionUrl);
                           _ref = database.reference().child('alerts');
                           _ref.child(global.UserId).child(name).set(
                               {
                                 "center_name":name,
                                 "date_created":date,
                                 "district_url":'$SessionUrl',
                                  "isAlerted":false,
                                 "user_id":global.UserId
                               });
                           Fluttertoast.showToast(msg: "Notify when available !!");
                         },
                       ),
                     )
                 )
             ]
           ):
           Container(
               height:40,
               width:90,
               color: Colors.green,
               child: Center(
                 child: TextButton(
                   child: Text("Book Now",style: TextStyle(color: Colors.white)),
                   onPressed: ()async{
                     const url = "https://www.cowin.gov.in/";
                     if(await canLaunch(url)){
                       await launch(url);
                     }else{
                       Fluttertoast.showToast(msg: "Can't open try again.");
                     }
                   },
                 ),
               )
           )
          ],


        ),
      )
    );
}
}