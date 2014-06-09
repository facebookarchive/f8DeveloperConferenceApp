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

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.ViewSwitcher;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.ParseRelation;
import com.parse.ParseUser;
import com.parse.f8.R;
import com.parse.f8.model.Message;

public class AlertsActivity extends BaseActivity {

	private AlertsAdapter alertsAdapter;
	private ViewSwitcher viewSwitcher;
	private ListView alertsView;
	private LinearLayout noAlertsView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_alerts);

		// Set up the views
		viewSwitcher = (ViewSwitcher) findViewById(R.id.view_switcher);
		alertsView = (ListView) findViewById(R.id.alerts_view);
		noAlertsView = (LinearLayout) findViewById(R.id.no_alerts_view);

		// Set up the adapter for the alert list
		alertsAdapter = new AlertsAdapter(this);
		alertsView.setAdapter(alertsAdapter);
		alertsView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Message message = alertsAdapter.getItem(position);
				if (message.isSurvey()) {
					Intent i = new Intent(Intent.ACTION_VIEW);
					i.setData(Uri.parse(message.getUrl()));
					startActivity(i);
				}
			}
		});

		ActionBar actionBar = getSupportActionBar();
		actionBar.setHomeButtonEnabled(false);
		actionBar.setDisplayShowTitleEnabled(false);
		actionBar.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
	}

	public void checkForAlerts() {
		alertsAdapter.clear();

		ParseUser currentUser = ParseUser.getCurrentUser();
		ParseRelation<Message> messageRelation = currentUser
				.getRelation("messages");
		ParseQuery<Message> messageQuery = messageRelation.getQuery();
		messageQuery.findInBackground(new FindCallback<Message>() {

			@Override
			public void done(List<Message> objects, ParseException e) {
				if (e != null || objects.isEmpty()) {
					// Show the second view in the view switcher
					// list, the no alerts view
					if (viewSwitcher.getCurrentView() != noAlertsView) {
						viewSwitcher.showNext();
					}
				} else {
					for (Message message : objects) {
						alertsAdapter.add(message);
					}
					// Show the first view in the view switcher
					// list, the alerts view
					if (viewSwitcher.getCurrentView() != alertsView) {
						viewSwitcher.showPrevious();
					}
				}

			}

		});

	}

	@Override
	public void onResume() {
		super.onResume();
		checkForAlerts();
	}

	private class AlertsAdapter extends ArrayAdapter<Message> {

		private ViewHolder holder;

		public AlertsAdapter(Context context) {
			super(context, 0);
		}

		@Override
		public View getView(int position, View v, ViewGroup parent) {

			if (v == null) {
				// Inflate the layout
				LayoutInflater inflater = (LayoutInflater) getContext()
						.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = inflater.inflate(R.layout.list_item_alert, parent, false);
				// Cache the view components
				holder = new ViewHolder();
				holder.checkmark = (ImageView) v.findViewById(R.id.checkmark);
				holder.surveyTitle = (TextView) v
						.findViewById(R.id.survey_title);
				holder.surveyContent = (TextView) v
						.findViewById(R.id.survey_content);
				// Lookup tag
				v.setTag(holder);
			} else {
				holder = (ViewHolder) v.getTag();
			}

			Message message = getItem(position);

			ImageView checkmark = holder.checkmark;
			TextView surveyTitle = holder.surveyTitle;
			TextView surveyContent = holder.surveyContent;

			surveyTitle.setText(message.getTitle());
			surveyContent.setText(message.getContent());

			if (message.isRead()) {
				checkmark.setVisibility(View.VISIBLE);
			} else {
				checkmark.setVisibility(View.INVISIBLE);
			}
			return v;
		}

	}

	private static class ViewHolder {
		ImageView checkmark;
		TextView surveyTitle;
		TextView surveyContent;
	}
}
