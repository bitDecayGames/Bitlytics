package com.bitdecay.analytics;

import haxe.Timer;

class Session {
	public var num:Int;

	private var defaultTags:Array<Tag>;

	private var start:Float;
	private var pendingData:Array<Metric>;

	public function new(sessionNum:Int, tags:Array<Tag>) {
		num = sessionNum;
		
		this.defaultTags = tags;
		defaultTags.push(new Tag(Tags.Session, Std.string(num)));

		start = Date.now().getTime();
		pendingData = new Array<Metric>();

		Add(new Metric(Common.SessionStarted, null, 1));
	}

	public function Add(metric:Metric):Void {
		for (t in defaultTags) {
			metric.tags.push(t);
		}

		pendingData.push(metric);
		trace("session " + num + " now has " + pendingData.length + " pending metrics");
	}

	public function GetAllPendingData():Array<Metric> {
		return pendingData.splice(0, pendingData.length);
	}

	public function End():Float {
		var duration = Date.now().getTime() - start;
		Add(new Metric(Common.SessionEnded, null, duration));

		return duration;
	}
}