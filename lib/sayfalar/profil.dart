import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/gonderi.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/sayfalar/profiliDuzenle.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';
import 'package:realapp/widgetlar/gonderikarti.dart';

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
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  String _aktifKullaniciId;
  Kullanici _profilSahibi;

  _gonderileriGetir() async {
    try {
      List<Gonderi> gonderiler =
          await FireStoreServisi().gonderiGetir(widget.profilSahibiId);
      if (mounted) {
        setState(() {
          _gonderiler = gonderiler;
          _gonderiSayisi = _gonderiler.length;
        });
      }
    } catch (hata) {
      print("hata:" + hata);
    }
  }

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilen =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilen;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
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
            // bu snapshot kullanıcının bilgilerini tutuyor
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            _profilSahibi = snapshot.data;

            return ListView(
              children: [
                _profilDetaylari(snapshot
                    .data), // çektiğimiz bilgileri profil detayda gösterebiliriz
                _gonderileriGoster(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
        itemCount: _gonderiler.length,
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });

      return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    // gonderi parametresinin veri türü bilinmediği için sadece gönderi yazdığımızda resmin url sine ulaşamadık
    return GridTile(
      child: Image.network(
        gonderi.gonderiResmiUrl,
        fit: BoxFit.cover,
      ),
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
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
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
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButonu()
              : Text("Takip et butonu"),
        ],
      ),
    );
  }

  Widget _profiliDuzenleButonu() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfiliDuzenle(profil: _profilSahibi,)));
        },
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
