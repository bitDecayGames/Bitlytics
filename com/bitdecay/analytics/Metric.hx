package com.bitdecay.analytics;

import haxe.Int64;

class Metric {
	public var name:String;
	public var tags:Array<Tag>;
	public var value:Float;
	public var timestampMS:Int64;

	public function new(name:String, tags:Array<Tag>, value:Float) {
		this.name = name;
		if (tags == null) {
			tags = [];
		}
		this.tags = tags;
		this.value = value;
	}
}
