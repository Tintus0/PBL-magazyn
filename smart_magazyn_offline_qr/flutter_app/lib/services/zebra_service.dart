import 'dart:async';
import 'dart:io';
import '../models/item.dart';

class ZebraService {
  static String escapeZplText(String? value) {
    return (value ?? '').replaceAll('^', ' ').replaceAll('~', ' ');
  }

  static String buildQrAndBarcodeLabel(WarehouseItem item) {
    final code = escapeZplText(item.code);
    final name = escapeZplText(item.name);
    final family = escapeZplText(item.familyName ?? 'Brak rodziny');
    final owner = escapeZplText(item.ownerName);
    final quantity = item.quantity.toString();

    // Etykieta 60x40 mm, 203 dpi: ok. 480x320 punktów.
    return '''^XA
^CI28
^PW480
^LL320
^FO25,25^A0N,28,28^FD$name^FS
^FO25,60^A0N,21,21^FDKod: $code^FS
^FO25,88^A0N,21,21^FDRodzina: $family^FS
^FO25,116^A0N,21,21^FDWlasciciel: $owner^FS
^FO25,144^A0N,21,21^FDIlosc: $quantity^FS
^FO300,35^BQN,2,5^FDLA,$code^FS
^FO25,248^BY2,2,45^BCN,45,Y,N,N^FD$code^FS
^XZ''';
  }

  static Future<void> printLabel({
    required String host,
    int port = 9100,
    required WarehouseItem item,
  }) async {
    if (host.trim().isEmpty) {
      throw Exception('Brak IP drukarki Zebra. Ustaw IP w ekranie ustawień.');
    }

    final socket = await Socket.connect(host.trim(), port, timeout: const Duration(seconds: 5));
    socket.write(buildQrAndBarcodeLabel(item));
    await socket.flush();
    await socket.close();
  }
}
