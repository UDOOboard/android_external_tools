/*
 * Copyright 2016 Junk Chen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.seco.emmcinstaller;

import android.util.Log;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import android.content.Context;
import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;

import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ScrollView;
// import java.lang.reflect.Method;

import android.util.Log;


public class MainActivity extends Activity {

     private static String TAG = "eMMC Android Installer";
     private ScrollView mScrollView = null;
     private TextView t1 = null;
     private TextView t2 = null;
     private Button b = null;
     private String lastScriptMsg = "";

     private final Handler mHandler = new Handler();

     private static String GETPROP_EXECUTABLE_PATH = "/system/bin/getprop";
     private static String SETPROP_EXECUTABLE_PATH = "/system/bin/setprop";

     private static String setProp(String propName, String propValue) {
        Process process = null;
        BufferedReader bufferedReader = null;

        try {
            process = new ProcessBuilder().command(SETPROP_EXECUTABLE_PATH, propName, propValue).redirectErrorStream(true).start();
            bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line = bufferedReader.readLine();
            if (line == null){
                line = ""; //prop not set
            }
//            Log.i(TAG,"set System Property: " + propName + "=" + line);
            return line;
        } catch (Exception e) {
            Log.e(TAG,"Failed to set System Property " + propName,e);
            return "";
        } finally{
            if (bufferedReader != null){
                try {
                    bufferedReader.close();
                } catch (IOException e) {}
            }
            if (process != null){
                process.destroy();
            }
        }
     }

     private static String readProp(String propName) {
        Process process = null;
        BufferedReader bufferedReader = null;

        try {
            process = new ProcessBuilder().command(GETPROP_EXECUTABLE_PATH, propName).redirectErrorStream(true).start();
            bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line = bufferedReader.readLine();
            if (line == null){
                line = ""; //prop not set
            }
//            Log.i(TAG,"read System Property: " + propName + "=" + line);
            return line;
        } catch (Exception e) {
            Log.e(TAG,"Failed to read System Property " + propName,e);
            return "";
        } finally{
            if (bufferedReader != null){
                try {
                    bufferedReader.close();
                } catch (IOException e) {}
            }
            if (process != null){
                process.destroy();
            }
        }
     }

     private final Runnable mUpdateMessages = new Runnable() {
	public void run() {

     		String scriptMsg = "";

        	if (Integer.parseInt(readProp("installation_status")) == 1) {
			scriptMsg = readProp("installation_progress");
			if (scriptMsg.equals(lastScriptMsg)) {
				t1.append(" .");
			} else {
				t1.append("\n" + scriptMsg);
			}
			lastScriptMsg = scriptMsg;
			mHandler.postDelayed(mUpdateMessages, 2 * 1000);
        	} else if (Integer.parseInt(readProp("installation_status")) == 3) {
			t2.setText("\n\t It is now safe to exit.\n");
			t1.append(readProp("installation_progress") + "\n");
			t1.append("\n\t\tYou can now exit Android eMMC installation App; \n\t\tRemove J27 jumper, eject uSD and restart the system.\nEnjoy.\n");
			mScrollView.fullScroll(View.FOCUS_DOWN);
			t1.append(". \n. \n. \n. \n. \n. \n. \n");
			mScrollView.fullScroll(View.FOCUS_DOWN);
			t1.append(". \n. \n");
			mScrollView.fullScroll(View.FOCUS_DOWN);
			b.setEnabled(true); 
        	}
		mScrollView.fullScroll(View.FOCUS_DOWN);
    	}
     };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
	b = new Button(this); 
	t1 = new TextView(this); 
	t2 = new TextView(this); 
	mScrollView = new ScrollView(this); 

	setProp("emmcInstallStart", "0");
	setProp("installation_status", "0");

    	b = (Button)findViewById(R.id.StartStop);
    	t1 = (TextView)findViewById(R.id.Messages);
    	t2 = (TextView)findViewById(R.id.DoNotExit);
	t2.setVisibility(TextView.INVISIBLE);
    	mScrollView = (ScrollView)findViewById(R.id.Scrollview);
    }

    public void doClick(View v) {
	if (Integer.parseInt(readProp("installation_status")) <= 1) {
		mHandler.postDelayed(mUpdateMessages, 2 * 1000);
		b.setEnabled(false); 
		t2.setVisibility(TextView.VISIBLE);
		b.setText("Exit from application"); 
		setProp("emmcInstallStart", "1");
		t1.append("\nInstallation is starting. Please wait.\n");
	} else if (Integer.parseInt(readProp("installation_status")) == 3) {
        	android.os.Process.killProcess(android.os.Process.myPid());
	}
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
