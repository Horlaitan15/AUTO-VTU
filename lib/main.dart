
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_service/ussd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' ;

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
   bool start = false;
  
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
  prefs.setString('Baseurl', val1);
  
   setState(() {
      stringValue1 = prefs.getString('Baseurl');

   });
     }

getStringToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
 setState(() {
      stringValue1 = prefs.getString('Baseurl');

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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        
        
        appBar: AppBar(
          title: const Text('AUTO VTU'),
          backgroundColor: Colors.orange,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Theme(
          data: new ThemeData(
            primaryColor: Colors.redAccent,
            primaryColorDark: Colors.red,
          ),
          child: new TextField(
            onChanged: (newValue) {
                    setState(() {
                     sim1_network = newValue;
                    });
                  },
            decoration: InputDecoration(
                border:  OutlineInputBorder(
                    borderSide:  BorderSide(color: Colors.teal)),
                hintText: 'i.e https://www.dataking.com',
                helperText: 'Base API url to fetch your requests from',
                labelText: 'ENTER BASE URL',
                prefixIcon: Icon(
                  Icons.link,
                  color: Colors.green,
                ),
                prefixText: ' ',
                suffixText: 'ENTER BASE URL',
                suffixStyle: const TextStyle(color: Colors.green)),
          ),
        ),
               
               
                const SizedBox(height: 20),
                MaterialButton(
                  color: Colors.orange,
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
                    "BASE URL: ",
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange,),
                  ),
                   Text(
                   stringValue1,
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange,),
                  ),
                     
                    ],
                  ),

                  SizedBox(height:30),
                   MaterialButton(
                  color:start? Colors.red : Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                         setState(() {
                           start = !start;
                         }); 
                        },
                  child: start? Text('STOP') : Text('START'),
                ),
                  
              
              ]),
        ),
      ),
    );
  }
}