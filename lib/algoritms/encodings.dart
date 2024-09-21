import 'dart:convert';
import 'dart:io';

import 'package:enough_convert/enough_convert.dart';

List<int> _readRawBytes(File file) {
  var rafile = file.openSync();
  List<int> data = rafile.readSync(file.lengthSync());
  rafile.closeSync();
  return data;
}

String? readFile(String path, String encoding) {
  var file = File(path);

  switch (encoding) {
    case "utf-8":
    case "u8":
    case "cp65001":
      return file.readAsStringSync();

    case "ascii":
    case "646":
    case "us-ascii":
    case "iso-ir-6":
    case "ansi_x3.4-1968":
    case "ansi_x3.4-1986":
    case "iso_646.irv:1991":
    case "iso646-us":
    case "us":
    case "ibm367":
    case "cp367":
    case "csascii":
      return file.readAsStringSync(encoding: ascii);

    case "latin1":
    case "latin-1":
    case "iso-8859-1":
    case "iso-ir-100":
    case "iso_8859-1":
    case "l1":
    case "ibm819":
    case "cp819":
    case "csisolatin1":
    case "iso8859_1":
    case "iso8859-1":
      var decoder = const Latin1Decoder(allowInvalid: true);
      var data = file.readAsBytesSync();
      return decoder.convert(data);

    case "windows-1251":
    case "cswindows1251":
    case "cp1251":
    case "cp-1251":
      List<int> data = _readRawBytes(file);
      return const Windows1251Codec(allowInvalid: true).decode(data);

    case "windows-1250":
    case "cswindows1250":
    case "cp1250":
    case "cp-1250":
      List<int> data = _readRawBytes(file);
      return const Windows1250Codec(allowInvalid: true).decode(data);

    case "windows-1252":
    case "cswindows1252":
    case "cp1252":
    case "cp-1252":
      List<int> data = _readRawBytes(file);
      return const Windows1252Codec(allowInvalid: true).decode(data);

    case "windows-1253":
    case "cswindows1253":
    case "cp1253":
    case "cp-1253":
      List<int> data = _readRawBytes(file);
      return const Windows1253Codec(allowInvalid: true).decode(data);

    case "windows-1254":
    case "cswindows1254":
    case "cp1254":
    case "cp-1254":
      List<int> data = _readRawBytes(file);
      return const Windows1254Codec(allowInvalid: true).decode(data);

    case "windows-1256":
    case "cswindows1256":
    case "cp1256":
    case "cp-1256":
      List<int> data = _readRawBytes(file);
      return const Windows1256Codec(allowInvalid: true).decode(data);

    case "latin2":
    case "l2":
    case "latin-2":
    case "iso-8859-2":
    case "iso8859-2":
    case "iso8859_2":
    case "cslatin2":
    case "iso_8859-2":
    case "iso-ir-101":
    case "csisolatin2":
      var data = _readRawBytes(file);
      return const Latin2Codec(allowInvalid: true).decode(data);

    case "latin3":
    case "l3":
    case "latin-3":
    case "iso-8859-3":
    case "iso8859-3":
    case "iso8859_3":
    case "cslatin3":
    case "iso_8859-3":
    case "iso-ir-109":
    case "csisolatin3":
      var data = _readRawBytes(file);
      return const Latin3Codec(allowInvalid: true).decode(data);

    case "latin4":
    case "l4":
    case "latin-4":
    case "iso-8859-4":
    case "iso8859-4":
    case "iso8859_4":
    case "cslatin4":
    case "iso_8859-4":
    case "iso-ir-110":
    case "csisolatin4":
      var data = _readRawBytes(file);
      return const Latin4Codec(allowInvalid: true).decode(data);

    case "cyrillic":
    case "iso-8859-5":
    case "iso8859-5":
    case "iso8859_5":
    case "cscyrillic":
    case "iso_8859-5":
    case "iso-ir-144":
    case "csisolatincyrillic":
      var data = _readRawBytes(file);
      return const Latin5Codec(allowInvalid: true).decode(data);

    case "arabic":
    case "iso-8859-6":
    case "iso8859-6":
    case "iso8859_6":
    case "csarabic":
    case "iso_8859-6":
    case "iso-ir-127":
    case "ecma-114":
    case "asmo-708":
    case "cslatinarabic":
      var data = _readRawBytes(file);
      return const Latin6Codec(allowInvalid: true).decode(data);

    case "greek":
    case "greek8":
    case "iso-8859-7":
    case "iso8859-7":
    case "iso8859_7":
    case "csgreek":
    case "iso_8859-7":
    case "iso-ir-126":
    case "csisolatingreek":
    case "elot_928":
    case "ecma-118":
      var data = _readRawBytes(file);
      return const Latin7Codec(allowInvalid: true).decode(data);

    case "hebrew":
    case "iso-8859-8":
    case "iso8859-8":
    case "iso8859_8":
    case "cshebrew":
    case "iso_8859-8":
    case "iso-ir-138":
    case "csisolatinhebrew":
      var data = _readRawBytes(file);
      return const Latin8Codec(allowInvalid: true).decode(data);

    case "l5":
    case "latin5":
    case "latin-5":
    case "iso-8859-9":
    case "iso8859-9":
    case "iso8859_9":
    case "iso_8859-9":
      var data = _readRawBytes(file);
      return const Latin9Codec(allowInvalid: true).decode(data);

    case "l6":
    case "latin6":
    case "latin-6":
    case "iso-8859-10":
    case "iso8859-10":
    case "iso8859_10":
    case "iso_8859-10":
      var data = _readRawBytes(file);
      return const Latin10Codec(allowInvalid: true).decode(data);

    case "iso-8859-11":
    case "iso8859-11":
    case "iso8859_11":
    case "iso_8859-11":
    case "thai":
      var data = _readRawBytes(file);
      return const Latin11Codec(allowInvalid: true).decode(data);

    case "l7":
    case "latin7":
    case "latin-7":
    case "iso-8859-13":
    case "iso8859-13":
    case "iso8859_13":
    case "iso_8859-13":
      var data = _readRawBytes(file);
      return const Latin13Codec(allowInvalid: true).decode(data);

    case "l8":
    case "latin8":
    case "latin-8":
    case "iso-8859-14":
    case "iso8859-14":
    case "iso8859_14":
    case "iso_8859-14":
      var data = _readRawBytes(file);
      return const Latin14Codec(allowInvalid: true).decode(data);

    case "l9":
    case "latin9":
    case "latin-9":
    case "iso-8859-15":
    case "iso8859-15":
    case "iso8859_15":
    case "iso_8859-15":
      var data = _readRawBytes(file);
      return const Latin15Codec(allowInvalid: true).decode(data);

    case "l10":
    case "latin10":
    case "latin-10":
    case "iso-8859-16":
    case "iso8859-16":
    case "iso8859_16":
    case "iso_8859-16":
      var data = _readRawBytes(file);
      return const Latin16Codec(allowInvalid: true).decode(data);

    case "cp-850":
    case "ibm850":
    case "cp850":
    case "cspc850multilingual":
    case "850":
      var data = _readRawBytes(file);
      return const CodePage850Codec(allowInvalid: true).decode(data);

    case "gbk":
    case "936":
    case "cp936":
    case "cp-936":
    case "ms936":
    case "windows-936":
      var data = _readRawBytes(file);
      return const GbkCodec(allowInvalid: true).decode(data);

    case "koi8-r":
    case "cskoi8r":
      var data = _readRawBytes(file);
      return const Koi8rCodec(allowInvalid: true).decode(data);

    case "koi8-u":
    case "cskoi8u":
      var data = _readRawBytes(file);
      return const Koi8uCodec(allowInvalid: true).decode(data);

    case "big5":
    case "big5-tw":
    case "csbig5":
      var data = _readRawBytes(file);
      return const Big5Codec(allowInvalid: true).decode(data);

    default:
      return null;
  }
}
