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
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBar.Tab;

import com.parse.f8.R;

public class ScheduleActivity extends BaseActivity implements
		ActionBar.TabListener {

	private ScheduleSectionsPagerAdapter scheduleSectionsPagerAdapter;
	private ViewPager sectionsViewPager;
	private ActionBar actionBar;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		scheduleSectionsPagerAdapter = new ScheduleSectionsPagerAdapter(
				getSupportFragmentManager());

		setContentView(R.layout.activity_schedule);

		actionBar = getSupportActionBar();
		actionBar.setHomeButtonEnabled(false);
		actionBar.setDisplayShowTitleEnabled(false);
		actionBar.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

		actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
		actionBar.setStackedBackgroundDrawable(new ColorDrawable(
				Color.TRANSPARENT));
		sectionsViewPager = (ViewPager) findViewById(R.id.schedule_pager);
		sectionsViewPager.setAdapter(scheduleSectionsPagerAdapter);
		sectionsViewPager.setOffscreenPageLimit(TRIM_MEMORY_RUNNING_MODERATE);
		sectionsViewPager
				.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
					@Override
					public void onPageSelected(int position) {
						actionBar.setSelectedNavigationItem(position);
					}
				});

		// Add a tab to the action bar for each subsection
		for (int i = 0; i < scheduleSectionsPagerAdapter.getCount(); i++) {
			ActionBar.Tab scheduleTab = actionBar.newTab()
					.setIcon(scheduleSectionsPagerAdapter.getPageIcon(i))
					.setTabListener(this);
			scheduleTab.getIcon().setAlpha(80);
			actionBar.addTab(scheduleTab);
		}

	}

	public static class ScheduleSectionsPagerAdapter extends
			FragmentStatePagerAdapter {

		public ScheduleSectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int i) {
			if (i == 0) {
				Fragment fragment = new WelcomeFragment();
				return fragment;
			} else {
				Fragment fragment = new ScheduleFragment();
				Bundle args = new Bundle();
				args.putInt(ScheduleFragment.ARG_TRACK, i);
				fragment.setArguments(args);
				return fragment;
			}
		}

		@Override
		public int getCount() {
			return 12;
		}

		public int getPageIcon(int position) {
			switch (position) {
			case 0:
				return R.drawable.welcome;
			case 1:
				return R.drawable.registration;
			case 2:
				return R.drawable.keynote;
			case 3:
				return R.drawable.lunch;
			case 4:
				return R.drawable.build;
			case 5:
				return R.drawable.grow;
			case 6:
				return R.drawable.monetize;
			case 7:
				return R.drawable.hackerway;
			case 8:
				return R.drawable.thegarage;
			case 9:
				return R.drawable.gameslounge;
			case 10:
				return R.drawable.internetorg;
			default:
				return R.drawable.party;
			}
		}
	}

	@Override
	public void onTabReselected(Tab arg0, FragmentTransaction arg1) {
		// Do nothing
	}

	@Override
	public void onTabSelected(Tab arg0, FragmentTransaction arg1) {
		sectionsViewPager.setCurrentItem(arg0.getPosition());
		Drawable icon = actionBar.getSelectedTab().getIcon();
		if (icon != null) {
			icon.setAlpha(255);
		}
	}

	@Override
	public void onTabUnselected(Tab arg0, FragmentTransaction arg1) {
		Drawable icon = actionBar.getSelectedTab().getIcon();
		if (icon != null) {
			icon.setAlpha(80);
		}
	}

}
