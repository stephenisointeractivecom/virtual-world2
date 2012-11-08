package scripts.game
{
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;	
	import mx.utils.ObjectUtil;
	
	import scripts.game.ConversationEngine;
	import scripts.Events.ConversationEngineEvent;
	
	import com.smartfoxserver.v2.entities.data.*;		
	import com.smartfoxserver.v2.requests.*;
	
	public class npcSystem extends MovieClip 
	{
		// Convo Eng Vars
		private var convoEng:ConversationEngine;
		private var sessionID:String;
		//User Vars
		private var userName:String;
		private var myQuests:ISFSArray = null;
		private var Quests:SFSArray = null;
		private var NPC:int;
		// Question Vars		
		private var curQuestion:uint;
		private var curQuest:uint = 0;
		private var curPossibleAnswers:Object;
		private var curPossAnSize:uint;
		private var curQuestionType:String;
		private var availableQuest:uint = 0;
		//
		private var kd:Boolean = false;
		private var canEnter:Boolean = false;	
		private var textSpeed:uint = 50;
		private var curSelection:uint = 0;
		private var correctAnswer:uint = 0;
		private var doAQuest:Boolean = false;
		//
		private var pRoot:Object = null;
		
		public function init(vRoot:Object)
		{						
			//Grab info from main.as
			pRoot = vRoot;
			myQuests = pRoot.pMyQuestProgress;
			//// REPLACE 5 W/THE NPC YOUR INTERACTING WITH //////
			NPC = 5;
			//////////////////////////////////////////////////
			sessionID = pRoot.smartFox.sessionToken;
			userName = pRoot.gUserName;
			Quests = pRoot.pQuests;
			
			//set up feedback attr for system
			AnswerBox.visible = false;
			AnswerBar.visible = false;
			
			C1.borderColor = 0x154071;
			C2.borderColor = 0x154071;
			C3.borderColor = 0x154071;
			C4.borderColor = 0x154071;
			
			EntToCont.visible = false;
			EscToExt.visible = false;
			
			//initalize convo engine and add listeners
			convoEng = new ConversationEngine();
			convoEng.setSessionId(sessionID);
			convoEng.addEventListener('EndQuest', endQuest);
			convoEng.addEventListener(ConversationEngineEvent.NEXT_QUESTION, nextQuestion);
			convoEng.addEventListener(ConversationEngineEvent.QUEST_ID, nextQuest);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener("returnUpdateQuestProgress", getUpdateQuestProgress);
			
			//iterate through User's Quest Progress to see if a quest should be continued
			for (var i = 0; i < myQuests.size(); i++)
			{
				if (myQuests.getSFSObject(i).getInt("IsQuestCompleted") == 0 && myQuests.getSFSObject(i).getInt("NPC_NPCId") == NPC)
				{
					curQuest = myQuests.getSFSObject(i).getInt("Quest_idQuest");
					if (myQuests.getSFSObject(i).containsKey("Question_idQuestion"))
					{
						if (completedTask(myQuests.getSFSObject(i).getUtfString("QuestName")))
							convoEng.getNextQuestion(myQuests.getSFSObject(i).getInt("Question_idQuestion"));
					}
					else
						convoEng.getFirstQuestion(NPC, curQuest);
				}
			}
			//if no current quest to continue, check to see if one is available based on last Quest the user completed 
			//and all Quests' parent Quest
			if (curQuest == 0)
			{
				checkQuestAvailable();
			}
			//if neither of above, get basic question from convo eng
			if (curQuest == 0 && availableQuest == 0)
			{
				convoEng.getFirstQuestion(NPC, curQuest);
			}
		}
		public function npcSystem() 
		{
			
		}
		private function nextQuestion(event:ConversationEngineEvent):void
		{
			// main return point from convo engine
			
			//save variables of question/text
			curQuestion = event.questionId;
			curPossibleAnswers = event.possibleAnswers;
			curPossAnSize = curPossibleAnswers.length;
			curQuest = event.questId;
			curQuestionType = event.questionType;
			QuestTitle.text = event.questName;
			
			var str:String = event.questionText;
			
			//set text typing test
			textSpeed = 50;
			
			//curQuest == 0 means its not really a quest but a basic question
			if (curQuest == 0)
			{
				//dont display quest text and replace the * with the username 
				//changes Hey *!!! to Hey test1!!!
				QuestTitle.text = "";
				str = str.replace("*", userName);
			}
			
			//send question text to animate 
			animateDialogue("QuestionText",str, 0, 0);
		}
		private function nextQuest(event:ConversationEngineEvent):void
		{
			
		}
		private function onKeyDown(event:KeyboardEvent):void
		{
			var key = event.keyCode;
			if (key == 13 && !kd && canEnter) //Enter key - submit
			{
				kd = true; //set to say enter key is down
				canEnter = false; //stops multiple submits
				trace("enter down");
			}
			else if (key == 13 && !canEnter)//Enter key - speed text
			{
				textSpeed = 0; //speeds up text animation
			}
			else if (key == 38 && canEnter)//Up Arrow - change selections
			{
				//turn off border of current selection
				var cmdU:String = "C" + curSelection;
				this[cmdU].border = false;
				
				//move selection
				curSelection--;
				if (curSelection <= 0)
					curSelection = curPossAnSize;
				
				//turn on border of current selection
				cmdU = "C" + curSelection;
				this[cmdU].border = true;
			}
			else if (key == 40 && canEnter)//Down Arrow - change selections
			{
				//turn off border of current selection
				var cmdD:String = "C" + curSelection;
				this[cmdD].border = false;
				
				//move selection
				curSelection++;
				if (curSelection > curPossAnSize)
					curSelection = 1;
				
				//turn on border of current selection
				cmdD = "C" + curSelection;
				this[cmdD].border = true;
			}	
			else if (key == 27) //ESC - exit npc system
			{
				ExitNPC();
			}
		}
		private function onKeyUp(event:KeyboardEvent):void
		{
			var key = event.keyCode;
			if (key == 13 && kd) //Enter - choose answer
			{
				//set key to up
				kd = false;
				trace("enter up");
				
				if (curQuest != 0) //curQuest is an actual quest
				{
					if (curQuestionType != "Text") //there are answers
					{
						if (curSelection == correctAnswer)
							CorrectAnswer();
						else
							WrongAnswer();
					}
					else //plain text, no answers 
					{
						clearScreen(); //prepare screen for next Q
						UpdateQuestProgress(); //update Quest Progress with current question, so user does not have to repeat steps of quest
						convoEng.getNextQuestion(curQuestion); //get next question of quest
					}
				}
				else if (curQuestionType == "Multiple Choice") //curQuest == 0, and question has multi answers
				{
					switch (curSelection)
					{
					case 1: //Do a Quest
						{
							//Get up to date Quest Progress
							var obj:ISFSObject = new SFSObject();
							obj.putUtfString("cmd2", "UpdateQuest");
							pRoot.smartFox.send(new ExtensionRequest("get", obj));
							doAQuest = true;
							break;
						}
					case 2: //Quiz
						{
							break;
						}
					case 3: //Poll
						{
							break;
						}
					case 4:	//Exit		
						{
							ExitNPC();
							break;
						}
					}
				}
				else if (curQuestionType == "YesNo") //curQuest == 0, used to ask if player would like to play an available quest
				{
					if (curSelection == 1) //Yes
						playQuest(); //play available quest
					else //No	
					{
						clearScreen(); //prepare screen for next question
						convoEng.getFirstQuestion(0, 0); //get basic question
					}
				}
				else
				{
					clearScreen(); //prepare screen for next question
					convoEng.getFirstQuestion(0, 0); //get basic question
				}
			}
		}
		private function animateDialogue (txtBox:String, s:String, i:uint, x:uint) 
		{
			//function is used to animate display of dialogue and set up answers
			//function is used recursevily
			if (i == 0) //first time called
			{
				this[txtBox].text = ''; //reset text of textfield
				canEnter = false; //stop user from submiting
			}
			if (i < s.length) //while current word is still typing out
			{
				this[txtBox].appendText(s.charAt(i)); //append cur letter
				i++; //increase i
				setTimeout(animateDialogue, textSpeed, txtBox, s, i, x); //resend function call
			}
			else //current word done typing, check for possible answers to type
			{
				if (curPossAnSize != 0) //answers are available
				{
					if (x < curPossAnSize) //loop through answers while less than total possible answers
					{
						var obj:Object = curPossibleAnswers.list.getItemAt(x); //get possible answer object
						var cmd:String = "C" + (x + 1); //string for name of textfield ex: C1
						var str:String = (x + 1) + "). " + obj.PossibleAnswerText; //string for text of answer
						if (obj.CorrectAnswer) //checks to see if cur answer is the correct answer for the question
							correctAnswer = (x + 1); //set variable = to number relative to textfields
						x++; //increase x, used to go to next answer on next loop 
						setTimeout(animateDialogue, textSpeed, cmd, str, 0, x); //
						//trace('--> ' + ObjectUtil.getClassInfo(obj).properties);
					}
					else if (curQuest == 0 && x == curPossibleAnswers.length) //used to add Exit option to basic question
					{
						cmd = "C" + (x + 1); //set the textfield
						str = (x + 1) + "). Bye!!"; //set the string
						x++; // increase x
						curPossAnSize++; // increase the possible answer size to be able to select choice
						setTimeout(animateDialogue, textSpeed, cmd, str, 0, x); //recall function
					}
					else
					{
						//turn on border and set cur selection to 1
						C1.border = true;
						C1.borderColor = 0x154071;
						curSelection = 1;
						canEnter = true;
						textSpeed = 50;
					}					
				}
				else if (curQuestionType == "YesNo") //for Yes No, not using convo engine possible answers
				{
					if (x == 0) //set up yes
					{
						x++;
						setTimeout(animateDialogue, textSpeed, "C1", "Yes", 0, x);
					}
					else if (x == 1)//set up no
					{
						x++;
						setTimeout(animateDialogue, textSpeed, "C2", "No", 0, x);
					}
					else
					{
						//turn on border and set curselection
						C1.border = true;
						C1.borderColor = 0x154071;
						curSelection = 1;
						curPossAnSize = 2;
						canEnter = true;
						textSpeed = 50;
					}					
				}
				else //no answers, used for text or no wrong answer questions
				{
					if (curQuestionType == "Open Ended")//no wrong answer
					{			
						clearAnswerFeedback();
						//turn on answer bar
						AnswerBox.visible = true;
						AnswerBar.visible = true;
					}
					else if (curQuestionType == "Text")
					{
						clearAnswerFeedback();
						EntToCont.visible = true;
					}
					canEnter = true;
					textSpeed = 50;
				}				
			}
		}	
		private function animateStaticText (s:String, i:uint) //used to animate text not coming from convo engine
		{
			//runs similar to animate dialogue, without answers
			if (i == 0)
			{
				QuestionText.text = '';
				canEnter = false;
			}
			if (i < s.length) 
			{
				QuestionText.appendText(s.charAt(i));
				i++;
				setTimeout(animateStaticText, textSpeed, s, i);
			}
			else 
			{
				textSpeed = 50;
			}
		}
		private function endQuest(event:Event) //called from convo engine if question returned = null
		{
			QuestionText.text = '';
			QuestTitle.text = '';
			
			//set current quest to finished through extension call
			var obj:ISFSObject = new SFSObject();
			obj.putUtfString("cmd2", "FinishedQuest");
			obj.putInt("questId", curQuest);
			pRoot.smartFox.send(new ExtensionRequest("set", obj));
			
			for (var i = 0; i < myQuests.size(); i++)//update local copy or user quest progress
			{
				//trace(curQuest);
				//trace(myQuests.getDump());
				if (myQuests.getSFSObject(i).getInt("Quest_idQuest") == curQuest)
				{
					myQuests.getSFSObject(i).putInt("IsQuestCompleted", 1);
					trace(myQuests.getSFSObject(i).getDump());
					break;
				}
			}
			
			convoEng.getFirstQuestion(0, 0); //get basic question
		}
		private function clearScreen() //called to clear textfields
		{
			QuestTitle.text = "";
			QuestionText.text = "";
			C1.text = "";
			C2.text = "";
			C3.text = "";
			C4.text = "";
			EntToCont.visible = false;
			EscToExt.visible = false;
			
			clearAnswerFeedback();
		}
		private function clearAnswerFeedback() //called to clear answer properties
		{
			AnswerBox.visible = false;
			AnswerBar.visible = false;
			C1.border = false;
			C2.border = false;
			C3.border = false;
			C4.border = false;	
		}
		private function UpdateQuestProgress() //called to update quest progress in database, done by sending current question the user finished
		{
			trace("UpdateQuestProgress");
			var obj:ISFSObject = new SFSObject();
			obj.putUtfString("cmd2", "UpdateQuest");
			obj.putInt("questId", curQuest);
			obj.putInt("questionId", curQuestion);
			pRoot.smartFox.send(new ExtensionRequest("set", obj));
		}
		public function getUpdateQuestProgress() //called by main.as when extension response is recieved from the request of updated quest progress
		{
			trace("getUpdateQuestProgress");
			myQuests = pRoot.pMyQuestProgress; //get up to date progress
			checkQuestAvailable(); //check if a quest is available
		}
		private function CorrectAnswer() //called if user chose the correct answer
		{
			clearScreen();
			animateStaticText("Thats the correct answer!! Way to go!!!", 0); //animate text

			UpdateQuestProgress(); //update progress
			setTimeout(convoEng.getNextQuestion, 3000, curQuestion); //3000 = 3 sec, time to type out above string
			//setTimeout(convoEng.saveAnswerAndGetNextQuestion, 1000, curPossibleAnswers.list.getItemAt(correctAnswer-1).PossibleAnswerText);
		}
		private function WrongAnswer() //called if user chose the wrong answer
		{
			clearScreen();
			animateStaticText("I'm sorry but that is not the correct answer. Please try again.", 0);//animate text
			
			setTimeout(convoEng.getQuestion, 4100, curQuestion); //4100, time to type out above string
		}
		private function ExitNPC() //called to leave this system
		{
			var obj:ISFSObject = new SFSObject();
			obj.putUtfString("cmd2", "UpdateQuest");
			pRoot.smartFox.send(new ExtensionRequest("get", obj)); //called to update progress so on next enter to system, info is up to date
			removeEventListener("returnUpdateQuestProgress", getUpdateQuestProgress);
			dispatchEvent(new Event("Exit",true)); //dispatched for a event main.as is listening for
		}
		private function checkQuestAvailable() //called to see if quest is available to be played
		{
			trace("checkQuestAvailable: started");
			for (var x = 0; x < Quests.size(); x++)
			{
				if (Quests.getSFSObject(x).containsKey("Parent_idQuest"))
				{
					if (myQuests.getSFSObject(myQuests.size() - 1).getInt("Quest_idQuest") == Quests.getSFSObject(x).getInt("Parent_idQuest") 
							&& Quests.getSFSObject(x).getInt("NPC_NPCId") == NPC)
					{
						trace("checkQuestAvailable: quest found");
						if (completedQuestTriggers(Quests.getSFSObject(x).getUtfString("QuestName")))
						{
							//found available quest
							clearScreen();
							convoEng.getQuestion(22); //ask if they would like to play it
						
							availableQuest = Quests.getSFSObject(x).getInt("idQuest"); //set to use if they yes
							return;
						}								
					}
				}					
			}
			if (doAQuest)
			{
				clearScreen();
				convoEng.getQuestion(23); 
				doAQuest = false;
			}
			trace("checkQuestAvailable: done");  
		}
		private function playQuest() //called if they chose to play the quest
		{
			var obj:ISFSObject = new SFSObject();
			obj.putInt("questId", availableQuest);
			obj.putUtfString("cmd2", "InsertQuest");
			pRoot.smartFox.send(new ExtensionRequest("set", obj)); //insert newly started quest into progress table
			
			clearScreen();
			convoEng.getFirstQuestion(NPC, availableQuest); //get first question of quest
		}
		private function completedTask(quest:String):Boolean //called before going to next question in quest, place specific functionality here
		{
			trace("completedTask: " + quest);
			switch(quest)
			{
				case "The Rush":
					{
						var dustTotal:int = pRoot.gUserDustCounts[0] + pRoot.gUserDustCounts[1] + pRoot.gUserDustCounts[2];
						if (dustTotal >= 3)
						{
							trace("returned true: " + dustTotal);
							return true;
						}
						animateStaticText("You must go find 3 motes and come back, Hurry!!!", 0);
						EscToExt.visible = true;
						trace("returned false");
						return false;
					}
				case "One to Three":
				case "Timing is Everything":				
			}
			trace("returned true");
			return true;
		}
		private function completedQuestTriggers(quest:String):Boolean //called before starting new quest, place specific functionality here
		{
			trace("completedQuestTriggers");
			switch(quest)
			{
				case "The Rush":
				case "One to Three":
				case "Timing is Everything":				
			}
			return true;
		}
	}	
}