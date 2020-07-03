package com.bitdecay.analytics;

class Session {
	public var num:Int;

	private var defaultTags:Array<Tag>;

	private var start:Float;
	private var pendingData:List<Metric>;


	public function new(sessionNum:Int, tags:Array<Tag>) {
		num = sessionNum;
		
		this.defaultTags = tags;
		defaultTags.push(new Tag(Tags.Session, Std.string(num)));

		start = Date.now().getTime();
		pendingData = new List<Metric>();
	}

	public function Add(metric:Metric):Void {
		for (t in defaultTags) {
			metric.tags.push(t);
		}

		pendingData.add(metric);
		trace("session " + num + " now has " + pendingData.length + " pending metrics");
	}

	public function End():Float {
		var duration = Date.now().getTime() - start;
		return duration;
	}
}