TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to remote control the TVHeadend server  ( https://github.com/tvheadend/tvheadend ) - a DVB receiver, DVR and streaming server.

It allows you to list channels, view channel's EPG, search for programs, schedule recordings (DVR) and view the log / status of the server. It will also allow you to easily launch a third party video application to view the channel's streaming video.

You can now download the app directly from the App Store!

[![TvhClient](http://linkmaker.itunes.apple.com/htmlResources/assets/images/web/linkmaker/badge_appstore-lrg.png)](https://itunes.apple.com/gb/app/tvhclient/id638900112?mt=8&uo=4)

##Features
- View tags
- View channel list by tag
- View channel's EPG
- View EPG Program details
- Launch Stream URL with external video app
- Add / view / remove recordings
- Add / view / remove AutoRec
- Status subscriptions and Status adapters
- Log and debug log
- Search EPG
- Multiple Tvheadend servers
- iPad support

#### Future Features
- SSH tunnel to access tvheadend
- Visual EPG

##Screenshots iPhone

![Channels](http://a572.phobos.apple.com/us/r1000/068/Purple/v4/ed/42/4e/ed424e9c-fee9-fc23-c74f-8d9591766fbd/mzl.dthdmvhr.320x480-75.jpg)
![ChannelPrograms](http://a1437.phobos.apple.com/us/r1000/064/Purple2/v4/08/b6/70/08b67026-50bc-bfcb-e68f-b47d0886ccd4/mzl.ekqhetuf.320x480-75.jpg)
![ProgramDetails](http://a1542.phobos.apple.com/us/r1000/116/Purple/v4/d7/b5/8f/d7b58fb7-d360-6981-bc04-f1a4c1dd6a88/mzl.fdlipgep.320x480-75.jpg)
![Recordings](http://a404.phobos.apple.com/us/r1000/120/Purple/v4/f2/0e/4b/f20e4b51-a2d7-0119-8ae0-99415c6c0633/mzl.xshppebg.320x480-75.jpg)
![Status](http://a1501.phobos.apple.com/us/r1000/070/Purple2/v4/a8/ab/b8/a8abb8a1-d052-f8c8-6730-385615f12bf1/mzl.jzfxfbli.320x480-75.jpg)

##Screenshots iPad

![Channels](https://github.com/zipleen/tvheadend-iphone-client/blob/screenshots/Screenshots/ipad/channels.png?raw=true)
![ChannelPrograms](https://github.com/zipleen/tvheadend-iphone-client/blob/screenshots/Screenshots/ipad/channelsepg.png?raw=true)
![Recordings](https://github.com/zipleen/tvheadend-iphone-client/blob/screenshots/Screenshots/ipad/recordings.png?raw=true)
![Status](https://github.com/zipleen/tvheadend-iphone-client/blob/screenshots/Screenshots/ipad/status.png?raw=true)

## Getting the code

    git clone --recursive git://github.com/zipleen/tvheadend-iphone-client.git
    cd libssh2-for-iOS
    ./build-all openssl

Don't forget to have the command line tools installed from Xcode, otherwise libssh2 won't compile.
Build and run ! Send your patches to me via a pull request ;)

## Video Streaming

DVB streaming is mainly MPEG2 streams for SD channels. MPEG4 is used for some HD Video streaming, although the audio codec could be MPEG2, AAC or AC3. The iOS devices have limitations that only allow them to hardware decode a MP4 stream which complies with device specifications. TVHeadend serves a TS or MKV stream, which the iOS can't handle natively.

In order to add video streaming, software decoding is the only solution - normally FFMPEG, but it has a lot of drawbacks:
- software only decoding of MPEG2 streams (your iOS device battery will drain)
- software only for MPEG4 - because tvheadend uses a mkv or TS container, this could (possible) be overcome
- need to pay royalties for AC3
- need to pay royalties for MPEG2
- it's slow, buggy (hangs a lot - only latest iPad have the processing power to handle software decoding) and it's not polished enough

For this reasons, I won't include ffmpeg in the app. You can experiment adding ffmpeg to the app, see some instructions in the wiki https://github.com/zipleen/tvheadend-iphone-client/wiki/Kxmovie

However, there's been some work on TVHeadend to implement a transcoding feature. With transcoding, it could be possible to encode the stream to an iOS capable stream - the streaming support will be directly supported by the system.

## Technical Background regarding connection to TVHeadend

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. Also, with SSH tunneling this shouldn't be a problem! 

## License

This app's source code is licensed under the Apache 2.0 License. 

App Icon made by Julio Costa Pinto, thanks =)

Clean Icons from Matt Gentile, from icondeposit.com.

