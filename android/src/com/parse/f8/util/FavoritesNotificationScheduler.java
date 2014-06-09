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

import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.f8.model.Favorites;
import com.parse.f8.model.Talk;

/**
 * Listens for changes to the set of favorite talks and sets up alarms to send
 * out notifications a few minutes before the talks start.
 */
public class FavoritesNotificationScheduler implements Favorites.Listener {
	private Context context;

	public FavoritesNotificationScheduler(Context context) {
		this.context = context;
	}

	/**
	 * Creates a PendingIntent to be sent when the alarm for this talk goes off.
	 */
	private PendingIntent getPendingIntent(Talk talk) {
		Intent intent = new Intent();
		intent.setClass(context, FavoritesNotificationReceiver.class);
		intent.setData(talk.getUri());
		return PendingIntent.getBroadcast(context, 0, intent,
				PendingIntent.FLAG_ONE_SHOT);
	}

	/**
	 * Schedules an alarm to go off a few minutes before this talk.
	 */
	private void scheduleNotification(Talk talk) {
		// We need to know the time slot of the talk, so fetch its data if we
		// haven't already.
		if (!talk.isDataAvailable()) {
			Talk.getInBackground(talk.getObjectId(), new GetCallback<Talk>() {
				@Override
				public void done(Talk talk, ParseException e) {
					if (talk != null) {
						scheduleNotification(talk);
					}
				}
			});
			return;
		}

		// Figure out what time we need to set the alarm for.
		Date talkStart = talk.getSlot().getStartTime();
		Logger.getLogger(getClass().getName()).log(Level.INFO,
				"Registering alarm for " + talkStart);
		long fiveMinutesBefore = talkStart.getTime() - (5000 * 60);
		if (fiveMinutesBefore < System.currentTimeMillis()) {
			return;
		}

		// Register the actual alarm.
		AlarmManager manager = (AlarmManager) context
				.getSystemService(Context.ALARM_SERVICE);
		PendingIntent pendingIntent = getPendingIntent(talk);
		manager.set(AlarmManager.RTC_WAKEUP, fiveMinutesBefore, pendingIntent);
	}

	/**
	 * Cancels any alarm scheduled for the given talk.
	 */
	private void unscheduleNotification(Talk talk) {
		AlarmManager manager = (AlarmManager) context
				.getSystemService(Context.ALARM_SERVICE);
		PendingIntent pendingIntent = getPendingIntent(talk);
		manager.cancel(pendingIntent);
	}

	@Override
	public void onFavoriteAdded(Talk talk) {
		scheduleNotification(talk);
	}

	@Override
	public void onFavoriteRemoved(Talk talk) {
		unscheduleNotification(talk);
	}
}
