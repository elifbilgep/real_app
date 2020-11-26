import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realapp/modeller/gonderi.dart';
import 'package:realapp/modeller/kullanici.dart';
import 'package:realapp/sayfalar/yorumlar.dart';
import 'package:realapp/servisler/firestoreServis.dart';
import 'package:realapp/servisler/yetkilendirme.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.gonderi.begeniSayisi;
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    begeniVarMi();
  }

  begeniVarMi() async {
    bool begeniVarmiymis =
        await FireStoreServisi().begeniVarMi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmiymis) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _begendin = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            bottom:
                8.0), //iki tane kaydırılabilir widgetın iç içe olduğu için container üzerinden kaydıramıyoruz
        child: Column(
          children: [_gonderiBasligi(), _gonderiResmi(), _gonderiAlt()],
        ));
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
              ? NetworkImage(widget.yayinlayan.fotoUrl)
              : AssetImage("assets/images/anonim.png"),
        ),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {
          null;
        },
      ),
      contentPadding: EdgeInsets.all(0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: !_begendin
                    ? Icon(
                        Icons.favorite_border,
                        size: 25,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 25,
                        color: Colors.red,
                      ),
                onPressed: _begeniDegistir),
            IconButton(
                icon: Icon(
                  Icons.comment,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Yorumlar(gonderi:widget.gonderi)));
                }),
          ],
        ),
        Text(
          "  $_begeniSayisi beğeni",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                      text: widget.yayinlayan.kullaniciAdi + " ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                            text: widget.gonderi.aciklama,
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14))
                      ]),
                ),
              )
            : SizedBox(
                height: 0,
              )
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      //beğeni kaldırılcak
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FireStoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      //beğeni eklenicek,
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
