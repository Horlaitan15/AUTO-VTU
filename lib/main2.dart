
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_service/ussd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' ;
import 'package:sms/sms.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum RequestState {
  Ongoing,
  Success,
  Error,
}

class _MyAppState extends State<MyApp> {
  RequestState _requestState;
  String _requestCode = "";
  String _responseCode = "";

  String _responseMessage = "";
  String _status = "";
 
   String sim1_network = "";
   String sim2_network = "";
   String stringValue1 = "";
   String stringValue2 ="";
  
Timer timer;

@override
void initState() { 
  super.initState();
 // getStringToSF();
  timer = Timer.periodic(Duration(seconds: 15), (Timer t) => checkorder());

 
    
}

Future<void> sendUssdRequest(String ussd,int slot) async {
    setState(() {
      _requestState = RequestState.Ongoing;
    });
    try {
      String responseMessage;
      await Permission.phone.request();
      if (!await Permission.phone.isGranted) {
        print("permission missing");
      }

      responseMessage = await UssdService.makeRequest(
         slot, ussd);

      setState(() {
        _requestState = RequestState.Success;
        _status = "successful";
         
        _responseMessage = responseMessage;
      });

    } catch (e) {
      setState(() {
          _status = "failed";
        _requestState = RequestState.Error;
        _responseCode = e is PlatformException ? e.code : "";
        _responseMessage = e.message;
      });
    }
  }

  

checkorder() async{
   String url = 'https://www.dataking.com.ng/api/automation/';
      Response response = await get(url, headers: {"Content-Type": "application/json"}
          );

          print(response.body);
         var mydata = jsonDecode(response.body);

          print(mydata["ussd"]);
           print(mydata["id"]);
           print(mydata["slot"]);


           if (_requestState != RequestState.Ongoing){
                sendUssdRequest(mydata["ussd"],int.parse(mydata["slot"]));

                 print(_responseMessage);
                print(_requestState);

           if ( _status == "successful"){
               print("sucess");
               print( _responseMessage);
                 String url2 = "https://www.dataking.com.ng/api/automation/?id=${mydata['id']}&&message=$_responseMessage&&status=successful";
      Response response2 = await get(url2, headers: {"Content-Type": "application/json"});

           }

           else if (_status == "failed") {

              print("Error");
               print( _responseMessage);
                 String url2 = "https://www.dataking.com.ng/api/automation/?id=${mydata['id']}&&message=$_responseMessage&&status=failed";
      Response response2 = await get(url2, headers: {"Content-Type": "application/json"});

           }

           }


         

      
}

addStringToSF(String val1,String val2) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('SIM1', val1);
   prefs.setString('SIM2', val2);
   setState(() {
      stringValue1 = prefs.getString('SIM1');
 stringValue2 = prefs.getString('SIM2');

   });
     }

getStringToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
 setState(() {
      stringValue1 = prefs.getString('SIM1');
 stringValue2 = prefs.getString('SIM2');

   });

   
     }


@override
void dispose() {
  timer?.cancel();
  super.dispose();
}

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AUTO VTU'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ENTER SIM 1 NETWORK',
                  ),
                  onChanged: (newValue) {
                    setState(() {
                     sim1_network = newValue;
                    });
                  },
                ),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ENTER SIM 2 NETWORK',
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      sim2_network = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                          addStringToSF(sim1_network,sim2_network);
                        },
                  child: const Text('SAVE'),
                ),



                const SizedBox(height: 20),
                
               
                  Row(
                    children:  <Widget>[
                       Text(
                    "SIM 1 NETWORK: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                   Text(
                   stringValue1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                     
                    ],
                  ),
                  SizedBox(height:20),
                    Row(
                    children:  <Widget>[
                       Text(
                    "SIM 2 NETWORK: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                   Text(
                    stringValue2,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                     
                    ],
                  ),
              
              ]),
        ),
      ),
    );
  }
}