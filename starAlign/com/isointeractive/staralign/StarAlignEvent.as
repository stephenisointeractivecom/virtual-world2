﻿package com.isointeractive.staralign {
	import flash.events.Event;
	
	public class StarAlignEvent extends Event{
		
		public static const KILL_STAR:String = "staralignevent_kill_star";
		public static const GLOW_STONE_ACTIVATE:String = "staralignevent_glow_stone_activate";
		
		private var _params:Object;

		public function StarAlignEvent(type:String, param:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_params = param;
		}
		
		public function get param():Object{
			return _params;
		}

	}
	
}
