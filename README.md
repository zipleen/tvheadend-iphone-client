TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to remote control the TVHeadend server  ( https://github.com/tvheadend/tvheadend ) - a DVB receiver, DVR and streaming server.

It allows you to list channels, view channel's EPG, search for programs, schedule recordings (DVR) and view the log / status of the server. It will also allow you to easily launch a third party video application to view the channel's streaming video.

##Screenshots

![Channels](https://raw.github.com/zipleen/tvheadend-iphone-client/screenshots/Screenshots/Channels.png)
![ChannelPrograms](https://raw.github.com/zipleen/tvheadend-iphone-client/screenshots/Screenshots/ChannelPrograms.png)
![ProgramDetails](https://raw.github.com/zipleen/tvheadend-iphone-client/screenshots/Screenshots/ProgramDetails.png)
![Recordings](https://raw.github.com/zipleen/tvheadend-iphone-client/screenshots/Screenshots/Recordings.png)
![Status](https://raw.github.com/zipleen/tvheadend-iphone-client/screenshots/Screenshots/Status.png)

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

#### Future Features
- SSH tunnel to access tvheadend
- iPad support
- Visual EPG



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

However, there's been some work on TVHeadend to implement a recoding feature. With recoding, it could be possible to transcode the stream to an iOS capable stream - the streaming support will be directly supported by the system.

## Technical Background regarding connection to TVHeadend

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. Also, with SSH tunneling this shouldn't be a problem! 

## License

This app's source code is licensed under the Apache 2.0 License. 

App Icon made by Julio Costa Pinto, thanks =)

Clean Icons from Matt Gentile, from icondeposit.com.

