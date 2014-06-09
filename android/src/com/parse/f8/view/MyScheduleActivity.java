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

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.f8.R;
import com.parse.f8.model.Favorites;
import com.parse.f8.model.Room;
import com.parse.f8.model.Talk;
import com.parse.f8.util.TalkComparator;
import com.parse.f8.util.TalkListAdapter;

public class MyScheduleActivity extends BaseActivity implements
		Favorites.Listener {

	private TalkListAdapter adapter;

	// Set favoritesOnly to true, since this is the current user's schedule
	private boolean favoritesOnly = true;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_my_schedule);

		ActionBar actionBar = getSupportActionBar();
		actionBar.setHomeButtonEnabled(false);
		actionBar.setDisplayShowTitleEnabled(false);
		actionBar.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
		adapter = new TalkListAdapter(this, true);
		ListView list = (ListView) findViewById(R.id.my_talks_list);
		list.setAdapter(adapter);

		Room room = null;

		Talk.findInBackground(room, new FindCallback<Talk>() {
			@Override
			public void done(List<Talk> talks, ParseException e) {
				Favorites.get().addListener(MyScheduleActivity.this);

				if (e != null) {
					Toast toast = Toast.makeText(getApplicationContext(),
							e.getMessage(), Toast.LENGTH_LONG);
					toast.show();
					return;
				}

				if (talks != null) {
					for (Talk talk : talks) {
						if (!favoritesOnly || talk.isAlwaysFavorite()
								|| Favorites.get().contains(talk)) {
							adapter.add(talk);
						}
					}
				}

			}
		});

		list.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Talk talk = adapter.getItem(position);
				openTalkDetailView(talk);
			}
		});
	}

	@Override
	public void onStop() {
		Favorites.get().removeListener(this);
		super.onStop();
	}

	@Override
	public void onResume() {
		super.onResume();
		adapter.notifyDataSetChanged();
	}

	public void openTalkDetailView(Talk talk) {
		Intent intent = new Intent(this, TalkActivity.class);
		intent.setData(talk.getUri());
		startActivity(intent);
	}

	@Override
	public void onFavoriteAdded(Talk talk) {
		if (adapter != null) {
			adapter.add(talk);
			adapter.sort(TalkComparator.get());
		}
		adapter.notifyDataSetChanged();
	}

	@Override
	public void onFavoriteRemoved(Talk talk) {
		if (adapter != null) {
			if (favoritesOnly) {
				adapter.remove(talk);
			} else {
				adapter.notifyDataSetChanged();
			}
		}
	}

	/**
	 * Removes any talks from the list that haven't been favorited, if
	 * favoritesOnly is true.
	 */
	public void removeUnfavoritedItems() {
		if (!favoritesOnly) {
			return;
		}
		for (int i = 0; adapter != null && i < adapter.getCount(); ++i) {
			Talk talk = adapter.getItem(i);
			if (!talk.isAlwaysFavorite() && !Favorites.get().contains(talk)) {
				adapter.remove(talk);
				i--;
			}
		}
	}

}
