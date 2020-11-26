import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/storageServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfiliDuzenle({Key key, this.profil}) : super(key: key);
  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _secilmisFoto;
  bool _yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: _kaydet,
          )
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          _profilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState.save();

      String yeniProfilFotoUrl;
      if (_secilmisFoto == null) {
        yeniProfilFotoUrl = widget.profil.fotoUrl;
      } else {
        yeniProfilFotoUrl =
            await StorageServisi().profilResmiYukle(_secilmisFoto);
      }

      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FireStoreServisi().kullaniciGuncelle(
          kullaniciId: aktifKullaniciId,
          kullaniciAdi: _kullaniciAdi,
          hakkinda: _hakkinda,
          fotoUrl: yeniProfilFotoUrl);

      setState(() {
        _yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
          child: CircleAvatar(
            backgroundImage: _secilmisFoto == null
                ? NetworkImage(widget.profil.fotoUrl)
                : FileImage(_secilmisFoto),
            backgroundColor: Colors.pink.shade100,
            radius: 55,
          ),
        ),
      ),
    );
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              validator: (girilenDeger) {
                return girilenDeger.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalı!"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda,
              validator: (girilenDeger) {
                return girilenDeger.trim().length >= 100
                    ? "100 karakterden fazla girilmez!"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
              decoration: InputDecoration(labelText: "Hakkında"),
            ),
          ],
        ),
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      _secilmisFoto = File(image.path);
    });
  }
}
