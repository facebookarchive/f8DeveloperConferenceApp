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

package com.parse.f8.util;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.parse.ParseImageView;
import com.parse.f8.R;
import com.parse.f8.model.Favorites;
import com.parse.f8.model.Speaker;
import com.parse.f8.model.Talk;

public class TalkListAdapter extends ArrayAdapter<Talk> {

	private boolean isFavoritesView = false;

	public TalkListAdapter(Context context, boolean isFavorites) {
		super(context, 0);
		isFavoritesView = isFavorites;
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ViewHolder holder;

		// If a view hasn't been provided inflate on
		if (null == view) {
			LayoutInflater inflater = (LayoutInflater) getContext()
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			view = inflater.inflate(R.layout.list_item_talk, parent, false);
			// Cache view components into the view holder
			holder = new ViewHolder();
			holder.talkLayout = (LinearLayout) view
					.findViewById(R.id.talk_item);
			holder.timeView = (TextView) view.findViewById(R.id.time_view);
			holder.titleView = (TextView) view.findViewById(R.id.title);
			holder.speakerName = (TextView) view
					.findViewById(R.id.speaker_name);
			holder.photo = (ParseImageView) view
					.findViewById(R.id.speaker_photo);
			holder.favoriteButton = (ImageButton) view
					.findViewById(R.id.favorite_button);
			// Tag for lookup later
			view.setTag(holder);
		} else {
			holder = (ViewHolder) view.getTag();
		}

		final Talk talk = getItem(position);

		if (isFavoritesView) {
			LinearLayout talkLayout = holder.talkLayout;

			int displayColor = talk.getRoom().getColor();
			talkLayout.setBackgroundColor(displayColor);
		}

		TextView timeView = holder.timeView;
		timeView.setText(talk.getSlot().format(getContext()));

		TextView titleView = holder.titleView;
		TextView speakerName = holder.speakerName;
		titleView.setText(talk.getTitle());

		List<Speaker> speakers = talk.getSpeakers();

		final ParseImageView photo = holder.photo;

		if (!speakers.isEmpty()) {
			final Speaker primarySpeaker = speakers.get(0);
			speakerName.setText(primarySpeaker.getName());
			photo.setParseFile(primarySpeaker.getPhoto());
			photo.loadInBackground();
		}

		if (talk.isAlwaysFavorite()) {
			photo.setParseFile(talk.getIcon());
			photo.loadInBackground();
		}

		final ImageButton favoriteButton = holder.favoriteButton;
		if (Favorites.get().contains(talk)) {
			if (isFavoritesView) {
				favoriteButton.setImageResource(R.drawable.x);
			} else {
				favoriteButton
						.setImageResource(R.drawable.light_rating_important);
			}
		} else {
			favoriteButton
					.setImageResource(R.drawable.light_rating_not_important);
		}
		favoriteButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Favorites favorites = Favorites.get();
				if (favorites.contains(talk)) {
					favorites.remove(talk);
					favoriteButton
							.setImageResource(R.drawable.light_rating_not_important);
				} else {
					favorites.add(talk);
					if (isFavoritesView) {
						favoriteButton.setImageResource(R.drawable.x);
					} else {
						favoriteButton
								.setImageResource(R.drawable.light_rating_important);
					}
				}
				favorites.save(getContext());
			}
		});
		favoriteButton.setFocusable(false);

		if (talk.isAlwaysFavorite()) {
			favoriteButton.setVisibility(View.GONE);
			photo.setBackgroundResource(android.R.color.transparent);
		} else if (talk.isBreak()) {
			favoriteButton.setVisibility(View.GONE);
			photo.setVisibility(View.INVISIBLE);
		} else {
			favoriteButton.setVisibility(View.VISIBLE);
		}

		return view;
	}

	static class ViewHolder {
		LinearLayout talkLayout;
		TextView timeView;
		TextView titleView;
		TextView speakerName;
		ParseImageView photo;
		ImageButton favoriteButton;
	}
}
