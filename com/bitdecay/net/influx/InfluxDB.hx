package com.bitdecay.net.influx;

import haxe.Http;
import com.bitdecay.metrics.Metric;

class InfluxDB implements DataSender {
	private static inline var PRECISION="ms";

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
		var request:Http = new Http('${baseURL}?org=${org}&bucket=${bucket}&precision=${PRECISION}');
		var postData:String = data;
		request.addHeader("Content-Type", "text/plain");
		request.addHeader("Authorization", 'Token ${authToken}');
		request.setPostData(postData);
		return request;
	}

	/**
	 * Format the Metrics according to InfluxDB line protocol
	 * ```haxe
	 * measurementName,tagKey=tagValue fieldKey="fieldValue" 1465839830100400200
	 *                                |                     |
	 *                            1st space             2nd space
	 * ```
	 */
	public function Format(data:Array<Metric>):String {
		var buf = new StringBuf();
		for (d in data) {
			if (buf.length > 0) {
				buf.add("\n");
			}

			buf.add(d.name);

			if (d.tags.length > 0) {
				buf.add(",");

				buf.add([
					for (tag in d.tags) {
						'${tag.name}=${tag.value}';
					}
				].join(","));
			}
			buf.add(" ");

			buf.add('value=${d.value}');

			if (d.timestampMS != null && d.timestampMS > 0) {
				buf.add(" ");
				buf.add('${d.timestampMS}');
			}
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
