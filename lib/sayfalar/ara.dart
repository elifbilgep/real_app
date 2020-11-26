import 'package:flutter/material.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/sayfalar/profil.dart';
import 'package:realapp/servisler/firestoreServis.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaKontrol = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 5.0,
      backgroundColor: Colors.grey.shade100,
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaKontrol,
        decoration: InputDecoration(
            hintText: "Kullanıcı ara..",
            contentPadding: EdgeInsets.only(top: 16.0),
            prefixIcon: Icon(
              Icons.search,
              size: 25,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _aramaKontrol.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              },
            ),
            border: InputBorder.none,
            filled: true),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: _aramaSonucu,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(child: Text("Sonuç bulunamadı"));
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              Kullanici kullanici = snapshot.data[index];
              return kullaniciSatiri(kullanici);
            },
          );
        });
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profil(profilSahibiId: kullanici.id,)));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: kullanici.fotoUrl.isEmpty ? AssetImage("assets/images/anonim.png") : NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
