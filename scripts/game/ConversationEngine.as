package scripts.game {
	/**
	 * ...
	 * @author Stephen Synowsky
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import mx.utils.ObjectUtil;
	import scripts.Events.ConversationEngineEvent;
	
	public class ConversationEngine extends MovieClip {
		var ws:WebService = new WebService;
		var wsObj:Object = new Object();
		var firstQuestionID:uint = 1;

		public function ConversationEngine () {
			ws.wsdl = 'http://ec2-23-21-121-27.compute-1.amazonaws.com/TidesWS/ConversationEngine.svc?wsdl';
			ws.useProxy = false;
			ws.addEventListener(ResultEvent.RESULT, questionHandler);
			ws.addEventListener(FaultEvent.FAULT, wsFailure);
			if (ws.canLoadWSDL())
				ws.loadWSDL();
			else
				trace('There was an error with WSDL');
		}
		
		private function questionHandler (re:ResultEvent) {
			trace('ResultEvent ' + ObjectUtil.getClassInfo(re.result).properties);
			
			if (re.result == null)
			{
				dispatchEvent(new Event("EndQuest"));
				return;
			}
			var xml:XML;
            xml = new XML(re.message.body.toString());
            trace(xml.child(0).child(0).name().localName);
			
			var ev:ConversationEngineEvent = null;
			switch(xml.child(0).child(0).name().localName)
			{
                case "GetQuestByQuestNameResponse":
                {
                    ev = new ConversationEngineEvent("questId");
                    ev.questId = re.result.QuestId;
                    dispatchEvent(ev);
                    break;
                }
                case "SaveUserResponseResponse":
                {
					trace('UserID Is: ' + re.result.UserId);
					wsObj.UserId = re.result.UserId;
					ws.GetNextQuestion(firstQuestionID);
					break;
                }
                case "GetFirstQuestionResponse":
                case "GetNextQuestionResponse":
                case "GetQuestionByIdResponse":
                case "SaveUserResponseAndGetNextQuestionResponse":
                {
                    ev = new ConversationEngineEvent("nextQuestion");
                    ev.questionId = re.result.QuestionId;
                    ev.questName = re.result.QuestName;
                    ev.questionText = re.result.QuestionText;
                    ev.possibleAnswers = re.result.PossibleAnswers;
                    trace("ResultEvent " + ObjectUtil.getClassInfo(ev.possibleAnswers).properties);
                    trace(re.result.QuestionType);
                    ev.questionType = re.result.QuestionType;
                    ev.questId = re.result.QuestId;
                    dispatchEvent(ev);
                    break;
                }
                default:
                {
                    break;
                }
            }
            return;
        }
		
		private function wsFailure (fe:FaultEvent) {
			trace('FaultEvent ' + fe);
		}
		
		public function getFirstQuestion (i:uint, x:uint) {
			ws.GetFirstQuestion(i,x);
		}
		
		public function saveAnswer (s1:String) {
			trace('[saveAnswer] ' + s1);
			wsObj.AnswerText = s1;
			ws.SaveUserResponse(wsObj);
		}
		
		public function saveAnswerAndGetNextQuestion (s1:String) {
			wsObj.AnswerText = s1;
			ws.SaveUserResponseAndGetNextQuestion(wsObj);
		}		
		
		public function getQuestByQuestName (i:String) {
			ws.GetQuestByQuestName(i);
		}
        public function getNextQuestion(i:uint) {
            ws.GetNextQuestion(i);
        }
        public function getQuestion(i:uint) {
            ws.GetQuestionById(i);
        }
		public function setUserId (i:uint) {
			wsObj.UserId = i;
		}
		
		public function setSessionId (i:String) {
			wsObj.SessionId = i;
		}
		
		public function setQuestionId (i:uint) {
			wsObj.QuestionId = i;
		}
	}
}
