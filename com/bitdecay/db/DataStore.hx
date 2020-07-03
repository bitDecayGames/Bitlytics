package com.bitdecay.db;

interface DataStore {
	public function Init(key:String):Void;
	public function NextSessionNum():Int;
	public function GetString(prop:String):String;
	public function Flush():Void;
}
