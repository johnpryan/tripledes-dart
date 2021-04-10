// Copyright (c) 2017, john. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tripledes/src/utils.dart';
import 'package:tripledes/tripledes.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  group('Triple DES', () {
    test('1', () {
      new TestCase('800101010101010180010101010101018001010101010101',
              '0000000000000000', '95a8d72813daa94d', true)
          .run();
    });

    test('2', () {
      new TestCase('010101010101010201010101010101020101010101010102',
              '0000000000000000', '869efd7f9f265a09', true)
          .run();
    });
    test('3', () {
      new TestCase('010101010101010101010101010101010101010101010101',
              '8000000000000000', '95f8a5e5dd31d900', true)
          .run();
    });
    test('4', () {
      new TestCase('010101010101010101010101010101010101010101010101',
              '0000000000000001', '166b40b44aba4bd6', true)
          .run();
    });
    test('5', () {
      new TestCase('800101010101010180010101010101018001010101010101',
              '0000000000000000', '95a8d72813daa94d', false)
          .run();
    });
    test('6', () {
      new TestCase('010101010101010201010101010101020101010101010102',
              '0000000000000000', '869efd7f9f265a09', false)
          .run();
    });
    test('7', () {
      new TestCase('010101010101010101010101010101010101010101010101',
              '8000000000000000', '95f8a5e5dd31d900', false)
          .run();
    });
    test('8', () {
      new TestCase('010101010101010101010101010101010101010101010101',
              '0000000000000001', '166b40b44aba4bd6', false)
          .run();
    });

    test('encode and decode', () {
      var inp = 'Hello, World!';
      var inpEncoded = utf8ToWords(inp);
      var inpDecoded = wordsToUtf8(inpEncoded);
      expect(inpDecoded, startsWith(inp));
    });

    test('encode and decode 2', () {
      var inp = 'HflZXsTrj9kJzNmBsw/fqg==';
      var inpEncoded = utf8ToWords(inp);
      var inpDecoded = wordsToUtf8(inpEncoded);
      expect(inpDecoded, startsWith(inp));
    });

    test('decodeWordArray', () {
      expect(wordsToUtf8([0x12345678, 0, 0, 0]), equals("\x12\x34\x56\x78"));
    });

    test('encodeWordArray', () {
      expect(utf8ToWords("\x12\x34\x56\x78").first, equals(0x12345678));
    });

    test('UTF-8 => word array', () {
      var inp = 'Hello, World!';
      var cipher = 'cipher';
      var expected = "HflZXsTrj9kJzNmBsw/fqg==";
      var inpEncoded = utf8ToWords(inp);
      var cipherEncoded = utf8ToWords(cipher);

      var b = new DESEngine();
      b.init(true, cipherEncoded);
      var result = b.process(inpEncoded);

      expect(base64.encode(wordsToUtf8(result).codeUnits), equals(expected));
    });

    test('decode Base 64', () {
      var cipherTextB64 = "HflZXsTrj9kJzNmBsw/fqg==";
      var cipherTextWords = parseBase64(cipherTextB64);
      var cipher = utf8ToWords('cipher');
      var b = new DESEngine();
      b.init(false, cipher);
      var result = b.process(cipherTextWords);
      expect(wordsToUtf8(result), equals('Hello, World!'));
    });

    test('public API', () {
      var blockCipher = new BlockCipher(new DESEngine(), "cipher");
      var message = "Driving in from the edge of town";
      var ciphertext = blockCipher.encode(message);
      var decoded = blockCipher.decode(ciphertext);
      expect(decoded, equals(message));
    });

    test('public API Base64', () {
      var blockCipher = new BlockCipher(new DESEngine(), "cipher");
      var message = "Driving in from the edge of town";
      var ciphertext = blockCipher.encodeB64(message);
      var decoded = blockCipher.decodeB64(ciphertext);
      expect(decoded, equals(message));
    });

    test('odd length with even key', () {
      var blockCipher = new BlockCipher(new DESEngine(), "somekeys");
      // length 177
      var message = r'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
          'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
      var ciphertext = blockCipher.encode(message);
      var decoded = blockCipher.decode(ciphertext);
      expect(decoded, equals(message));
    });
  });
}

class TestCase {
  final String key;
  final String inp;
  final String expected;
  final bool encrypt;

  TestCase(this.key, this.inp, this.expected, this.encrypt);

  void run() {
    var key = hexParse(this.key);
    var b = new TripleDESEngine();
    var inp = hexParse(this.inp);
    var expected = hexParse(this.expected);
    b.init(true, key);
    var result = new List<int?>.from(inp);
    b.processBlock(result, 0);
    expect(result, equals(expected));
    expect(hexToString(result), equals(this.expected));
  }
}

List<int> hexParse(String hexStr) {
  // Shortcut
  var hexStrLength = hexStr.length;

  // Convert
  var words = new List.generate(hexStrLength, (_) => 0);
  for (var i = 0; i < hexStrLength; i += 2) {
    words[i >> 3] |=
        (int.parse(hexStr.substring(i, i + 2), radix: 16).toSigned(32) <<
                (24 - (i % 8) * 4))
            .toSigned(32);
  }

  return new List.generate(hexStrLength ~/ 2, (i) => words[i]);
}

String hexToString(List<int?> wordArray) {
  // Shortcuts
  var words = wordArray.toList();
  var sigBytes = wordArray.length;

  // Convert
  var hexChars = [];
  for (var i = 0; i < sigBytes; i++) {
    var bite = (words[i >> 2]! >> (24 - (i % 4) * 8)) & 0xff;
    hexChars.add((bite >> 4).toRadixString(16));
    hexChars.add((bite & 0x0f).toRadixString(16));
  }
  return hexChars.join('');
}
