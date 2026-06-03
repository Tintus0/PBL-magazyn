# Opis projektu — aplikacja do obsługi smart magazynu

Projekt zakłada stworzenie mobilnego systemu magazynowego działającego na tablecie z Androidem. System umożliwia dodawanie przedmiotów do lokalnej bazy danych, drukowanie etykiet z kodem QR i kodem kreskowym na drukarce Zebra oraz późniejsze skanowanie tych kodów w celu identyfikacji przedmiotu.

Wersja offline została zaprojektowana tak, aby działała bez dostępu do internetu oraz bez zewnętrznego serwera. Cała logika systemu, baza danych i obsługa użytkowników znajdują się bezpośrednio w aplikacji Flutter. Dane są przechowywane w lokalnej bazie SQLite, która jest tworzona automatycznie przy pierwszym uruchomieniu aplikacji.

Głównym celem systemu jest szybka identyfikacja przedmiotów magazynowych. Po dodaniu przedmiotu aplikacja generuje unikalny kod, zapisuje dane w bazie i wysyła komendę ZPL do drukarki Zebra. Drukarka drukuje etykietę, którą można nakleić na przedmiot, opakowanie lub lokalizację magazynową. Po zeskanowaniu kodu aplikacja pokazuje dane przedmiotu, właściciela, ostatniego użytkownika oraz liczbę przedmiotów należących do tej samej rodziny.

System może być wykorzystany w małym magazynie, pracowni, firmie produkcyjnej lub jako prototyp większego rozwiązania WMS. Wersja offline jest szczególnie przydatna tam, gdzie nie ma stałego dostępu do internetu albo system ma działać tylko na jednym urządzeniu.
