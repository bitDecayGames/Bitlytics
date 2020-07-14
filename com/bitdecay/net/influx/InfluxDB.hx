package com.bitdecay.net.influx;

import haxe.Json;
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

	public static function load(input:Dynamic, authToken:String):InfluxDB {
		return new InfluxDB(input.api, input.org, input.bucket, authToken);
	}

	public function GetPost(data:String):Http {
		var request:Http = new Http('${baseURL}?org=${org}&bucket=${bucket}&precision=s');
		var postData:String = data;
		request.addHeader("Content-Type", "text/plain");
		request.addHeader("Authorization", 'Token ${authToken}');
		request.setPostData(postData);
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

	public function Validate():String {
		var errors:Array<String> = [];
		if (baseURL == null || baseURL == "") {
			errors.push("baseURL is empty");
		}
		if (org == null || org == "") {
			errors.push("org is empty");
		}
		if (bucket == null || bucket == "") {
			errors.push("bucket is empty");
		}
		if (authToken == null || authToken == "") {
			errors.push("authToken is empty");
		}

		return errors.join(", ");
	}
}