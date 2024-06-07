
import 'package:beposoft/pages/ACCOUNTS/register.dart';
import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
          
            children: [
              SizedBox(height: 100,),
               Image.asset(
                          "lib/assets/logo_black.png",
                          width: 100, // Change width to desired size
                          height: 100, // Change height to desired size
                          fit: BoxFit
                              .contain, // Use BoxFit.contain to maintain aspect ratio
                        ),
                       
                      
        Padding(
          padding: const EdgeInsets.only(left: 20,),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Responsive width
            height: MediaQuery.of(context).size.height * 0.5, // Responsive height
            decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                      children: [
                      
                         Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
              color: Color.fromARGB(255, 38, 156, 235),
              borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
              ),
              border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
              boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 254, 252, 252).withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 1),
                      ),
              ],
                        ),
                        child: Column(
              children: [
                      Text(
                        " Sign in",
                        style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 13),
                      // Add more widgets here as needed
              ],
                        ),
                      ),
                    
                           SizedBox(height: 20,),
                      
                       TextField(
                            decoration: InputDecoration(
                              labelText: 'username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                          ),
                           SizedBox(height: 15,),
                      
                         
                         
                     
                      
                          ElevatedButton(onPressed: (){}, style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                     Color.fromARGB(255, 38, 156, 235),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1), // Set your desired border radius
                      ),
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(300, 15), // Set your desired width and heigh
                    ),
                  ), child: Text('Sign in',style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 20,),
                


                  Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>register()));
                        },
                        child: Text("I forgot my password",style: TextStyle(color: Color.fromARGB(255, 38, 156, 235) ),)),
                            ],
                          ),
                          SizedBox(height: 10,),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>register()));
                        },
                        child: Text("Register a new membership",style: TextStyle(color: Color.fromARGB(255, 38, 156, 235) ),)),
                            ],
                          )
                  
                      ],
              ),
            ),
          ),
        ),
        
            ],
          ),
        ),
      ),
    );
  }
}