


import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/BDM/bdm_customer_list.dart';
import 'package:beposoft/pages/BDM/bdm_order_list.dart';
import 'package:beposoft/pages/BDM/bdm_order_request.dart';
import 'package:beposoft/pages/BDM/bdm_proforma_invoice.dart';
import 'package:flutter/material.dart';

class hr_dashbord extends StatefulWidget {
  const hr_dashbord({super.key});

  @override
  State<hr_dashbord> createState() => _hr_dashbordState();
}

class _hr_dashbordState extends State<hr_dashbord> {
  

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(

        actions: [
            IconButton(
              icon: Image.asset('lib/assets/profile.png'),
               
              onPressed: () {
                
              },
            ),
          ],
          
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          
          children: [
            Container(
              width: 10, // Customize the width here
              child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 110, 110, 110),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "lib/assets/logo-white.png",
                        width: 100, // Change width to desired size
                        height: 100, // Change height to desired size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to maintain aspect ratio
                      ),
                      SizedBox(width: 70,),
                      Text(
                        'BepoSoft',
                        style: TextStyle(
                          color: Color.fromARGB(236, 255, 255, 255),
                          fontSize: 20,
                         
                        ),
                      ),
                      
                    ],
                  )),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>hr_dashbord()));

              },
            ),
            

              
              
              
               ListTile(
                leading: Icon(Icons.sports_basketball),
                title: Text('Users'),
              
                onTap: () {
                 
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('User list'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 3');
                              },
                            ),
                            ListTile(
                              title: Text('Attendance '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 4');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              
               ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chats'),
              onTap: () {},
            ),  
            ],
          ),
        ),
        body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 50),
                child: Text(
                  "DASHBOARD",
                  style: TextStyle(
                    letterSpacing: 13.0,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 76, 175, 144)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Number of Bills ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "0",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(width: 85,),
                                      
                                      ],
                                    ),  Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(255, 228, 195, 3)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Waiting for approval",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "25/5",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                     
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

               Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(241, 192, 81, 88)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Todays Shipped orders",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Text(
                                          "1",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Delivary Boxes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "25/5",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                       
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

               Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                               color: const Color.fromARGB(255, 76, 175, 144)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Customers",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "54",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                      
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                             color: Color.fromARGB(255, 0, 153, 241)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Proforma Invoice",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "0",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                      
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(255, 228, 195, 3)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Total Orders",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "0",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                       
                                      
                                      ],
                                    ),
                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey

                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "GRV Created",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "25/5",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                       
                                      ],
                                    ),

                                    Row(
                                      
                                      children: [
                                        SizedBox(width: 120,),
                                        Image.asset(
                                              "lib/assets/right.png",
                                              width: 25,
                                              height: 25,
                                              fit: BoxFit.contain,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

 
            
            ],
          ),
        ),
      ),

      );
    

  }

   void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    
    switch (selectedOption) {
      case 'Option 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdm_performa_invoice()),
        );
        break;
      case 'Option 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>credit_note_list()),
        );
        break;
        case 'Option 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdm_order_request()),
        );
        break;
        case 'Option 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdm_oredr_list()),
        );
        break; 
      default:
        // Handle default case or unexpected options
        break;
    }
  }


   
}
