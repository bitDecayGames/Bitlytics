package com.bitdecay.analytics;

import haxe.Timer;
import com.bitdecay.db.Values;
import com.bitdecay.db.DataStore;
import com.bitdecay.db.LocalStore;

class Bitlytics {
	private static var instance:Bitlytics;

	private var gameID:String;
	private var authToken:String;
	private var org:String;
	private var bucket:String;

	private var store:DataStore;
	private var session:Session;

	private var timer:Timer;

	public static function Init(name:String, authToken:String, org:String, bucket:String) {
		instance = new Bitlytics(name, authToken, org, bucket);
	}

	public static function Instance():Bitlytics {
		if (instance == null) {
			throw "Must init Bitlytics before usin the instance";
		}
		return instance;
	}

	private function new(id:String, authToken:String, org:String, bucket:String) {
		store = new LocalStore();
		this.gameID = id;
		this.authToken = authToken;
		this.org = org;
		this.bucket = bucket;
		store.Init(gameID + "_data");
	}

	public function NewSession(reportInterval:Float = 10000):Void {
		var num = store.NextSessionNum();
		if (session != null) {
			trace("starting new sesion while existing session in-progress");
			session.End();
			timer.stop();
			postPendingData();
		}

		trace("starting sesion: " + num);
		session = new Session(num, [
			new Tag(Tags.GameID, store.GetString(gameID)),
			new Tag(Tags.ClientID, store.GetString(Values.ClientID))
		]);

		timer = new Timer(reportInterval);
		timer.run = postPendingData;
	}

	public function EndSession():Void {
		session.End();
	}

	public function Queue(name:String, value:Float) {
		session.Add(new Metric(name, null, value));
	}

	private function postPendingData():Void {
		var data = session.GetAllPendingData();
		// TODO: In doing this, all events will have the same time stamp
		// This means that our metric resolution is our reporting interval
		if (data.length > 0) {
			trace("Sending " + data.length + " data events");
		} else {
			trace("No data to send");
		}
	}
}
