package com.bitdecay.analytics;

class Metric {
	public var name:String;
	public var tags:Array<Tag>;
	public var value:Float;

	public function new(name:String, tags:Array<Tag>, value:Float) {
		this.name = name;
		if (tags == null) {
			tags = [];
		}
		this.tags = tags;
		this.value = value;
	}
}