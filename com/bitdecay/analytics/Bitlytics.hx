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

	private var devMode:Bool = false;
	private var onError:String->Void;

	public static function Init(name:String, sender:DataSender, devMode:Bool = false) {
		instance = new Bitlytics(name, sender, devMode);
	}

	public static function Instance():Bitlytics {
		if (instance == null) {
			throw "Must init Bitlytics before usin the instance";
		}
		return instance;
	}

	private function new(id:String, sender:DataSender, devMode:Bool) {
		#if dev_analytics
		trace('dev_analytics compilation flag detected');
		devMode = true;
		#end

		if (devMode) {
			SetDevMode(true);
			id = "dev_in_progress";
		}

		this.gameID = id;
		this.sender = sender;
		onError = traceError;

		sanityCheck();

		try {
			store = new LocalStore();
			store.Init(gameID + "_data");
		} catch(e:Dynamic) {
			throw 'Failed to load data store with id `${gameID}. Did you set your analytics name properly in the config?';
		}
	}

	private function traceError(msg:String) {
		trace(msg);
	}

	// Allow for manual control over dev state
	public function SetDevMode(dev:Bool) {
		devMode = dev;
		trace('Bitlytics dev mode set to: ${devMode}');
	}

	private function sanityCheck() {
		if (gameID.indexOf("<") > -1 || gameID.indexOf(" ") > -1) {
			if (devMode) {
				trace('gameID "${gameID}" should not contain special characters or spaces. This will not work in a prod build');
			} else {
				throw 'gameID "${gameID} should not contain special characters or spaces';
			}
		}

		var senderStatus = sender.Validate();
		if (senderStatus != null && senderStatus != "") {
			if (devMode) {
				trace('sender failed validation, this will not work in a prod build: "${senderStatus}"');
			} else {
				throw 'bitlytics sender invalid: ${senderStatus}';
			}
		}

		if (devMode) {
			var req = sender.GetPost(sender.Format([new Metric("sanity", null, 1)]));
			req.onError = (s) -> { trace('sender sanity call failed. bitlytics will likely fail in prod : ${s}'); };
			req.onData = (s) -> { trace('sender sanity call successful. bitlytics should function in prod'); };
			req.request(true);
		}
	}

	public function NewSession(tags:Array<Tag>=null, reportIntervalMS:Int = 10000):Void {
		var num = store.NextSessionNum();
		if (session != null) {
			trace("starting new session while existing session in-progress");
			EndSession();
		}

		session = new Session(num, [
			new Tag(Tags.GameID, gameID),
			new Tag(Tags.ClientID, store.GetString(Values.ClientID))
		]);

		timer = new Timer(reportIntervalMS);
		timer.run = postPendingData;
	}

	public function AddSessionTag(tag:Tag) {
		session.AddDefaultTag(tag);
	}

	public function Pause() {
		session.Pause();
	}

	public function Resume() {
		session.Resume();
	}

	public function ForceFlush() {
		postPendingData();
	}

	public function EndSession():Void {
		session.End();
		if (timer != null) {
			timer.stop();
		}
		postPendingData();
	}

	public function Queue(name:String, value:Float, tags:Array<Tag>=null) {
		if (name.indexOf(" ") > -1) {
			trace('Metrics cannot contain spaces. Dropping metric ${name}');
			return;
		}
		session.Add(new Metric(name, tags, value));
	}

	public function setOnError(func:String->Void):Void {
		onError = func;
	}

	private function postPendingData():Void {
		var data = session.GetAllPendingData();
		// TODO: By batching events, all events will have the same time stamp
		// This means that our metric resolution is our reporting interval
		if (data.length == 0) {
			#if debug_level > 2
			trace("No data to send");
			#end

			return;
		}

		var body = sender.Format(data);

		#if debug_level > 2
		trace("Sending " + data.length + " data events");
		#end

		if (devMode) {
			trace('Formatted ${data.length} analytics:\n${body}');
			return;
		}

		var req = sender.GetPost(body);
		if (onError != null) {
			req.onError = onError;
		}

		req.request(true);
	}
}
