// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> cs = {
  "homeVersion": "App verze",
  "homeClock": "Digitronové hodiny",
  "homeAlarm": "Digitronový budík",
  "homeClockLink": "https://noycejoyce.com/media/pages/support/411181fbbd-1636027647/nixie-clock_manual_cz_online.pdf",
  "homeAlarmLink": "https://noycejoyce.com/media/pages/support/c450b16819-1639150730/nixie-alarm-manual_cz_2_web.pdf",
  "homeWebLink": "https://noycejoyce.com/cs",
  "homeManuals": "Manuály",
  "listSearch": "Hledej",
  "listStop": "Zastavit",
  "listTitle": "Připojte se k zařízení",
  "homeSearch": "Hledej zařízení...",
  "listBleStatus1": "Toto zařízení nepodporuje Bluetooth",
  "listBleStatus2": "Povolte aplikaci použít Bluetooth a polohu",
  "listBleStatus3": "Bluetooth je vypnuté, zapněte ho",
  "listBleStatus4": "Zapněte umístění v nastavení",
  "listBleWarning": "Čekejte prosím, hledali jste příliš mnohokrát.",
  "detailTimeFormat": "Formát Času",
  "detailTimeFormatText": "Mění formát času mezi 12 a 24.",
  "detailNightMode": "Noční Nastavení",
  "detailNightModeText": "Vypne digitrony v časovém rozmezí.",
  "detailNighModeStart": "Začátek",
  "detailNighModeEnd": "Konec",
  "detailNighModeSet": "Nastavit",
  "detailHourglass": "Přesýpací Efekt",
  "detailHourglassText": "Přesýpací effect projede všechny číslice v digitronech. Zde si můžete nastavit v jakém intervalu se toto bude opakovat. Tato funkce prodlužuje životnost digitronů.",
  "detailSyncTime": "SYNCHRONIZOVAT ČAS",
  "detailMore": "Další funkce",
  "detailCustomTime": "Vlastní Čas",
  "detailCustomTimeText": "Nastavte si svůj vlastní čas.",
  "detailNixieDots": "Doutnavky",
  "detailNixieDotsText": "Vypněte nebo zapněte doutnavky.",
  "detailNixieDotsOn": "ZAP",
  "detailNixieDotsOff": "VYP",
  "detailFwAlertNewer": "Novější firmware",
  "detailFwAlertNewerText": "Vaše hodiny mají novější verzi FW {} než je podporovaná verze FW {}.\nNěkteré funkce nemusí fungovat.",
  "detailFwAlertUpdateButton": "Aktualizovat",
  "detailFwAlertUpdate": "Aktualizace firmware",
  "detailFwAlertUpdateText": "Aby jste mohli používat všechny dostupné funkce aktualizujte si zařízení z FW {} na FW {}\n\nZařízení musí být připojeno k telefonu, ale nesmí být spárované.",
  "detailFwAlertLegacyText": "Zařízení musí být připojeno k telefonu, ale nesmí být spárované.\n\n1. Odpojte zařízení ze záskuvky\n2. Zapojte jej zpět se stisknutým tlačítkem MENU\n3. Vyhledejte zařízení v aplikaci\n4. Klikněte na zařízení se žlutým pozadím a počkejte",
  "detailCustomTimeDate": "Datum",
  "detailCustomTimeTime": "Čas",
  "listAlarmSupport": "Nixie Alarm zatím není podporovaný.",
  "homeNews": "Novinky",
  "homeManualsText": "Produktové manuály",
  "homeNewsText": "Co je nového v aplikaci",
  "listSettings": "Nastavení",
  "newsWIFI": "Chcete-li dostávat novinky o aplikaci zapněte WIFI",
  "newsServer": "Chyba serveru, zkuste to znovu později.",
  "detailUnpairWarning": "Chyba! Zrušte párování zařízení v nastavení Bluetooth.",
  "homePrivacy": "Osobní údaje",
  "homePrivacyText": "Ochrana osobních údajů"
};
static const Map<String,dynamic> en = {
  "homeVersion": "App version",
  "homeClock": "Nixie Clock",
  "homeAlarm": "Nixie Alarm",
  "homeClockLink": "https://noycejoyce.com/media/pages/support/e048fd2201-1636027647/nixie-clock_manual_eng_online.pdf",
  "homeAlarmLink": "https://noycejoyce.com/media/pages/support/59b17f0f91-1639150730/nixie-alarm-manual_eng_2_web.pdf",
  "homeWebLink": "https://noycejoyce.com",
  "homeManuals": "Manuals",
  "listSearch": "Search",
  "listStop": "Stop",
  "listTitle": "Click to connect",
  "homeSearch": "Search for devices...",
  "listBleStatus1": "This device does not support Bluetooth",
  "listBleStatus2": "Authorize the app to use Bluetooth and location",
  "listBleStatus3": "Bluetooth is powered off on your device, turn it on",
  "listBleStatus4": "Enable location services",
  "listBleWarning": "Please wait, you scanned too many times.",
  "detailTimeFormat": "Time Format",
  "detailTimeFormatText": "Change time format between 12 and 24.",
  "detailNightMode": "Night Mode",
  "detailNightModeText": "Turns off nixie tubes in the time range.",
  "detailNighModeStart": "Start",
  "detailNighModeEnd": "End",
  "detailNighModeSet": "Set",
  "detailHourglass": "Hourglass Effect",
  "detailHourglassText": "The hourglass effect passes through all digits in the nixie tubes. Here you can set the interval at which this will be repeated. This feature extends the life of the nixie tubes.",
  "detailSyncTime": "SYNCHRONIZE TIME",
  "detailMore": "More functions",
  "detailCustomTime": "Custom Time",
  "detailCustomTimeText": "Set your own time.",
  "detailNixieDots": "Nixie Dots",
  "detailNixieDotsText": "Turn nixie dots off or on.",
  "detailNixieDotsOn": "ON",
  "detailNixieDotsOff": "OFF",
  "detailFwAlertNewer": "Newer firmware",
  "detailFwAlertNewerText": "Your clock has a newer FW version {} than the supported FW version {}.\nSome functions may not work.",
  "detailFwAlertUpdateButton": "Update",
  "detailFwAlertUpdate": "Update firmware version",
  "detailFwAlertUpdateText": "To use the available functions update your firmware version from FW {} to FW {}\n\nThe device needs to be connected to the phone but it must not be paired.",
  "detailFwAlertLegacyText": "The device needs to be connected to the phone but it must not be paired.\n\n1. Unplug your device from the outlet\n2. Plug it back in while holding the MENU button\n3. Search for devices in the app\n4. Click the device with the yellow background and wait",
  "detailCustomTimeDate": "Date",
  "detailCustomTimeTime": "Time",
  "listAlarmSupport": "Nixie Alarm is not supported yet.",
  "homeNews": "News",
  "homeManualsText": "Product manuals",
  "homeNewsText": "What is new in the app",
  "listSettings": "Settings",
  "newsWIFI": "To get news about the app please turn on the WIFI",
  "newsServer": "Server error, please try again later.",
  "detailUnpairWarning": "Error! Unpair the device in Bluetooth settings.",
  "homePrivacy": "Privacy policy",
  "homePrivacyText": "Our privacy policy"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"cs": cs, "en": en};
}
