import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/servisler/yetkilendirme.dart';
import 'package:realapp/yonlendirme..dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
      create: (_)=> YetkilendirmeServisi() ,
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Projem',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: Yonlendirme(),
      ),
    );
  }
  
}
