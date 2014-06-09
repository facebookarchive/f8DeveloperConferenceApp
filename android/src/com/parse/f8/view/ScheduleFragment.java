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

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.f8.R;
import com.parse.f8.model.Room;
import com.parse.f8.model.Talk;
import com.parse.f8.util.TalkListAdapter;

public class ScheduleFragment extends Fragment {

	public static final String ARG_TRACK = "track";

	public String[] scheduleTitles;
	public String[] scheduleTimes;
	public int[] scheduleFavoriteBreaks;

	private TalkListAdapter adapter = null;

	private int track;
	private boolean isFavoriteBreakTalk;
	private List<Talk> talkList;
	private Room trackForTalk = null;

	private TextView trackDescriptionTextView = null;
	private TextView trackDescriptionHeaderTextView = null;
	private LinearLayout talkLayout = null;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		Bundle args = getArguments();
		track = args.getInt(ARG_TRACK);

		talkList = new ArrayList<Talk>();

		// Get schedule info from resources
		scheduleTitles = getResources().getStringArray(
				R.array.drawer_schedule_content);
		scheduleTimes = getResources().getStringArray(
				R.array.drawer_schedule_times);
		scheduleFavoriteBreaks = getResources().getIntArray(
				R.array.always_favorite_breaks);

		// Set flag for favorite break talk
		isFavoriteBreakTalk = isFavoriteBreak(track);

		// Check if this is a favorite break talk
		if (isFavoriteBreakTalk) {
			Talk.findInBackground(scheduleTitles[track],
					new GetCallback<Talk>() {
						@Override
						public void done(Talk talk, ParseException e) {
							if (talk != null) {
								talkList.add(talk);
								// Update view
								updateView();
							}
						}
					});
		} else {
			// This is a list of talks for a track
			adapter = new TalkListAdapter(getActivity(), false);
			// Get the room info corresponding to this track
			Room.findInBackground(track, new GetCallback<Room>() {
				@Override
				public void done(Room room, ParseException e) {
					if (room != null) {
						trackForTalk = room;
						Talk.findInBackground(room, new FindCallback<Talk>() {
							@Override
							public void done(List<Talk> talks, ParseException e) {
								talkList.addAll(talks);
								if (adapter != null) {
									for (Talk talk : talks) {
										if (!talk.allDay()) {
											adapter.add(talk);
										}
									}
									// Update view
									updateView();
								}
							}
						});
					}
				}
			});
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		View v = inflater.inflate(R.layout.track_schedule_layout, container,
				false);

		((TextView) v.findViewById(R.id.track_title))
				.setText(scheduleTitles[track]);

		((TextView) v.findViewById(R.id.track_time))
				.setText(scheduleTimes[track]);

		talkLayout = (LinearLayout) v.findViewById(R.id.color_block);

		if (isFavoriteBreakTalk) {
			talkLayout
					.setBackgroundColor(getResources().getColor(R.color.navy));
			trackDescriptionTextView = ((TextView) v
					.findViewById(R.id.track_description));
		} else {
			View header = inflater.inflate(R.layout.list_header_view, null);
			trackDescriptionHeaderTextView = (TextView) header
					.findViewById(R.id.track_description_header);
			ListView list = (ListView) v.findViewById(R.id.talk_list_view);
			list.addHeaderView(header, null, false);
			list.setAdapter(adapter);
			list.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					// The list has a header, offset adapter position by
					// 1
					Talk talk = adapter.getItem(position - 1);
					if (!talk.isBreak()) {
						Intent intent = new Intent(getActivity(),
								TalkActivity.class);
						intent.setData(talk.getUri());
						startActivity(intent);
					}
				}
			});

			updateView();
		}

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
		trackDescriptionTextView = null;
		talkLayout = null;
		trackDescriptionHeaderTextView = null;
	}

	private boolean isFavoriteBreak(int track) {
		for (int i : scheduleFavoriteBreaks) {
			if (i == track) {
				return true;
			}
		}
		return false;
	}

	private void updateView() {
		// If this is a favorite break
		if (isFavoriteBreakTalk) {
			// Update the description from the Talk
			if (trackDescriptionTextView != null && talkList.size() > 0) {
				Talk talk = talkList.get(0);
				trackDescriptionTextView.setText(talk.getString("abstract"));
				trackDescriptionTextView.setVisibility(View.VISIBLE);
			}
		} else {
			// Update the description header from the Room
			if (trackDescriptionHeaderTextView != null && trackForTalk != null) {
				trackDescriptionHeaderTextView.setText(trackForTalk
						.getString("description"));
			}
			// Set the background color that distinguishes a trck
			if (talkLayout != null && talkList.size() > 0 && isAdded()) {
				Talk firstTalk = talkList.get(0);
				int displayColor = firstTalk.getRoom().getColor();
				talkLayout.setBackgroundColor(displayColor);
			}
			// Update the adapter view
			if (adapter != null) {
				adapter.notifyDataSetChanged();
			}
		}
	}

}
