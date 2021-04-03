package com.bitdecay.metrics;

class ObjectPool<T> {
	private var pooledType:Class<T>;
	private var pool:Array<T>;
	private var counter:Int;

	public function new(_pooledType:Class<T>, len:Int) {
		pooledType = _pooledType;
		pool = getPoolPortion(len);
		counter = len - 1;

		#if (debug_level > "3")
		trace('pool size now: ${pool.length}. current counter: ${counter}');
		#end
	}

	private function getPoolPortion(len:Int):Array<T> {
		var portion = new Array();

		var i:Int = len;
		while (i-- > 0) {
			portion.push(Type.createInstance(pooledType, []));
		}

		return portion;
	}

	public function get():T {
		if (counter < 0) {
			// if we run out of pooled elements, double our pool
			var tempLen = pool.length;
			pool = getPoolPortion(tempLen).concat(pool);
			counter = tempLen - 1;

			#if (debug_level > "3")
			trace('pool size now: ${pool.length}. current counter: ${counter}');
			#end
		}

		#if (debug_level > "3")
		trace('returning object counter: ${counter}');
		#end
		return pool[counter--];
	}

	public function put(s:T):Void {
		counter++;
		pool[counter] = s;
		#if (debug_level > "3")
		trace('returning to pool object counter: ${counter}');
		#end
	}
}
