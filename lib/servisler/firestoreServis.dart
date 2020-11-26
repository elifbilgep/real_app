import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realapp/modeller/gonderi.dart';
import 'package:realapp/modeller/kullanici.dart';

class FireStoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman =
      DateTime.now(); //veritabanına kayıt eklerken kayıt zamanı için kullanıcaz

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    //fotoUrl i googledan gireni googleinkini çekcez mail gireninki boş dönsün diye ilk halini boş atıyoruz
    await _firestore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulanZaman": zaman,
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  kullaniciGuncelle(
      {String kullaniciId,
      String kullaniciAdi,
      String fotoUrl = "",
      String hakkinda}) {
    _firestore.collection("kullanicilar").doc(kullaniciId).update({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl,
    });
  }

   Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .get();

    List<Kullanici> kullanicilar = snapshot.docs
        .map((doc) => Kullanici.dokumandanUret(doc))
        .toList(); //kullanıcı dökümanını kullanıcı objesine dönüştürme
    return kullanicilar;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipçiler")
        .doc(kullaniciId)
        .collection("kullanicininTakipcileri")
        .get();

    return snapshot.docs.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipEdilenler")
        .doc(kullaniciId)
        .collection("kullanicininTakipleri")
        .get();

    return snapshot.docs.length;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore
        .collection("gonderiler")
        .doc(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman,
    });
  }

  Future<List<Gonderi>> gonderiGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .doc(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        //yeniden eskiye çekme
        .get();
    List<Gonderi> gonderilerr =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderilerr;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi  ilişkisini beğeniler koleksiyonuna ekle
      _firestore
          .collection("begenilen")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .set({});
    }
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      //Kullanıcı-Gönderi  ilişkisini beğeniler koleksiyonundan kaldır
      DocumentSnapshot docBegeni = await _firestore
          .collection("begenilen")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarMi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begenilen")
        .doc(gonderi.id)
        .collection("gonderiBegenileri")
        .doc(aktifKullaniciId)
        .get();

    if (docBegeni.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .doc(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulanZaman", descending: true)
        .snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String icerik}) {
    _firestore
        .collection("yorumlar")
        .doc(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulanZaman": zaman,
    });
  }
}
