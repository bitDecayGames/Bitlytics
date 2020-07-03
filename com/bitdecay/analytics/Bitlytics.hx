package com.bitdecay.analytics;

import com.bitdecay.db.Values;
import com.bitdecay.db.DataStore;
import com.bitdecay.db.LocalStore;

class Bitlytics {
	private static var instance:Bitlytics;

	private var gameID:String;
	private var store:DataStore;
	private var session:Session;

	public static function Init(name:String) {
		instance = new Bitlytics(name);
	}

	public static function Instance():Bitlytics {
		if (instance == null) {
			instance = new Bitlytics("bitdecay_default");
		}
		return instance;
	}

	private function new(id:String) {
		store = new LocalStore();
		this.gameID = id;
		store.Init(gameID + "_data");
	}

	public function NewSession():Void {
		var num = store.NextSessionNum();
		if (session != null) {
			trace("starting new sesion while existing session in-progress");
			session.End();
		}

		trace("starting sesion: " + num);
		session = new Session(num, [
			new Tag(Tags.GameID, store.GetString(gameID)),
			new Tag(Tags.ClientID, store.GetString(Values.ClientID))
		]);
	}

	public function EndSession():Void {
		session.End();
	}

	public function Queue(name:String, value:Float) {
		session.Add(new Metric(name, null, value));
	}
}
