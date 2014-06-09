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
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.support.v7.app.ActionBar.LayoutParams;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.youtube.player.YouTubeStandalonePlayer;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseImageView;
import com.parse.f8.R;
import com.parse.f8.model.Favorites;
import com.parse.f8.model.Speaker;
import com.parse.f8.model.Talk;

public class TalkActivity extends ActionBarActivity {

	private Talk selectedTalk = null;
	private boolean isActive = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_talk);

		// Fetch the data about this talk from Parse.
		String talkId = Talk.getTalkId(getIntent().getData());
		GetCallback<Talk> talkGetCallback = new GetCallback<Talk>() {
			@Override
			public void done(Talk talk, ParseException e) {
				if (!isActive) {
					return;
				}
				// If we can't get the data right now, the best we can do is
				// show a toast.
				if (e != null) {
					Toast toast = Toast.makeText(TalkActivity.this,
							e.getMessage(), Toast.LENGTH_LONG);
					toast.show();
					return;
				}

				selectedTalk = talk;

				// Update the view
				updateView(selectedTalk);
			}
		};

		Talk.getInBackground(talkId, talkGetCallback);
	}

	@Override
	public void onResume() {
		super.onResume();
		isActive = true;
		updateView(selectedTalk);
	}

	@Override
	public void onPause() {
		isActive = false;
		super.onPause();
	}

	private void updateView(final Talk talk) {
		if (!isActive) {
			return;
		}
		if (talk != null) {
			final ImageButton closeButton = (ImageButton) findViewById(R.id.close_button);
			closeButton.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					finish();
				}

			});

			LinearLayout talkLayout = (LinearLayout) findViewById(R.id.color_change);
			talkLayout.setBackgroundColor(talk.getRoom().getColor());

			RelativeLayout videoOverlayLayout = (RelativeLayout) findViewById(R.id.white_overlay_video);
			videoOverlayLayout.setBackgroundResource(R.drawable.white_bg);
			videoOverlayLayout.getBackground().setAlpha(25);
			videoOverlayLayout.setClickable(true);

			RelativeLayout favoriteOverlayLayout = (RelativeLayout) findViewById(R.id.white_overlay_favorite);
			favoriteOverlayLayout.setBackgroundResource(R.drawable.white_bg);
			favoriteOverlayLayout.getBackground().setAlpha(25);
			favoriteOverlayLayout.setClickable(true);

			TextView titleView = (TextView) findViewById(R.id.title);
			TextView timeView = (TextView) findViewById(R.id.time);
			TextView abstractView = (TextView) findViewById(R.id.talk_abstract);
			final TextView favoriteLabel = (TextView) findViewById(R.id.favorite_label);

			titleView.setText(talk.getTitle());
			timeView.setText(talk.getSlot().format(TalkActivity.this));
			abstractView.setText(talk.getAbstract());

			if (talk.getVideoID() == "") {
				videoOverlayLayout.setVisibility(View.GONE);
			}
			videoOverlayLayout.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					onClickVideo(talk.getVideoID());
				}
			});

			final ImageView favoriteStar = (ImageView) findViewById(R.id.favorite_star);
			if (Favorites.get().contains(talk)) {
				favoriteStar.setImageResource(R.drawable.x);
				favoriteStar.setVisibility(View.VISIBLE);
				favoriteLabel.setText(R.string.remove_favorite);

			} else {
				favoriteStar
						.setImageResource(R.drawable.light_rating_not_important);
				favoriteStar.setVisibility(View.VISIBLE);
				favoriteLabel.setText(R.string.add_favorite);
			}
			if (talk.isAlwaysFavorite()) {
				favoriteOverlayLayout.setVisibility(View.GONE);
			}

			favoriteOverlayLayout.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					if (Favorites.get().contains(talk)) {
						Favorites.get().remove(talk);
						favoriteStar
								.setImageResource(R.drawable.light_rating_not_important);
						favoriteLabel.setText(R.string.add_favorite);
					} else {
						Favorites.get().add(talk);
						favoriteStar.setImageResource(R.drawable.x);
						favoriteLabel.setText(R.string.remove_favorite);
					}
					Favorites.get().save(TalkActivity.this);
				}
			});

			// Add a view for each speaker in the talk.

			LinearLayout speakersView = (LinearLayout) findViewById(R.id.speakers_view);
			for (Speaker speaker : talk.getSpeakers()) {
				View speakerView = View.inflate(TalkActivity.this,
						R.layout.list_item_speaker, null);

				final ParseImageView photo = (ParseImageView) speakerView
						.findViewById(R.id.photo);
				photo.setParseFile(speaker.getPhoto());
				photo.loadInBackground();

				TextView nameView = (TextView) speakerView
						.findViewById(R.id.name);
				nameView.setText(speaker.getName());

				TextView titleAndCompany = (TextView) speakerView
						.findViewById(R.id.title_company);
				titleAndCompany.setText(String.format("%s @ %s",
						speaker.getTitle(), speaker.getCompany()));

				LayoutParams layout = new LayoutParams(
						LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
				speakerView.setLayoutParams(layout);

				speakersView.addView(speakerView);
			}
		}
	}

	private void onClickVideo(String videoId) {
		Intent intent = YouTubeStandalonePlayer.createVideoIntent(this,
				getResources().getString(R.string.youtube_developer_key),
				videoId, 0, true, false);
		if (canResolveIntent(intent)) {
			startActivity(intent);
		}
	}

	private boolean canResolveIntent(Intent intent) {
		List<ResolveInfo> resolveInfo = getPackageManager()
				.queryIntentActivities(intent, 0);
		return resolveInfo != null && !resolveInfo.isEmpty();
	}
}
