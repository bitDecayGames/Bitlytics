package com.bitdecay.analytics;

import com.bitdecay.metrics.Metric;
import com.bitdecay.metrics.Tags;
import com.bitdecay.metrics.Common;
import com.bitdecay.metrics.Tag;
import massive.munit.Assert;
import com.bitdecay.analytics.Session;

class SessionTest {
	@Test
	public function testPlainSession() {
		var session = new Session(1, []);
		session.End();
		var data = session.GetAllPendingData();
		Assert.areEqual(3, data.length, 'expected 3 data points, got: ${data.length}');
		Assert.areEqual(Common.SessionStarted, data[0].name, 'first datapoint of session should be session start, got ${data[0].name}');
		Assert.areEqual(Common.SessionTime, data[1].name, 'last datapoint of session should be session timing, got ${data[1].name}');
		Assert.areEqual(Common.SessionEnded, data[2].name, 'last datapoint of session should be session end, got ${data[1].name}');

		for (i in 0...data.length) {
			Assert.areEqual(2, data[i].tags.length, 'expected 2 tags on datapoint ${i}, got: ${data[i].tags.length}');
			Assert.areEqual(Tags.Session, data[i].tags[0].name, 'expected session tag as first tag of datapoint ${i}, got: ${data[i].tags[0].name}');
			Assert.areEqual(Tags.SessionID, data[i].tags[1].name, 'expected sessionID tag as second tag of datapoint ${i}, got: ${data[i].tags[1].name}');
		}
	}

	@Test
	public function testGauge() {
		var metricName = "testGauge";

		var session = new Session(1, []);
		session.StartGauge(metricName, Metric.get(metricName, null, 333));
		var data = session.GetAllPendingData();

		// Gauge metrics are added after all of the events
		var expectedDataPoints = 3;
		var index = 2;

		Assert.areEqual(expectedDataPoints, data.length, 'expected ${expectedDataPoints} data points, got: ${data.length}');
		Assert.areEqual(metricName, data[index].name, 'datapoint should be ${metricName}, got ${data[index].name}');
		Assert.areEqual(333, data[index].value, 'expected gauge value to equal 333, got: ${data[index].value}');

		for (i in 0...10) {
			session.SetGauge(metricName, i);
		}

		var expectedDataPoints = 2;
		var index = 1;

		data = session.GetAllPendingData();
		Assert.areEqual(expectedDataPoints, data.length, 'expected ${expectedDataPoints} data points, got: ${data.length}');
		Assert.areEqual(metricName, data[index].name, 'datapoint should be ${metricName}, got ${data[index].name}');
		Assert.areEqual(9, data[index].value, 'expected gauge value to equal 9, got: ${data[index].value}');
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

	@Test
	public function testTimestampAddedToMetrics() {
		var session = new Session(1, []);
		session.AddEvent(new Metric());
		var data = session.GetAllPendingData();

		var found:Bool;
		for (i in 0...data.length) {
			Assert.isTrue(data[i].timestampMS > 0, 'metric ${i} expected to have time stamp');
		}
	}
}
