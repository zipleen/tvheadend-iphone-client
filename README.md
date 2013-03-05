TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to get information from a TVHeadend server ( https://github.com/tvheadend/tvheadend ).

It allows you to view channels by tags, view channel EPG's, add and view recordings and view the status of the server.

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
    cd tvheadend-iphone-client/
    
    # configure kxmovie and ffmpeg
    cd tvheadend-iphone-client/
    cd kxmovie/
    rake
    
    # you need to have gas-preprocessor.pl in /usr/local/bin and have it 777, so 
    cp gas-preprocessor.pl /usr/local/bin
    sudo chmod 777 /usr/local/bin/gas-preprocessor.pl 

To work without kxmovie, remove "kxmovie frameworks" from "Frameworks" and "kxmovie" from Supporting Files/Framework. Then edit TVHChannelListProgramsViewController.m and remove #import "KxMovieViewController.h" and comment the whole "-(void)streamChannel:(NSString*) path" method.

## Technical Background

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. I hope the Tvheadend developers don't mind this. Also, with SSH tunneling this shouldn't be a problem! 

## License

This app's source code is licensed under the Apache 2.0 License. 

Clean Icons from Matt Gentile, from icondeposit.com.

TV Icon from brankic1979.com/icons/
