package com.bitdecay.analytics;

import com.bitdecay.metrics.Common;
import com.bitdecay.metrics.Tags;
import com.bitdecay.metrics.Tag;
import com.bitdecay.metrics.Metric;
import haxe.Int64;
import com.bitdecay.uuid.UUID;

class Session {
	public var num:Int = 0;

	private var id:String = "";

	private var defaultTags:Array<Tag>;

	private var start:Float = 0.0;
	private var timing:Bool = true;
	private var sessionTime:Float = 0.0;

	private var pendingEvents:Array<Metric>;
	private var gauges:Map<String, Metric>;

	public function new(sessionNum:Int, tags:Array<Tag>) {
		num = sessionNum;

		id = UUID.create();

		#if (debug_level > "1")
		trace('created session: ${id} (${num})');
		#end

		this.defaultTags = tags;
		defaultTags.push(new Tag(Tags.Session, Std.string(num)));
		defaultTags.push(new Tag(Tags.SessionID, id));

		start = Date.now().getTime();
		pendingEvents = new Array<Metric>();
		gauges = new Map<String, Metric>();

		AddEvent(Metric.get(Common.SessionStarted, null, 1));
	}

	public function Pause() {
		addTimeEvent();
		timing = false;
	}

	public function Resume() {
		start = Date.now().getTime();
		timing = true;
	}

	public function AddDefaultTag(tag:Tag) {
		defaultTags.push(tag);
	}

	public function AddEvent(metric:Metric):Void {
		for (t in defaultTags) {
			metric.tags.push(t);
		}

		metric.timestampMS = Int64.fromFloat(Date.now().getTime());

		pendingEvents.push(metric);
	}

	public function StartGauge(name:String, initial:Metric) {
		if (gauges.exists(name)) {
			// recycle anything that was there
			gauges.get(name).put();
		}

		for (t in defaultTags) {
			initial.tags.push(t);
		}

		// Gauges are continuous values without a timestamp
		initial.timestampMS = 0;
		gauges.set(name, initial);
	}

	public function SetGauge(name:String, value:Float):Void {
		if (!gauges.exists(name)) {
			#if dev_analytics
			trace('attempting to set gauge value before gauge is started')
			#end
		} else {
			gauges.get(name).value = value;
		}
	}

	public function GetAllPendingData():Array<Metric> {
		if (timing) {
			addTimeEvent();
		}

		var all = pendingEvents.splice(0, pendingEvents.length);
		for (key in gauges.keys()) {
			all.push(gauges.get(key));
		}

		return all;
	}

	private function addTimeEvent() {
		var now = Date.now().getTime();
		sessionTime += (now - start);

		AddEvent(Metric.get(Common.SessionTime, null, sessionTime / 1000.0));
		start = now;
	}

	public function End():Float {
		addTimeEvent();
		AddEvent(Metric.get(Common.SessionEnded, null, 1));
		timing = false;
		return sessionTime;
	}
}
