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

import java.util.List;

import android.graphics.Color;

import com.parse.GetCallback;
import com.parse.ParseClassName;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

@ParseClassName("Room")
public class Room extends ParseObject {
	public String getName() {
		return getString("name");
	}

	public int getColor() {
		List<Integer> colorValues = this.getList("displayColor");
		int color = Color.rgb(colorValues.get(0), colorValues.get(1),
				colorValues.get(2));
		return color;
	}
	
	public static void findInBackground(int order,
			final GetCallback<Room> callback) {
		ParseQuery<Room> roomQuery = ParseQuery.getQuery(Room.class);
		roomQuery.whereEqualTo("order", order);
		roomQuery.getFirstInBackground(new GetCallback<Room>() {

			@Override
			public void done(Room room, ParseException e) {
				if (e == null) {
					callback.done(room, null);
				} else {
					callback.done(null, e);
				}
			}
		});
	}
}
