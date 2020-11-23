import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;

  const Profil({Key key, this.profilSahibiId})
      : super(
            key:
                key); //profil widgetının profilSahibiId parametresi almasını sağladık

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gpnderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    setState(() {
      _takipci = takipciSayisi;
    });
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilen =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    setState(() {
      _takipEdilen = takipEdilen;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _cikisYap,
            color: Colors.grey.shade600,
          )
        ],
      ),
      body: FutureBuilder<Object>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: [
                _profilDetaylari(snapshot
                    .data), // çektiğimiz bilgileri profil detayda gösterebiliriz
              ],
            );
          }),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage(profilData.fotoUrl)
                    : AssetImage("assets/images/anonim.png"),
                backgroundColor: Colors.grey.shade300,
                radius: 50.0,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gpnderiSayisi),
                    _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
                    _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(profilData.kullaniciAdi,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          Text(profilData.hakkinda),
          SizedBox(
            height: 25,
          ),
          _profiliDuzenleButonu(),
        ],
      ),
    );
  }

  Widget _profiliDuzenleButonu() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {},
        child: Text("Profili Düzenle"),
      ),
    );
  }

  Widget _sosyalSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
