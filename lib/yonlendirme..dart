import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/sayfalar/anasayfa.dart';
import 'package:realapp/sayfalar/giris_sayfasi.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasData) {
          Kullanici aktifKullanici = snapshot.data;
          _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.id;
          return AnaSayfa();
        } else {
          return GirisSayfasi();
        }
      },
    );
  }
}
