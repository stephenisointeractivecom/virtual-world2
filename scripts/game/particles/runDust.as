﻿package scripts.game.particles{	import flash.display.Sprite;	import flash.events.*;	import flash.display.Stage;	import flash.geom.Point;	import flash.display.BitmapData;	import flash.geom.Rectangle;	//	public class runDust extends Sprite {		private var pRoot:Object = null;		private var pRoomObj:Object = null;		private var pAvatar:Object = null;		private var pState:int = 1;		private var x1:Number = 0;		private var y1:Number = 0;		private var dx:Number = 0;		private var dy:Number = 0;		private var wh:int = 1;		private var regPnt:Point = new Point(0, 0);		private var pRect:Rectangle = null;		//		public function runDust():void {		}		//		public function init(vRoot:Object, vRoomObj:Object, vAvatar:Object, vx1:int,vy1:int):void {			pRoot = vRoot;			pRoomObj = vRoomObj;			pAvatar = vAvatar;			var bmd:BitmapData = pRoot.pSpriteSheets.pRunDust[0];			pRect = bmd.rect;			x1 = vx1 + pRoot.rand()*5;			y1 = vy1 - pRoot.rand()*15;			dx = (pRoot.rand() - pRoot.rand())* .5;			dy = (pRoot.rand())* -1.5;		}		//		public function enterframe():void {			x1 = x1 + dx;			y1 = y1 + dy;			wh++;			if (wh < 40) {				if (pState == 0) {					return;				}				var bmd:BitmapData = pRoot.pSpriteSheets.pRunDust[wh];				var pnt:Point= new Point (Math.round(x1), Math.round(y1));				pRoomObj.blitSprite(bmd, pRect, pnt);			} else {				deleteMe();			}		}		//		public function deleteMe():void {			pAvatar.removeSpriteEffect(this);			pRoot = null;			pRoomObj = null;			pAvatar = null;			pSheetArray = null;			pState = 0;			wh = 0;			regPnt = null;			pRect = null;		}		//	}}//