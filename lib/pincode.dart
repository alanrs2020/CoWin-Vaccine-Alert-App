import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class pincode extends StatefulWidget{
  @override
  pincodeState createState() => pincodeState();

}
class pincodeState extends State<pincode>{
  bool searchState = false;
  List sessionList = [];
  bool noTextError = false;
  final _controller = new TextEditingController();

  getSession(pincode) async {
    String date = DateTime
        .now()
        .day
        .toString() + "-" + DateTime
        .now()
        .month
        .toString() + "-" + DateTime
        .now()
        .year
        .toString();
    print(date);
    var url = Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$pincode&date=$date');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if (response.statusCode.toString() == "200") {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      //print(result['states']);
      var session = result['centers'];


      if (session != null) {
        // print(session[1]);
        return session;
      } else {
        print("No Session found");
        return null;
      }
    } else {
      print("Error Occurred");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search by Pincode",style:TextStyle(color:Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: !searchState ? Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("images/bg.jpg"), fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: "Enter pin-code",
                  border: OutlineInputBorder()
              ),

            ),
            Container(
                height:40,
                width:90,
                color: Colors.black54,
                child: Center(
                  child: TextButton(
                    child: Text("Search",style: TextStyle(color: Colors.white),),
                    onPressed: ()async{

                      if(_controller.text != ""){
                        sessionList = await getSession(_controller.text);
                        setState(() {
                          noTextError = !noTextError;
                          searchState = true;
                        });
                      }else{
                        setState(() {
                          noTextError = true;
                        });
                      }
                    },
                  ),
                )
            ),

            noTextError ?
                Text("Enter the pincode",style:TextStyle(color: Colors.red)):
            Text(" ")
          ],
        ),
      ):
      sessionList != null ?
      Container(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
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
                sessionList[index]['sessions'][0]['min_age_limit']);

          },
        ),
      ):
      Container(
        child:Text("No centers available"),
      )
    );
  }
  Widget _SessionContainer(String name,String state,String district,pinCode,String address,blockName,feeType,fee,vaccine,dose1,dose2,age){
    return Card(
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.topLeft,
          child: Column(


            children: [
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
                Text("Free",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green))
              ]),
              dose1 == 0 && dose2 == 0 ? Container(
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
              ):
              Container(
                  height:40,
                  width:90,
                  color: Colors.green,
                  child: Center(
                    child: TextButton(
                      child: Text("Book Now",style: TextStyle(color: Colors.white)),
                      onPressed: (){

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