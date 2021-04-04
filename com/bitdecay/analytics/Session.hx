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

	private var pendingData:Array<Metric>;

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
		pendingData = new Array<Metric>();

		Add(Metric.get(Common.SessionStarted, null, 1));
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

	public function Add(metric:Metric):Void {
		for (t in defaultTags) {
			metric.tags.push(t);
		}

		metric.timestampMS = Int64.fromFloat(Date.now().getTime());

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

		Add(Metric.get(Common.SessionTime, null, sessionTime / 1000.0));
		start = now;
	}

	public function End():Float {
		addTimeEvent();
		timing = false;
		return sessionTime;
	}
}
