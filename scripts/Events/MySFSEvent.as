package scripts.Events {
	import flash.events.Event;
	/**
	 * ...
	 * @author Stephen Synowsky
	 */
	public class MySFSEvent extends Event {
		public static var USERNAME_AVAILABLE:String = 'userNameAvailable';
		private var _avail:Boolean;
		public function get avail():Boolean { return _avail; }
		public function set avail(b:Boolean) { _avail = b; }

		public function MySFSEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}