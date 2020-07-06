package com.bitdecay.analytics;

import haxe.Timer;
import com.bitdecay.db.Values;
import com.bitdecay.db.DataStore;
import com.bitdecay.db.LocalStore;
import com.bitdecay.net.DataSender;

class Bitlytics {
	private static var instance:Bitlytics;

	private var gameID:String;
	private var sender:DataSender;

	private var store:DataStore;
	private var session:Session;

	private var timer:Timer;

	private var debugMode:Bool = false;
	private var onError:String->Void;

	public static function Init(name:String, sender:DataSender) {
		instance = new Bitlytics(name, sender);
	}

	public static function Instance():Bitlytics {
		if (instance == null) {
			throw "Must init Bitlytics before usin the instance";
		}
		return instance;
	}

	private function new(id:String, sender:DataSender) {
		store = new LocalStore();
		this.gameID = id;
		this.sender = sender;
		onError = traceError;
		store.Init(gameID + "_data");
	}

	private function traceError(msg:String) {
		trace(msg);
	}

	public function SetDebug(debug:Bool) {
		debugMode = debug;
		trace('Bitlytics debug set to: ${debug}');
	}

	public function NewSession(reportIntervalMS:Int = 10000):Void {
		var num = store.NextSessionNum();
		if (session != null) {
			trace("starting new session while existing session in-progress");
			EndSession();
		}

		trace("starting session: " + num);
		session = new Session(num, [
			new Tag(Tags.GameID, gameID),
			new Tag(Tags.ClientID, store.GetString(Values.ClientID))
		]);

		timer = new Timer(reportIntervalMS);
		timer.run = postPendingData;
	}

	public function Pause() {
		session.Pause();
	}

	public function Resume() {
		session.Resume();
	}

	public function EndSession():Void {
		session.End();
		if (timer != null) {
			timer.stop();
		}
		postPendingData();
	}

	public function Queue(name:String, value:Float) {
		if (name.indexOf(" ") > -1) {
			trace('Metrics cannot contain spaces. Dropping metric ${name}');
			return;
		}
		session.Add(new Metric(name, null, value));
	}

	public function setOnError(func:String->Void):Void {
		onError = func;
	}

	private function postPendingData():Void {
		var data = session.GetAllPendingData();
		// TODO: In doing this, all events will have the same time stamp
		// This means that our metric resolution is our reporting interval
		if (data.length == 0) {
			trace("No data to send");
			return;
		}

		var body = sender.Format(data);

		if (debugMode) {
			trace("Sending " + data.length + " data events");
			trace('Formatted analytics:\n${body}');
			return;
		}

		var req = sender.GetPost(body);
		if (onError != null) {
			req.onError = onError;
		}

		req.request(true);
	}
}
