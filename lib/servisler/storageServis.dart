import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageServisi {
  Reference _storage = FirebaseStorage.instance.ref();
  String resimId;


  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();//random isimlendirme yapmak için kullanılır
    UploadTask yuklemeYoneticisi = _storage.child("resimler/gonderiler/gonderi_$resimId.jpg").putFile(resimDosyasi);// burda da kullandık
    TaskSnapshot snapshot = await yuklemeYoneticisi;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
  }
}
