


import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/login.dart';
import 'package:beposoft/pages/ACCOUNTS/register.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/HR/hr_dashboard.dart';
import 'package:beposoft/pages/LOGISTICS/logistics_dashboard.dart';
import 'package:flutter/material.dart';




void main() {
  runApp(beposoftmain());
}

class beposoftmain extends StatelessWidget {
  const beposoftmain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: beposoft(),
    );
  }
}
class beposoft extends StatefulWidget {
  const beposoft({super.key});

  @override
  State<beposoft> createState() => _beposoftState();
}

class _beposoftState extends State<beposoft> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>dashboard()));
          }, child: Text("accounts")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>bdm_dashbord()));
          }, child: Text("bdm")),
           ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>bdo_dashbord()));
          }, child: Text("bdo")),

          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>hr_dashbord()));
          }, child: Text("hr")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>logistics_dashbord()));
          }, child: Text("logistics")),
           ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
          }, child: Text("login"))
        ],
      ),

    );
  }
}
