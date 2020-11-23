import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/sayfalar/akis.dart';
import 'package:realapp/sayfalar/ara.dart';
import 'package:realapp/sayfalar/bildirimler.dart';
import 'package:realapp/sayfalar/profil.dart';
import 'package:realapp/sayfalar/yukle.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  PageController sayfaKumandasi;

  @override
  void initState() {
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sayfaKumandasi.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context,listen: false).aktifKullaniciId;
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: [Akis(), Ara(), Yukle(), Bildirimler(), Profil(profilSahibiId: aktifKullaniciId,)],
      ), // içerisine eklenen widgetların herbiri sayfa olur
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifSayfaNo,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Akış"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Keşfet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: "Yükle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Bildirimler"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profi"),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
