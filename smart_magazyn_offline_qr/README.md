# Smart Magazyn Offline — wersja na jeden tablet

To jest wersja bez backendu, bez serwera SQL i bez internetu. Wszystko działa lokalnie na jednym tablecie z Androidem.

## Co zawiera system

1. Aplikacja Flutter na Androida.
2. Lokalna baza SQLite zapisywana w pamięci tabletu.
3. Lokalne logowanie użytkowników.
4. Dodawanie przedmiotów do magazynu.
5. Nadawanie unikalnego kodu `SM-XXXXXXXXXX`.
6. Druk etykiety Zebra w ZPL: QR + kod kreskowy.
7. Skanowanie kodów kamerą tabletu.
8. Wyświetlanie informacji:
   - nazwa przedmiotu,
   - kod,
   - opis,
   - rodzina przedmiotu,
   - ilość przedmiotów z tej samej rodziny,
   - właściciel,
   - ostatni użytkownik,
   - lokalizacja,
   - status.
9. Historia skanowań w tabeli `scan_history`.

## Architektura

txt
Tablet Android
 ├── aplikacja Flutter
 ├── lokalna baza SQLite
 ├── kamera do skanowania QR/kodów
 └── lokalne połączenie TCP/IP do drukarki Zebra


