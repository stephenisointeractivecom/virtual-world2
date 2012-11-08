package scripts.Events {
	import flash.events.Event;
	/**
	 * ...
	 * @author Stephen Synowsky
	 */
	public class ConversationEngineEvent extends Event {
		public static var NEXT_QUESTION:String = 'nextQuestion';
		public static var QUEST_ID:String = 'questId';
		public static var SESSION_ID:String = 'sessionId';
		public static var USER_ID:String = 'userId';
		private var _questionId:uint;
		private var _sessionId:String;
		private var _questionText:String;
		private var _questId:uint;
		private var _possibleAnswers:Object;
        private var _questionType:String;
        private var _questName:String;
		private var _userId:uint;
		public function get questionId():uint { return _questionId; }
		public function set questionId(i:uint) { _questionId = i; }
		public function get sessionId():String { return _sessionId; } 
		public function set sessionId(i:String) { _sessionId = i; }
		public function get questionText():String { return _questionText; }
		public function set questionText(s:String) { _questionText = s; }
		public function get questId():uint { return _questId; }
		public function set questId(i:uint) { _questId = i; }
		public function get possibleAnswers():Object { return _possibleAnswers; }
        public function set possibleAnswers(i:Object) { _possibleAnswers = i; }
        public function get questionType():String { return _questionType; }
        public function set questionType(i:String) { _questionType = i; }
        public function get questName():String { return _questName; }
        public function set questName(i:String) { _questName = i; }
		public function get userId():uint { return _userId; }
		public function set userId(i:uint) { _userId = i; }
		
		public function ConversationEngineEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}