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

import org.json.JSONArray;

import com.parse.GetCallback;
import com.parse.ParseClassName;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

@ParseClassName("GeneralInfo")
public class GeneralInfo extends ParseObject {

	public String getDescription() {
		String description = getString("description");
		if (description == null) {
			description = "";
		}
		return description;
	}
	
	public JSONArray getDetail() {
		return getJSONArray("detail");
	}

	public static void findInBackground(final GetCallback<GeneralInfo> callback) {
		ParseQuery<GeneralInfo> generalInfoQuery = ParseQuery
				.getQuery(GeneralInfo.class);
		generalInfoQuery.getFirstInBackground(new GetCallback<GeneralInfo>() {
			@Override
			public void done(GeneralInfo generalInfo, ParseException e) {
				if (e == null) {
					callback.done(generalInfo, null);
				} else {
					callback.done(null, e);
				}
			}
		});
	}
}
