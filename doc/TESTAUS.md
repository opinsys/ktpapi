# Manuaalitestaus

1. Deb-paketin luonti `dpkg-buildpackage -uc -us`
1. Asennetaan deb-paketti virtuaalikoneessa `dpkg -i abitti-ktpapi_*.deb`
    - Tarvittavat palvelut käynnistyvät
    - Systemd-palvelu toimii (`systemctl status opinsys-ktpapi-watcher.path`)
    - `~/opinsys/apiwatcher` on olemassa
    - `/media/usb1/.opinsys` hakemisto on olemassa
1. Ajetaan asennusskripti uudelleen
    - Asennus keskeytyy koska palvelut jo asentuneita
1. Pingataan skriptiä: `echo "ping" > /media/usb1/.opinsys/cmd` palvelimella
    - muodostuu tiedosto `.opinsys/stamp`, jossa on aikaleima
    - muodostuu tiedosto `.opinsys/output`, jossa on "ping"
1. Ajetaan tuntematon komento `echo "pingg" > /media/usb1/.opinsys/cmd`
    - muodostuu tiedosto `.opinsys/stamp`, jossa on aikaleima
    - muodostuu tiedosto `.opinsys/output`, jossa on "{error: true, msg:"Unrecognized command", cmd:"pingg"}"
1. Ladataan oma.abitti.fi:stä kaksi koetta, joista toinen kooltaan suuri, yli 10 Mt. Paketoidaan .zip-tiedostoon. Nimetään `paketti.zip`. Tallennetaan purkukoodit `koodit.txt` tiedostoon erillisille riveille, siten että tiedostossa on vain yksi avainkoodi. Ajetaan isäntäkoneessa `echo "load-exam paketti.zip koodit.txt" > ~/ktp-jako/.opinsys/cmd`.
    - muodostuu tiedosto `.opinsys/output`, jossa on "{error: true, exam-load:"Unrecognized command",passwords:[], cmd:""}"
1. Ladataan oma.abitti.fi:stä kaksi koetta, joista toinen kooltaan suuri, yli 10 Mt. Paketoidaan .zip-tiedostoon. Nimetään `paketti.zip`. Tallennetaan purkukoodit `koodit.txt` tiedostoon erillisille riveille, siten että jälkimmäinen avainkoodi on virheellinen. Rivinvaihto suoritettu Windows-tyyliin `\n\r`. Viimeisen rivin jälkeen ei rivinvaihtoa. Ajetaan isäntäkoneessa `echo "load-exam paketti.zip koodit.txt" > ~/ktp-jako/.opinsys/cmd`.
1. Ladataan oma.abitti.fi:stä kaksi koetta, joista toinen kooltaan suuri, yli 10 Mt. Paketoidaan .zip-tiedostoon. Nimetään `paketti.zip`. Tallennetaan purkukoodit `koodit.txt` tiedostoon erillisille riveille. Rivinvaihto suoritettu Windows-tyyliin `\n\r`. Viimeisen rivin jälkeen ei rivinvaihtoa. Ajetaan isäntäkoneessa `echo "load-exam paketti.zip koodit.txt" > ~/ktp-jako/.opinsys/cmd`.
    - 
1. Tuhotaan `.opinsys/*` ja ajetaan `ping` komento
    - muodostuu tiedosto `.opinsys/stamp`, jossa on aikaleima
    - muodostuu tiedosto `.opinsys/output`, jossa on "ping"
