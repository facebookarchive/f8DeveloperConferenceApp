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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.f8.R;

public class WelcomeFragment extends Fragment {

	private WelcomeListAdapter adapter = null;
	private TextView wecomeDescriptionTextView = null;
	private ParseObject welcomeData = null;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		adapter = new WelcomeListAdapter(getActivity());

		// Get the information
		ParseQuery<ParseObject> welcomeQuery = ParseQuery
				.getQuery("GeneralInfo");
		welcomeQuery.getFirstInBackground(new GetCallback<ParseObject>() {

			@Override
			public void done(ParseObject object, ParseException e) {
				if (e == null) {
					welcomeData = object;
					if (adapter != null) {
						JSONArray welcomeDetails = object
								.getJSONArray("detail");
						for (int i = 0; i < welcomeDetails.length(); i++) {
							try {
								JSONObject innerObject = welcomeDetails
										.getJSONObject(i);
								adapter.add(innerObject);
							} catch (JSONException e1) {
								// Do nothing
							}
						}
						updateView();
					}
				}
			}
		});
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		final View v = inflater.inflate(R.layout.track_welcome_layout,
				container, false);
		((TextView) v.findViewById(R.id.greeting)).setText("Welcome, "
				+ ParseUser.getCurrentUser().getString("firstName"));

		LinearLayout welcomeBlock = (LinearLayout) v
				.findViewById(R.id.welcome_color_block);
		int actionBarHeight = getActivity().getActionBar().getHeight();
		welcomeBlock.setMinimumHeight(actionBarHeight + 270);

		wecomeDescriptionTextView = (TextView) v
				.findViewById(R.id.welcome_description);
		ListView list = (ListView) v.findViewById(R.id.welcome_details_list);
		list.setAdapter(adapter);

		return v;
	}

	@Override
	public void onResume() {
		super.onResume();
		updateView();
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		wecomeDescriptionTextView = null;
	}

	private void updateView() {
		if (wecomeDescriptionTextView != null && welcomeData != null) {
			wecomeDescriptionTextView.setText(welcomeData
					.getString("description"));
		}
		if (adapter != null) {
			adapter.notifyDataSetChanged();
		}
	}

	private static class WelcomeListAdapter extends ArrayAdapter<JSONObject> {

		ViewHolder holder;

		public WelcomeListAdapter(Context context) {
			super(context, 0);
		}

		@Override
		public View getView(int position, View view, ViewGroup parent) {
			if (view == null) {
				view = View.inflate(getContext(), R.layout.list_item_welcome,
						null);
				holder = new ViewHolder();
				holder.welcomeTitle = (TextView) view
						.findViewById(R.id.welcome_title);
				holder.welcomeContent = (TextView) view
						.findViewById(R.id.welcome_content);
				view.setTag(holder);
			} else {
				holder = (ViewHolder) view.getTag();
			}

			try {
				JSONObject object = getItem(position);
				holder.welcomeTitle.setText(object.getString("title"));
				holder.welcomeContent.setText(object.getString("content"));
			} catch (JSONException e1) {
				// DO nothing
			}

			return view;
		}
	}

	static class ViewHolder {
		TextView welcomeTitle;
		TextView welcomeContent;
	}

}
