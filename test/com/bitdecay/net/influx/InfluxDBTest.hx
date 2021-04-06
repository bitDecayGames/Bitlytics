package com.bitdecay.net.influx;

import com.bitdecay.metrics.Metric;
import com.bitdecay.net.influx.InfluxDB;
import com.bitdecay.metrics.Tag;
import massive.munit.Assert;

class InfluxDBTest {
	@Test
	public function testValidation() {
		var influx = new InfluxDB("", "", "", "");
		Assert.areEqual("baseURL is empty, org is empty, bucket is empty, authToken is empty", influx.Validate());
		influx = new InfluxDB("testURL", "", "", "");
		Assert.areEqual("org is empty, bucket is empty, authToken is empty", influx.Validate());
		influx = new InfluxDB("testURL", "testOrg", "", "");
		Assert.areEqual("bucket is empty, authToken is empty", influx.Validate());
		influx = new InfluxDB("testURL", "testOrg", "testBucket", "");
		Assert.areEqual("authToken is empty", influx.Validate());
		influx = new InfluxDB("testURL", "testOrg", "testBucket", "testToken");
		Assert.isEmpty(influx.Validate());
	}

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
