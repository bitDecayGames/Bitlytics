package com.bitdecay.analytics;

import com.bitdecay.metrics.Tags;
import com.bitdecay.metrics.Common;
import com.bitdecay.metrics.Metric;
import com.bitdecay.metrics.Tag;
import massive.munit.Assert;

import com.bitdecay.analytics.Session;

class SessionTest {
	@Test
	public function testPlainSession() {
		var session = new Session(1, []);
		var data = session.GetAllPendingData();
		Assert.areEqual(2, data.length, 'expected 2 data points, got: ${data.length}');
		Assert.areEqual(Common.SessionStarted, data[0].name, 'first datapoint of session should be session start, got ${data[0].name}');
		Assert.areEqual(Common.SessionTime, data[1].name, 'last datapoint of session should be session timing, got ${data[1].name}');

		for (i in 0...data.length) {
			Assert.areEqual(2, data[i].tags.length, 'expected 2 tags on datapoint ${i}, got: ${data[i].tags.length}');
			Assert.areEqual(Tags.Session, data[i].tags[0].name, 'expected session tag as first tag of datapoint ${i}, got: ${data[i].tags[0].name}');
			Assert.areEqual(Tags.SessionID, data[i].tags[1].name, 'expected sessionID tag as second tag of datapoint ${i}, got: ${data[i].tags[1].name}');
		}
	}

	@Test
	public function testCustomDefaultTags() {
		var session = new Session(1, [new Tag("customTag", "customValue")]);
		var data = session.GetAllPendingData();

		var found:Bool;
		for (i in 0...data.length) {
			found = false;
			for (tag in data[i].tags) {
				if (tag.name == "customTag") {
					found = true;
				}
			}
			Assert.isTrue(found, 'metric ${i} expected to have custom tag');
		}
	}
}