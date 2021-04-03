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
			#if (debug_level > 1)
			trace('LocalStore ("${key}") loaded for existing client with UUID: ${Reflect.getProperty(sharedObj.data, Values.ClientID)}');
			#end
			return;
		} else {
			Reflect.setField(sharedObj.data, Values.Initialized, true);
			Reflect.setField(sharedObj.data, Values.ClientID, UUID.create());
			Reflect.setField(sharedObj.data, Values.SessionNum, 1);
			Flush();
			#if (debug_level > 1)
			trace('LocalStore ("${key}") initialized with UUID: ${Reflect.getProperty(sharedObj.data, Values.ClientID)}');
			#end
		}
	}

	public function PutString(key:String, value:String):Void {
		Reflect.setField(sharedObj.data, key, value);
		sharedObj.flush();
	}

	public function GetString(prop:String):String {
		return Reflect.getProperty(sharedObj.data, prop);
	}

	public function NextSessionNum():Int {
		var num = Reflect.getProperty(sharedObj.data, Values.SessionNum);
		Reflect.setField(sharedObj.data, Values.SessionNum, num + 1);
		Flush();
		return num;
	}

	public function Flush():Void {
		sharedObj.flush();
	}
}
