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

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBar.Tab;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.matabii.dev.scaleimageview.ScaleImageView;
import com.parse.f8.R;

public class MapsActivity extends BaseActivity implements ActionBar.TabListener {

	private MapsPagerAdapter mapsPagerAdapter;
	private ViewPager mapsViewPager;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_map);

		final ActionBar actionBar = getSupportActionBar();
		actionBar.setHomeButtonEnabled(false);
		actionBar.setDisplayShowTitleEnabled(false);
		actionBar.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
		actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);

		mapsViewPager = (ViewPager) findViewById(R.id.pager);
		mapsPagerAdapter = new MapsPagerAdapter(getSupportFragmentManager());
		mapsViewPager.setAdapter(mapsPagerAdapter);
		mapsViewPager
				.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
					@Override
					public void onPageSelected(int position) {
						actionBar.setSelectedNavigationItem(position);
					}
				});

		// Add a tab to the action bar for each subsection
		for (int i = 0; i < mapsPagerAdapter.getCount(); i++) {

			actionBar.addTab(actionBar.newTab()
					.setText(mapsPagerAdapter.getPageTitle(i))
					.setTabListener(this));
		}

	}

	private class MapsPagerAdapter extends FragmentStatePagerAdapter {

		public MapsPagerAdapter(android.support.v4.app.FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int i) {
			Fragment fragment = new MapDetailFragment();
			Bundle args = new Bundle();
			args.putInt(MapDetailFragment.ARG_MAP, i);
			fragment.setArguments(args);
			return fragment;
		}

		@Override
		public int getCount() {
			return 3;
		}

		@Override
		public CharSequence getPageTitle(int position) {
			switch (position) {
			case 0:
				return getResources().getString(R.string.map_title_morning);

			case 1:
				return getResources().getString(R.string.map_title_afternoon);

			default:
				return getResources().getString(R.string.map_title_evening);
			}
		}
	}

	private class MapDetailFragment extends Fragment {

		public static final String ARG_MAP = "map";

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			View rootView = inflater.inflate(R.layout.fragment_map_detail,
					container, false);
			int mapId = getArguments().getInt(ARG_MAP);
			ScaleImageView map = (ScaleImageView) rootView
					.findViewById(R.id.map_view);
			switch (mapId) {
			case 0:
				map.setImageResource(R.drawable.map_morning);
				return rootView;

			case 1:
				map.setImageResource(R.drawable.map_afternoon);
				return rootView;

			default:
				map.setImageResource(R.drawable.map_night);
				return rootView;
			}
		}
	}

	@Override
	public void onTabReselected(Tab arg0, FragmentTransaction arg1) {
		// Do nothing
	}

	@Override
	public void onTabSelected(Tab arg0, FragmentTransaction arg1) {
		mapsViewPager.setCurrentItem(arg0.getPosition());

	}

	@Override
	public void onTabUnselected(Tab arg0, FragmentTransaction arg1) {
		// Do nothing
	}
}
