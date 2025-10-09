import 'package:flutter/material.dart';

class WalkeTracker extends StatelessWidget {
  const WalkeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: const Text(
            'Walk Tracker',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
          Row(children: [
           Padding(
             padding: const EdgeInsets.only(bottom: 7.0),
             child: Icon(Icons.directions_walk_rounded,size: 35,color: Colors.teal,),
           ),
           Icon(Icons.directions_walk_rounded,size: 27,color: Colors.teal,),
           Icon(Icons.directions_walk_rounded,size: 22,color: Colors.teal,),
           Padding(
             padding: const EdgeInsets.only(top: 10.0),
             child: Text('...',style:TextStyle(color: Colors.teal),),
           ),
         ],),

      ],
    );
  }
}
