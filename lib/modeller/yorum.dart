import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulanZaman;

  Yorum({this.id, this.icerik, this.yayinlayanId, this.olusturulanZaman});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Yorum(
      id: doc.id,
      icerik : docData["icerik"],
      yayinlayanId: docData["yayinlayanId"],
      olusturulanZaman: docData["olusturulanZaman"]
    );
  }
}
