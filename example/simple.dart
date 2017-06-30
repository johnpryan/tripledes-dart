import 'package:tripledes/tripledes.dart';

main() {
  var key = "cipher";
  var blockCipher = new BlockCipher(new DESEngine(), key);
  var message = "Driving in from the edge of town";
  var ciphertext = blockCipher.encodeB64(message);
  var decoded = blockCipher.decodeB64(ciphertext);

  print("key: $key");
  print("message: $message");
  print("ciphertext (base64): $ciphertext");
  print("decoded ciphertext: $decoded");
}