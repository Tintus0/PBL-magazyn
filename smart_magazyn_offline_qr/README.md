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

```txt
Tablet Android
 ├── aplikacja Flutter
 ├── lokalna baza SQLite
 ├── kamera do skanowania QR/kodów
 └── lokalne połączenie TCP/IP do drukarki Zebra
```

Internet nie jest wymagany. Do drukowania Zebra po IP tablet i drukarka muszą być tylko w tej samej lokalnej sieci Wi-Fi/LAN. Router może nie mieć internetu.

## Ważna sprawa: SQL vs SQLite

Chciałeś zwykły SQL. Przy wersji na jeden tablet bez internetu i bez serwera najlepszy wybór to SQLite, czyli lokalna baza SQL w pliku. Nie stawia się MySQL/MariaDB bezpośrednio na tablecie, bo to byłoby bez sensu do takiego zastosowania.

Schemat bazy masz w:

```txt
sql/schema_sqlite.sql
```

Aplikacja tworzy tę bazę automatycznie przy pierwszym uruchomieniu.

## Domyślni użytkownicy

```txt
login: admin
hasło: admin123

login: pracownik
hasło: pracownik123
```

## Struktura bazy

### `users`

Użytkownicy aplikacji.

Najważniejsze pola:

- `id`
- `username`
- `password_hash`
- `full_name`
- `role`

### `item_families`

Rodziny / typy przedmiotów, np. elektronika, narzędzia, części zamienne.

### `items`

Przedmioty magazynowe.

Najważniejsze pola:

- `code` — kod drukowany na etykiecie i skanowany,
- `name` — nazwa,
- `description` — opis,
- `family_id` — rodzina,
- `owner_user_id` — właściciel,
- `last_user_id` — ostatni użytkownik po skanowaniu,
- `location` — lokalizacja,
- `status` — status.

### `scan_history`

Historia skanowań.

### `app_settings`

Ustawienia lokalne, np. IP drukarki Zebra.

## Jak uruchomić projekt w Flutterze

Wymagania na komputerze:

- Flutter SDK,
- Android Studio albo Android SDK,
- tablet z Androidem,
- kabel USB albo możliwość przeniesienia pliku APK.

Wejdź do folderu aplikacji:

```bash
cd flutter_app
```

Pobierz zależności:

```bash
flutter pub get
```

Uruchom na podłączonym tablecie:

```bash
flutter run
```

## Jak zbudować APK

```bash
flutter build apk --release
```

Gotowy plik będzie tutaj:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

Ten plik kopiujesz na tablet i instalujesz.

## Jak wgrać na tablet przez USB

1. Na tablecie włącz opcje programistyczne.
2. Włącz debugowanie USB.
3. Podłącz tablet do komputera.
4. Sprawdź urządzenie:

```bash
flutter devices
```

5. Wgraj aplikację:

```bash
flutter install
```

Albo zbuduj APK i zainstaluj ręcznie.

## Jak ustawić drukarkę Zebra

W aplikacji:

```txt
Smart Magazyn Offline → Ustawienia drukarki Zebra
```

Wpisz:

```txt
IP drukarki: np. 192.168.1.50
Port: 9100
```

Drukarka musi obsługiwać ZPL i przyjmować wydruk po porcie TCP 9100.

## Tryby połączenia z drukarką

Ta wersja obsługuje najprostszy wariant:

```txt
Tablet → Wi-Fi/LAN → Zebra po IP → port 9100
```

To działa bez internetu, ale wymaga lokalnej sieci. Może być zwykły router bez internetu.

Jeżeli chcesz drukować przez USB albo Bluetooth, trzeba dopisać osobny moduł, bo Android inaczej obsługuje USB/Bluetooth niż zwykłe połączenie TCP.

## Jak działa dodawanie przedmiotu

1. Logujesz się.
2. Klikasz `Dodaj przedmiot i wydrukuj etykietę`.
3. Wpisujesz nazwę, opis, rodzinę, właściciela i lokalizację.
4. Aplikacja generuje kod, np. `SM-4HD82KLPQ9`.
5. Kod zapisuje się w SQLite.
6. Aplikacja wysyła ZPL do drukarki Zebra.
7. Zebra drukuje QR i kod kreskowy.
8. Po zeskanowaniu aplikacja szuka kodu w lokalnej bazie.

## Jak działa skanowanie

1. Klikasz `Skanuj QR / kod kreskowy`.
2. Kamera odczytuje kod.
3. Aplikacja sprawdza kod w lokalnym SQLite.
4. Jeżeli kod istnieje, pokazuje szczegóły przedmiotu.
5. `last_user_id` zostaje ustawiony na aktualnie zalogowanego użytkownika.
6. Skanowanie zapisuje się w `scan_history`.

## Gdzie jest kod drukowania Zebra

```txt
flutter_app/lib/services/zebra_service.dart
```

Tam jest generowany ZPL:

- `^BQN` — QR code,
- `^BC` — Code 128 barcode.

## Gdzie jest kod bazy danych

```txt
flutter_app/lib/services/database_service.dart
```

Tam jest:

- tworzenie tabel,
- seed użytkowników,
- logowanie,
- dodawanie przedmiotów,
- pobieranie rodzin,
- skanowanie kodów,
- zapis ustawień drukarki.

## Ograniczenia tej wersji

Ta wersja jest dobra na projekt i na jeden tablet, ale ma ograniczenia:

1. Dane są tylko na jednym tablecie.
2. Jak tablet padnie i nie ma kopii, baza przepada.
3. Kilka tabletów nie będzie widzieć tych samych danych.
4. Brak centralnego panelu administracyjnego.
5. Brak synchronizacji między urządzeniami.

Do prawdziwego magazynu z wieloma stanowiskami lepsza jest poprzednia wersja: backend + SQL + wiele tabletów.

## Co warto dopisać jako rozwinięcie projektu

- eksport bazy do pliku CSV,
- backup SQLite na pendrive/chmurę,
- role użytkowników z ekranem dodawania użytkownika,
- przyjęcie/wydanie przedmiotu,
- zmiana lokalizacji po skanowaniu,
- filtrowanie po rodzinie,
- stany magazynowe,
- synchronizacja z serwerem, gdy internet wróci.
