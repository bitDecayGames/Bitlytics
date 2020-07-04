package com.bitdecay.net;

import com.bitdecay.analytics.Metric;

interface DataSender {
	public function Post(body:String):Void;
	public function Format(data:Array<Metric>):String;
}