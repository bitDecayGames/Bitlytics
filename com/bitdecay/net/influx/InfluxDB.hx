package com.bitdecay.net.influx;

import haxe.Http;

import com.bitdecay.analytics.Metric;

class InfluxDB implements DataSender {

	private var baseURL:String;
	private var org:String;
	private var bucket:String;
	private var authToken:String;

	public function new(url:String, org:String, bucket:String, authToken:String) {
		this.baseURL = url;
		this.org = org;
		this.bucket = bucket;
		this.authToken = authToken;
	}

	public function GetPost(data:String):Http {
		var request:Http = new Http('${baseURL}?org=${org}&bucket=${bucket}&precision=s');
		var postData:String = data;
		request.addHeader("Content-Type", "text/plain");
		request.addHeader("Authorization", 'Token ${authToken}');
		request.setPostData(postData);
		trace("payload: " + postData);
		return request;
	}

	public function Format(data:Array<Metric>):String {
		var buf = new StringBuf();
		for (d in data) {
			if (buf.length > 0) {
				buf.add("\n");
			}

			buf.add(d.name);

			if (d.tags.length > 0) {
				buf.add(",");

				buf.add([for (tag in d.tags) {
					'${tag.name}=${tag.value}';
				}].join(","));
			}
			buf.add(" ");
			
			buf.add('value=${d.value}');
		}
		return buf.toString();
	}
}