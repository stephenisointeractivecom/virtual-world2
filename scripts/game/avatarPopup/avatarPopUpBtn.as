﻿package scripts.game.avatarPopup{	import flash.display.*;	import flash.events.*;	import flash.display.MovieClip;	import flash.display.Stage;	//	public class avatarPopUpBtn extends MovieClip {		private var pBtnNme:String = "";		//		public function avatarPopUpBtn():void {			addEventListener(MouseEvent.MOUSE_DOWN,mousedown);			addEventListener(MouseEvent.ROLL_OVER,rollover);			this.addEventListener(MouseEvent.ROLL_OUT,rollout);			pBtnNme = this.name;			stop();		}		private function rollover(evt:MouseEvent):void {			this.gotoAndStop(2);		}		private function rollout(evt:MouseEvent):void {			this.gotoAndStop(1);		}		//		private function mousedown(evt:MouseEvent):void {			if (root) {				switch (pBtnNme) {					case "addBuddyBtn" :						//root.toggleSceneInterface();						break;					case "privateChatBtn" :						//root.closeModMsgWindow();						break;				}			}			//		}	}}