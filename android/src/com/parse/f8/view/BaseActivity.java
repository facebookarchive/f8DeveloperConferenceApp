/**
 * Copyright 2014 Facebook, Inc.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to
 * use, copy, modify, and distribute this software in source code or binary
 * form for use in connection with the web services and APIs provided by
 * Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use
 * of this software is subject to the Facebook Developer Principles and
 * Policies [http://developers.facebook.com/policy/]. This copyright notice
 * shall be included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

package com.parse.f8.view;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.Window;
import android.widget.Toast;

import com.facebook.Session;
import com.parse.ParseUser;
import com.parse.f8.R;

/*
 * Base activity for logged in activities
 */
public class BaseActivity extends ActionBarActivity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getWindow().requestFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
	}

	@Override
	public void onResume() {
		super.onResume();
		// If the user is offline, let them know they are not connected
		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		if ((ni == null) || (!ni.isConnected())) {
			Toast.makeText(getApplicationContext(),
					getResources().getString(R.string.device_offline_message),
					Toast.LENGTH_LONG).show();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.main, menu);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {

		case R.id.action_schedule: {
			if (!(this instanceof ScheduleActivity)) {
				Intent i = new Intent(this, ScheduleActivity.class);
				startActivityForResult(i, 0);
				finish();
			}
			break;
		}

		case R.id.action_my_schedule: {
			if (!(this instanceof MyScheduleActivity)) {
				Intent i = new Intent(this, MyScheduleActivity.class);
				startActivityForResult(i, 0);
				finish();
			}
			break;
		}

		case R.id.action_alerts: {
			if (!(this instanceof AlertsActivity)) {
				Intent i = new Intent(this, AlertsActivity.class);
				startActivityForResult(i, 0);
			}
			break;
		}
		case R.id.action_maps: {
			if (!(this instanceof MapsActivity)) {
				Intent i = new Intent(this, MapsActivity.class);
				startActivityForResult(i, 0);
				finish();
			}
			break;
		}

		case R.id.action_logout: {
			ParseUser.logOut();
			Session session = Session.getActiveSession();
			if (session != null) {
				session.closeAndClearTokenInformation();
			}
			Intent intent = new Intent(this, DispatchActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK
					| Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
			break;
		}

		case R.id.action_terms_link: {
			String url = getResources().getString(R.string.terms_link);
			Intent i = new Intent(Intent.ACTION_VIEW);
			i.setData(Uri.parse(url));
			startActivity(i);
			break;
		}
		}
		return super.onOptionsItemSelected(item);
	}
}
