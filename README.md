TVHeadend iOS Client
=======================

TvhClient is a TVHeadend iOS (iPhone, iPad) Client app, which allows you to get information from a TVHeadend server ( https://github.com/tvheadend/tvheadend ).

It allows you to view channels by tags, view channel EPG's, add and view recordings and view the status of the server.

## Getting the code

    git clone https://github.com/zipleen/tvheadend-iphone-client.git
    cd tvheadend-iphone-client/
    git submodule update --init
    
    # configure kxmovie and ffmpeg
    cd kxmovie/
    git submodule update --init
    rake
    
    # you need to have gas-preprocessor.pl in /usr/local/bin and have it 777, so 
    cp gas-preprocessor.pl /usr/local/bin
    sudo chmod 777 /usr/local/bin/gas-preprocessor.pl 

To work without kxmovie, remove "kxmovie frameworks" from "Frameworks" and "kxmovie" from Supporting Files/Framework. Then edit TVHChannelListProgramsViewController.m and remove #import "KxMovieViewController.h" and comment the whole "-(void)streamChannel:(NSString*) path" method.

#### Background

There's two ways to connect to TVHeadend: HTSP and using the web interface. This app uses the web interface, although it's not officially supported. This way we have more detailed information on some components of the software, like the Status. It was also easier for me, as this is my first iPhone App. 

## License

This app's source code is licensed under the Apache 2.0 License. 

Clean Icons from Matt Gentile, from icondeposit.com.

TV Icon from brankic1979.com/icons/
