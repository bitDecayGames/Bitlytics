package com.bitdecay.net;

class InfluxDB {

	public var baseURL = "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/write";
	public var token = "Token fljf9wQb3bwY8Nb6FO7dWRaHMWvDVUwcgGshEqB0cMyKWmbcr6hKg1iW_BMPm-AAKL9D53aF27ysmKVWF78aJA=="
	public var org = "13ecc65d2303c6d7";
	public var bucket = "testMetrics";
	public var precision = "s"

	public function Post(url:String, data:String):Http
		{
			var request:Http = new Http(url);
			var postData:String = data;
			request.addHeader("Content-Type", "application/json");
			var cryptoString:String = Base64.encode(_hmac.make(Bytes.ofString(_secretKey), Bytes.ofString(data)));
			request.addHeader("Authorization", token);
			request.setPostData(postData);
			return request;
		}
}