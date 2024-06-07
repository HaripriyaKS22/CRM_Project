
import 'package:flutter/material.dart';
class Attribute extends ChangeNotifier
{
 static int counter=1;



 var r1;
 var r2;


//   int increment()
//  { 

  
//   r1=counter+1;
//   return r1;
 
//  }
//  int decrement(count){
//   print("counter value in decr $count");
//   var r2=count-1;
 

//   print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr $r2");
//   return r2;

 

//  }

 int set(int set1){
  

  if(set1==1){
    
    counter=counter+1;
    print(counter);

  }
  else{
     counter=counter-1;
     
     


  }
   return counter;
  

 }



  

}

