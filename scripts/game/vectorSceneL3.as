﻿package scripts.game{	import flash.display.Sprite;	import flash.events.*;	import flash.display.Stage;	import flash.geom.Point;	import flash.display.BitmapData;	import flash.geom.Rectangle;	//	public class vectorSceneL3 extends Sprite {		private var pRoot:Object = null;		private var pRoomObj:Object = null;		private var pState:int = 1;		//		public function vectorSceneL3():void {			trace("vectorSceneL3 init");		}		//		public function init(vRoot:Object, vRoomObj:Object, vLayerObj:Object, vSwfTarget):void {			pRoomObj = vRoomObj;		}		//		public function enterframe():void {					}		//;		public function deleteMe():void {			if (pState !=-1) {				pRoot = null;				pRoomObj = null;				pState = -1;				if (parent) {					parent.removeChild(this);				}			}		}		//	}}//