package com.bitdecay.db;

import com.bitdecay.db.Values;
import com.bitdecay.uuid.UUID;
import openfl.net.SharedObject;

class LocalStore implements DataStore {
	private var sharedObj:SharedObject;

	public function new() {}

	public function Init(key:String):Void {
		sharedObj = SharedObject.getLocal(key);

		if (Reflect.getProperty(sharedObj.data, Values.Initialized) == true) {
			trace("LocalStore (\"" + key + "\") already initialized");
			return;
		} else {
			Reflect.setField(sharedObj.data, Values.Initialized, true);
			Reflect.setField(sharedObj.data, Values.ClientID, UUID.create());
			Reflect.setField(sharedObj.data, Values.SessionNum, 0);
			trace("LocalStore (\"" + key + "\") initialized with UUID: " + Reflect.getProperty(sharedObj.data, Values.ClientID));
		}
	}

	public function GetString(prop:String):String {
		return Reflect.getProperty(sharedObj.data, prop);
	}

	public function NextSessionNum():Int {
		var num = Reflect.getProperty(sharedObj.data, Values.SessionNum);
		Reflect.setField(sharedObj.data, Values.SessionNum, num+1);
		return num;
	}

	public function Flush():Void {
		sharedObj.flush();
	}
}
