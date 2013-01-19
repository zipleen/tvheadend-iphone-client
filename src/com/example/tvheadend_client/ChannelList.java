package com.example.tvheadend_client;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;

public class ChannelList extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_channel_list);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.activity_channel_list, menu);
        return true;
    }
    
}
