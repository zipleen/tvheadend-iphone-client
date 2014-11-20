TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to remote control the TVHeadend server  ( https://github.com/tvheadend/tvheadend ) - a DVB receiver, DVR and streaming server.

It allows you to list channels, view channel's EPG, search for programs, schedule recordings (DVR) and view the log / status of the server. It will also allow you to easily launch a third party video application to view the channel's streaming video.

You can now download the app directly from the App Store!

[![TvhClient](http://linkmaker.itunes.apple.com/htmlResources/assets/images/web/linkmaker/badge_appstore-lrg.png)](https://itunes.apple.com/gb/app/tvhclient/id638900112?mt=8&uo=4)
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G6DBJWV5LP36A)

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

![Channels](http://a3.mzstatic.com/eu/r30/Purple5/v4/df/e4/17/dfe41704-81e9-7312-b57f-76f4b51ad511/screen322x572.jpeg)
![ChannelPrograms](http://a2.mzstatic.com/eu/r30/Purple5/v4/84/a8/7e/84a87e62-553b-33f6-bbb3-b1658e9c7e8a/screen322x572.jpeg)
![ProgramDetails](http://a1.mzstatic.com/eu/r30/Purple5/v4/57/ca/f5/57caf5b2-48fd-9149-648b-e22c1663c501/screen322x572.jpeg)
![Recordings](http://a2.mzstatic.com/eu/r30/Purple5/v4/74/27/06/7427065c-9ed3-eb1e-5339-cc9e5e079296/screen322x572.jpeg)
![Status](http://a5.mzstatic.com/eu/r30/Purple3/v4/1a/f9/77/1af97715-784c-e3d3-8b88-9cfeb15a2afd/screen322x572.jpeg)

##Screenshots iPad

![Channels](http://a3.mzstatic.com/eu/r30/Purple5/v4/ef/d8/87/efd88778-07ad-ba84-d708-5d71775907a5/screen480x480.jpeg)
![ChannelPrograms](http://a1.mzstatic.com/eu/r30/Purple3/v4/5a/a5/ab/5aa5abf6-0be0-bc2b-8c4b-59d4205645a4/screen480x480.jpeg)
![Recordings](http://a5.mzstatic.com/eu/r30/Purple3/v4/bb/e0/b8/bbe0b847-7723-1ef1-0564-eda41963632c/screen480x480.jpeg)
![Status](http://a3.mzstatic.com/eu/r30/Purple1/v4/89/59/51/895951cf-5a35-ba8a-743f-01bd082553d7/screen480x480.jpeg)

## Getting the code

    git clone --recursive git://github.com/zipleen/tvheadend-iphone-client.git
    pod install

Build and run ! Send your patches to me via a pull request ;)

## Video Streaming

Download VLC from the App Store and open the stream with it!

There's also an option to use the new alpha transcoding feature from TVHeadend to stream H264/AAC MPEG-TS, compatible with iOS. See [here](https://github.com/zipleen/tvheadend-iphone-client/wiki/Tvheadend-Transcoding) 

In the future there could be a possibility to add VLC into the app, in order to software decode the stream. Although AC3 won't ever be possible because of patent issues.

## Technical Background regarding connection to TVHeadend

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. Also, with SSH tunneling this shouldn't be a problem! 

## License

This app's source code is licensed under the Mozilla Public License 2 (MPL-2). 

App Icon made by Julio Costa Pinto, thanks =)

Clean Icons from Matt Gentile, from icondeposit.com.

