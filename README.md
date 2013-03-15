TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to get information from a TVHeadend server ( https://github.com/tvheadend/tvheadend ).

It allows you to list channels, view channel EPG's, control recordings (DVR) and view the log / status of the server.

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

#### Future Features
- Multiple Tvheadend servers
- SSH tunnel to access tvheadend




## Getting the code

    git clone --recursive git://github.com/zipleen/tvheadend-iphone-client.git

Go to TestFlight.com , download SDK and copy libTestFlight.a and TestFlight.h to the TestFlight SDK folder.

Build and run ! Send your patches to me via a pull request ;)

### Adding KXMOVIE

Kxmovie is a library which adds a ffmpeg player to the app. Adding ffmpeg has a lot of drawbacks:
- software only decoding of MPEG2 streams (your iOS device will drain)
- software only for MPEG4 - because tvheadend uses a mkv or TS container
- royalties for AC3
- royalties for MPEG2
- it's just slow, buggy (hangs a lot) and it's not polished enough
- if you can run hardware accelerated MPEG2 / MKV streams, then you can run XBMC which is the right app to do this.

But if you want to add kxmovie and test it:

Get the code:
    
    cd tvheadend-iphone-client/
    git clone --recursive git://github.com/kolyvan/kxmovie.git
    cd kxmovie
    rake

    # you need to have gas-preprocessor.pl in /usr/local/bin and have it 777, so 
    cp gas-preprocessor.pl /usr/local/bin
    sudo chmod 777 /usr/local/bin/gas-preprocessor.pl 

After the compilation is finished, drag the following files from kxmovie/kxmovie to the project
- KxMovieViewController.h
- kxmovie.bundle 

Go to Project / Target TvhClient / Build Phases , in the Link Binary With Libraries add all the .a files in kxmovie/output

Uncoment #define KXMOVIE in TVHPlayStreamHelpController.m

"Play Stream" should popup in a red button.

## Technical Background regarding connection to TVHeadend

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. I hope the Tvheadend developers don't mind this =) Also, with SSH tunneling this shouldn't be a problem! 

## License

This app's source code is licensed under the Apache 2.0 License. 

Clean Icons from Matt Gentile, from icondeposit.com.

TV Icon from brankic1979.com/icons/
