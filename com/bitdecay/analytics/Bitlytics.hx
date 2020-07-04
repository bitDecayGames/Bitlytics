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
			new Tag(Tags.GameID, gameID),
			new Tag(Tags.ClientID, store.GetString(Values.ClientID))
		]);

		timer = new Timer(reportInterval);
		timer.run = postPendingData;
	}

	public function EndSession():Void {
		session.End();
	}

	public function Queue(name:String, value:Float) {
		if (name.indexOf(" ") > -1) {
			trace('Metrics cannot contain spaces. Dropping metric ${name}');
			return;
		}
		session.Add(new Metric(name, null, value));
	}

	private function postPendingData():Void {
		var data = session.GetAllPendingData();
		// TODO: In doing this, all events will have the same time stamp
		// This means that our metric resolution is our reporting interval
		if (data.length == 0) {
			trace("No data to send");
			return;
		}

		trace("Sending " + data.length + " data events");
		var body = sender.Format(data);
		sender.Post(body);
	}
}
