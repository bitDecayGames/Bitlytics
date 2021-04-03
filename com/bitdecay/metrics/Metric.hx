package com.bitdecay.metrics;

import haxe.Int64;

class Metric {
	private static var pool:ObjectPool<Metric> = new ObjectPool(Metric, 100);

	public var name:String;
	public var tags:Array<Tag>;
	public var value:Float;
	public var timestampMS:Int64;

	public static function get(name:String, tags:Array<Tag>, value:Float):Metric {
		var m = pool.get();
		m.name = name;
		if (tags == null) {
			tags = [];
		}
		m.tags = tags;
		m.value = value;

		return m;
	}

	public function new() {
		name = "";
		tags = [];
		value = 0.0;
		timestampMS = 0;
	}

	public function put() {
		Metric.pool.put(this);
	}
}
