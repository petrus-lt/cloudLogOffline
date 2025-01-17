# CloudLogOffline

[![CloudLogOfflineDemo](http://img.youtube.com/vi/jgX52e1QWU0/0.jpg)](https://youtu.be/jgX52e1QWU0 "CloudLogOffline Demo")

<a href=""><img src="https://www.webappjung.de/images/assets/google2.png" style="height:40px;border-radius:0!important;"  alt=""/></a>&nbsp;<a href="https://apps.apple.com/de/app/cloudlogoffline/id1528219213"><img src="https://www.webappjung.de/images/assets/iOS2.png"  style="height:40px;border-radius:0!important;" alt=""/></a>

CloudLogOffline is an app interface for [Cloudlog](https://github.com/magicbug/Cloudlog) the cloud logbook for HAM radio OMs and YLs by 2M0SQL.

The main purpose of CloudLogOffline is the portable operating mode, where no Wifi or 3G/LTE is availabe, e.g. SOTA, IOTA or COTA. The logs can be stored in the app and when back to a internet connection, the log can be uploaded to a selfhosted Cloudlog instance. This app is developed as cross-plattform tool for macOS, iOS, iPadOS, Android, Windows, Linux using the Qt framework.

Currently CloudLogOffline supports following features:

- Upload to Cloudlog via API 
- Query QRZ.com (if 3G/LTE is available)
- Connect to [Flrig](http://www.w1hkj.com) by W1HKJ which e.g. runs on a Raspberry Pi which is connected to the radio and opens a Wifi to interact with CloudLogOffline
- Set a CQ QRG if Flrig is not available
- Live and post QSOs
- SOTA Fields
- SAT Fields
- WWFF Fields
- [Hear Ham Repeater List](https://hearham.com/repeaters)

## Build Instructions:

There is just one requirement, which is [Qt](https://www.qt.io/download-open-source). On Debian-based system you might want to install `libqt5svg5-dev` and `qtbase5-private-dev` as well.

After installing Qt just follow these steps on command line:

```bash
git clone --recursive https://github.com/myzinsky/cloudLogOffline.git
cd cloudLogOffline/
mkdir build && cd build
qmake ../CloudLogOffline.pro
make -j
```
Or use QtCreator to build the project.

Then run the binary, app or exe

## Community:
- German Telegram Group: https://t.me/CloudLogOffline
- International DARC Matrix Group: [#thema_cloudlogoffline:darc.de](https://matrix.to/#/#thema_cloudlogoffline:darc.de)
- News: <a rel="me" href="https://social.darc.de/@DL9MJ">Mastodon DL9MJ</a>
