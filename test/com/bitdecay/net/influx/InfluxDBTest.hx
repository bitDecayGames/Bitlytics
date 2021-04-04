package com.bitdecay.net.influx;

import com.bitdecay.metrics.Metric;
import com.bitdecay.net.influx.InfluxDB;
import com.bitdecay.metrics.Tags;
import com.bitdecay.metrics.Common;
import com.bitdecay.metrics.Tag;
import massive.munit.Assert;
import com.bitdecay.analytics.Session;

class InfluxDBTest {
	@Test
	public function testFormatting() {
		var influx = new InfluxDB("testURL", "testOrg", "testBucket", "testToken");
		var testMetric = new Metric();
		var testTag = new Tag("testTag", "testTagValue");
		testMetric.name = "testName";
		testMetric.value = 123;
		testMetric.tags = [testTag];
		testMetric.timestampMS = 1;
		var formatted = influx.Format([testMetric]);
		Assert.areEqual('${testMetric.name},${testTag.name}=${testTag.value} value=${testMetric.value} ${testMetric.timestampMS * 1000000}', formatted);
	}
}
