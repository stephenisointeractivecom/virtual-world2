﻿package scripts.game.sound{	import flash.display.*;	import flash.events.*;	import flash.display.Sprite;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundTransform;	import flash.utils.getDefinitionByName;	import flash.display.Stage;	public class sceneSoundEmitter extends Sprite {		private var pRoot:Object;		private var pRoomObj:Object = null;		private var pName:String = "";		private var pSoundName:String = "";		private var pSound:Sound;		private var pTrans:SoundTransform = new SoundTransform();		private var pChan:SoundChannel;		private var pCycle:int = 0;		private var x1:int = 0;		private var y1:int = 0;		private var pRange:int = 2000;		private var pVolumeReducer:Number = 1;		//		public function sceneSoundEmitter():void{					}		//		public function init(vRoot:Object, vRoomObj:Object, vLayer:Object, pSwfTarget):void {			trace("sound emitter init");			this.visible = false;			pRoot = vRoot;			x1 = this.x;			y1 = this.y;			pName = this.name;			var nameArray = pName.split("_");			pSoundName = nameArray[1];			pRange = parseInt( nameArray[2]);			pVolumeReducer = (parseInt(nameArray[3]))/100;			var c:Class = pSwfTarget.applicationDomain.getDefinition(pSoundName) as Class;			pSound = new c() as Sound;			pTrans.volume = 0;			var r:int = Math.random() * 1000;			pChan = pSound.play(r,999999);			pChan.soundTransform = pTrans;		}		//		public function enterframe():void {			pCycle++;			if (pCycle > 15) {				pCycle = 0;				var x2:int = pRoot.pMyAvatar.x1;				var distX:int = x1 - x2;				if (distX < 2000) {					var y2:int = pRoot.pMyAvatar.y1;					var distY:int = y1 - y2;					var dist:int = Math.sqrt(distX * distX + distY * distY);					var vol:Number = (pRange - dist) / pRange;					if (vol<0) {						vol = 0;					}					vol = vol * pVolumeReducer;					pTrans.volume = vol;					pChan.soundTransform = pTrans;				}			}		}		//		public function deleteMe():void {			pChan.stop();			pRoot = null;			pSound = null;			pTrans = null;			pChan = null;			pCycle = 0;			pState = -1;		}		//	}}