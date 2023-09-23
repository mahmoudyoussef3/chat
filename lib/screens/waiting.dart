import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget{
  const WaitingScreen({super.key});
@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(title: const Text('My Chat App'),),body: const Center(child: Text('Loading...'),),);
  }

}