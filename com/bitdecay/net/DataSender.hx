package com.bitdecay.net;

import haxe.Http;
import com.bitdecay.analytics.Metric;

interface DataSender {
	public function GetPost(body:String):Http;
	public function Format(data:Array<Metric>):String;
	public function Validate():String;
}