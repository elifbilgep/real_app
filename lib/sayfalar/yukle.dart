import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/storageServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaKontrol = TextEditingController();
  TextEditingController konumKontrol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
        ),
        onPressed: () {
          fotografSec();
        });
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade500,
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              // ignore: unnecessary_statements
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: _gonderiOlustur)
        ],
      ),
      body: ListView(
        //sayfa kayma gerekeblr die
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          AspectRatio(
            aspectRatio: 16.0 / 12.0,
            child: Image.file(
              dosya,
              fit: BoxFit.cover,
            ),
          ), // aspect ratio en boy ayarlayabilme
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: aciklamaKontrol,
              decoration: InputDecoration(
                  hintText: "Açıklama ekle",
                  contentPadding: EdgeInsets.only(left: 15, right: 15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: konumKontrol,
              decoration: InputDecoration(
                  hintText: "Konum ekle",
                  contentPadding: EdgeInsets.only(left: 15, right: 15)),
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya);
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      await FireStoreServisi().gonderiOlustur(
          gonderiResmiUrl: resimUrl,
          aciklama: aciklamaKontrol.text,
          yayinlayanId: aktifKullaniciId,
          konum: konumKontrol.text);
      setState(() {
        yukleniyor = false;
        aciklamaKontrol.clear();
        konumKontrol.clear();
        dosya = null;
      });
    }
  }

  fotografSec() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi Oluştur"),
          children: [
            SimpleDialogOption(
              child: Text("Fotoğraf Çek"),
              onPressed: () {
                fotoCek();
              },
            ),
            SimpleDialogOption(
              child: Text("Galeriden yükle"),
              onPressed: () {
                galeridenSec();
              },
            ),
            SimpleDialogOption(
              child: Text(
                "İptal",
                textAlign: TextAlign.end,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    ); //kullanıcıyla diyalog kurma
  }

  fotoCek() async {
    Navigator.pop(context);
    try {
      var image = await ImagePicker().getImage(
          source: ImageSource.camera,
          maxHeight: 600,
          maxWidth: 800,
          imageQuality: 80);

      setState(() {
        dosya = File(image.path);
      });
    } catch (hata) {
      print(hata);
    }
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }
}
