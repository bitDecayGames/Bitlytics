package com.bitdecay.analytics;

import haxe.Timer;

class Session {
	public var num:Int;

	private var defaultTags:Array<Tag>;

	private var start:Float;
	private var timing:Bool = true;
	private var sessionTime:Float;


	private var pendingData:Array<Metric>;

	public function new(sessionNum:Int, tags:Array<Tag>) {
		num = sessionNum;
		
		this.defaultTags = tags;
		defaultTags.push(new Tag(Tags.Session, Std.string(num)));

		start = Date.now().getTime();
		pendingData = new Array<Metric>();

		Add(new Metric(Common.SessionStarted, null, 1));
	}

	public function Pause() {
		addTimeEvent();
		timing = false;
	}

	public function Resume() {
		start = Date.now().getTime();
		timing = true;
	}

	public function Add(metric:Metric):Void {
		for (t in defaultTags) {
			metric.tags.push(t);
		}

		pendingData.push(metric);
	}

	public function GetAllPendingData():Array<Metric> {
		if (timing) {
			addTimeEvent();
		}
		return pendingData.splice(0, pendingData.length);
	}

	private function addTimeEvent() {
		var now = Date.now().getTime();
		sessionTime += (now - start);
		Add(new Metric(Common.SessionTime, null, sessionTime / 1000));
		start = now;
	}

	public function End():Float {
		var duration = Date.now().getTime() - start;
		return duration;
	}
}