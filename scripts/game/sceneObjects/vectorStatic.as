﻿package scripts.game.sceneObjects{	import flash.display.Sprite;	import flash.events.*;	import flash.display.Stage;	import flash.geom.Point;	import flash.display.BitmapData;	import flash.geom.Rectangle;	//	public class vectorStatic extends Sprite {		private var pRoot:Object = null;		private var pRoomObj:Object = null;		private var pState:int = 1;		//		public function vectorStatic():void {		}		//		public function init(vRoot:Object, vRoomObj:Object, vLayerObj:Object, vSwfTarget):void {			pRoomObj = vRoomObj;		}		//		public function enterframe():void {			var onScreen:Boolean = pRoomObj.pointOnScreen(this.x, this.y);			if (onScreen){				this.visible = true;			}else{				this.visible = false;			}		}		//;		public function deleteMe():void {			if (pState !=-1) {				pRoot = null;				pRoomObj = null;				pState = -1;				if (parent) {					parent.removeChild(this);				}			}		}		//	}}//