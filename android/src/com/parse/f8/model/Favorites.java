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

package com.parse.f8.model;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.widget.Toast;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.ParseRelation;
import com.parse.ParseUser;

/**
 * The set of talks that have been starred in the app.
 */
public class Favorites {
	/**
	 * A listener to notify other parts of the app when talks have been starred
	 * or unstarred.
	 */
	public static interface Listener {
		void onFavoriteAdded(Talk talk);

		void onFavoriteRemoved(Talk talk);
	}

	// This class is a Singleton, since there's only one set of favorites for
	// the installation.
	private static Favorites instance = new Favorites();

	public static Favorites get() {
		return instance;
	}

	private List<Talk> favoriteTalks = new ArrayList<Talk>();

	// The set of objectIds for the talks that have been favorited.
	private HashSet<String> talkIds = new HashSet<String>();

	// Listeners to notify when the set changes.
	private ArrayList<Listener> listeners = new ArrayList<Listener>();

	private Favorites() {
		fetchFavoritesFromParse();
	}

	public List<Talk> getFavorites() {
		return favoriteTalks;
	}

	/**
	 * Returns true if this talk has been favorited.
	 */
	public boolean contains(Talk talk) {
		return talkIds.contains(talk.getObjectId());
	}

	/**
	 * Adds a talk to the set of favorites.
	 */
	public void add(Talk talk) {
		// For now, just add the favorite to this list; we will save it to the
		// relation later
		favoriteTalks.add(talk);
		talkIds.add(talk.getObjectId());
		ParseUser.getCurrentUser().getRelation("favoriteTalks").add(talk);
		for (Listener listener : listeners) {
			listener.onFavoriteAdded(talk);
		}
	}

	/**
	 * Removes a talk from the set of favorites.
	 */
	public void remove(Talk talk) {
		favoriteTalks.remove(talk);
		talkIds.remove(talk.getObjectId());
		ParseUser.getCurrentUser().getRelation("favoriteTalks").remove(talk);
		for (Listener listener : listeners) {
			listener.onFavoriteRemoved(talk);
		}
	}

	/**
	 * Adds a listener to be notified when the set of favorites changes.
	 */
	public void addListener(Listener listener) {
		listeners.add(listener);
	}

	/**
	 * Removes a listener.
	 */
	public void removeListener(Listener listener) {
		listeners.remove(listener);
	}

	/**
	 * Populates the set of favorites from its JSON representation, as returned
	 * from toJSON.
	 */
	private void setJSON(JSONObject json) {
		JSONArray favorites = json.optJSONArray("favorites");
		if (favorites == null) {
			favorites = new JSONArray();
		}

		ArrayList<Talk> toRemove = new ArrayList<Talk>();
		for (String objectId : talkIds) {
			Talk pointer = Talk.createWithoutData(Talk.class, objectId);
			toRemove.add(pointer);
		}
		for (Talk talk : toRemove) {
			remove(talk);
		}

		for (int i = 0; i < favorites.length(); ++i) {
			String objectId = favorites.optString(i);
			Talk pointer = Talk.createWithoutData(Talk.class, objectId);
			add(pointer);
		}
	}

	/**
	 * Returns a JSON representation of the set of favorited talks. The format
	 * is something like:
	 * <code>{ "favorites": [ "talkObjectId1", "talkObjectId2", "talkObjectId3" ] }</code>
	 */
	private JSONObject toJSON() {
		JSONArray favorites = new JSONArray();
		for (String objectId : talkIds) {
			favorites.put(objectId);
		}

		JSONObject json = new JSONObject();
		try {
			json.put("favorites", favorites);
		} catch (JSONException e) {
			// This can't happen.
			throw new RuntimeException(e);
		}
		return json;
	}

	/**
	 * Saves the current set of favorites to a SharedPreferences file. This
	 * method returns quickly, while the saving runs asynchronously.
	 */
	private void saveLocally(final Context context) {
		final JSONObject json = toJSON();

		new AsyncTask<Void, Void, Exception>() {
			@Override
			protected Exception doInBackground(Void... unused) {
				try {
					String jsonString = json.toString();
					SharedPreferences prefs = context.getSharedPreferences(
							"favorites.json", Context.MODE_PRIVATE);
					prefs.edit().putString("json", jsonString).commit();
				} catch (Exception e) {
					return e;
				}
				return null;
			}

			@Override
			protected void onPostExecute(Exception error) {
				if (error != null) {
					Toast toast = Toast.makeText(context, error.getMessage(),
							Toast.LENGTH_LONG);
					toast.show();
				}
			}
		}.execute();
	}

	/**
	 * Saves the current set of favorites to Parse, so that we can push to
	 * people based on what talks they have favorited, and also to measure which
	 * talks were the most favorited.
	 */
	private void saveToParse() {
		// Save the new relation on the user object
		ParseUser.getCurrentUser().saveInBackground();
	}

	/**
	 * Loads the set of favorites from the SharedPreferences file, calling the
	 * listeners for all the favorites that get added.
	 */
	public void findLocally(final Context context) {
		new AsyncTask<Void, Void, JSONObject>() {
			@Override
			protected JSONObject doInBackground(Void... unused) {
				SharedPreferences prefs = context.getSharedPreferences(
						"favorites.json", Context.MODE_PRIVATE);
				String jsonString = prefs.getString("json", "{}");
				try {
					return new JSONObject(jsonString);
				} catch (JSONException json) {
					// Just ignore malformed json.
					return null;
				}
			}

			@Override
			protected void onPostExecute(JSONObject json) {
				if (json != null) {
					setJSON(json);
				}
			}
		}.execute();
	}

	/**
	 * Saves the current set of favorites both to the local disk and to Parse.
	 * This returns immediately, which the saves run asynchronously.
	 */
	public void save(final Context context) {
		saveLocally(context);
		saveToParse();
	}

	private void fetchFavoritesFromParse() {
		ParseUser currentUser = ParseUser.getCurrentUser();
		ParseRelation<Talk> relation = currentUser.getRelation("favoriteTalks");
		ParseQuery<Talk> favoriteTalksQuery = relation.getQuery();
		favoriteTalksQuery.findInBackground(new FindCallback<Talk>() {

			@Override
			public void done(List<Talk> objects, ParseException e) {
				if ((objects != null) && (!objects.isEmpty())) {
					for (Talk talk : objects) {
						favoriteTalks.add(talk);
						talkIds.add(talk.getObjectId());
					}
				}
			}

		});
	}
}