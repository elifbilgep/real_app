import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/sayfalar/hesapolustur.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
        child: Stack(
          children: [_sayfaElemanlari(context), _yuklemeAnimasyonu()],
        ),
      ),
    );
  }

  _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaElemanlari(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(//sayfa kayabilir
          children: [
        FlutterLogo(size: 90),
        SizedBox(
          height: 80,
        ),
        TextFormField(
          validator: (girilenDeger) {
            if (girilenDeger.isEmpty) {
              return "E-mail alanı boş bırakılamaz";
            } else if (!girilenDeger.contains("@")) {
              return "Girilen değer mail formatında olmalı";
            }
            return null;
          },
          onSaved: (girilenDeger) => email = girilenDeger,
          autocorrect: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 14),
            hintText: "E-mail adresinizi girin..",
            prefixIcon: Icon(Icons.mail),
          ),
        ),
        SizedBox(height: 40),
        TextFormField(
          validator: (girilenDeger) {
            if (girilenDeger.isEmpty) {
              return "Şifre alanı boş bırakılamaz";
            } else if (girilenDeger.trim().length < 4) {
              return "Şifre 4 karakterden az olamaz";
            }
            return null;
          },
          onSaved: (girilenDeger) => sifre = girilenDeger,
          obscureText: true,
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 14),
            hintText: "Şifrenizi girin",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        SizedBox(height: 40),
        Row(children: [
          Expanded(
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HesapOlustur()));
              },
              child: Text(
                "Hesap oluştur",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: FlatButton(
              onPressed: _girisYap,
              child: Text(
                "Giriş Yap",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ]),
        SizedBox(
          height: 20,
        ),
        Center(
            child: Text(
          "Veya",
          style: TextStyle(color: Colors.grey),
        )),
        SizedBox(
          height: 20,
        ),
        Center(
            child: InkWell(
          onTap: _googleIleGiris,
          child: Text(
            "Google İle Giriş Yap",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontSize: 19),
          ),
        )),
        SizedBox(
          height: 20,
        ),
        Center(
            child: Text(
          "Şifremi Unuttum",
          style: TextStyle(color: Colors.grey.shade500),
        )),
      ]),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("Giriş İşlemleri Başarılı");
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
      } catch (hata) {
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;
    if (hataKodu == "user-not-found") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "email-already-in-use") {
      hataMesaji = "Girdiğiniz mail zaten  kayıtlıdır";
    } else if (hataKodu == "wrong-password") {
      hataMesaji = "Yanlış Şifre";
    }

    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    if (yukleniyor) {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  void _googleIleGiris() async {
    setState(() {
      yukleniyor = true;
    });
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
    if (kullanici != null) {
      Kullanici firestoreKullanici =
          await FireStoreServisi().kullaniciGetir(kullanici.id);
      if (firestoreKullanici == null) {
        FireStoreServisi().kullaniciOlustur(
            id: kullanici.id,
            email: kullanici.email,
            kullaniciAdi: kullanici.kullaniciAdi,
            fotoUrl: kullanici.fotoUrl);
        print("Kullanici dökümanı oluşturuldu");
      }
    }
  }
}
