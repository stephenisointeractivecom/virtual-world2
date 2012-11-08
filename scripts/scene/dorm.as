﻿package {	import com.greensock.TweenMax;	import com.greensock.plugins.ColorMatrixFilterPlugin;	import com.greensock.plugins.GlowFilterPlugin;	import com.greensock.plugins.TweenPlugin;	import flash.display.BitmapData;	import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.geom.Point;	import flash.utils.getDefinitionByName;	public class dorm extends MovieClip {		private var pRoot:Object;		public var pSceneAttributes:Object = new Object;		private var mcArr:Array;		private var menuLight:MovieClip = new MovieClip();		private var menuPlant:MovieClip = new MovieClip();		private var menuBasket:MovieClip = new MovieClip();		private var menu:String;		private var wallColor:uint = 1;		private var trimColor:uint = 1;		private var floorColor:uint = 1;		private var lastLight:uint = 1;		private var lastPlant:uint = 1;		private var lastBasket:uint = 1;		private var pBackdrop:Object = null;		private var pMenu:Object = null;		private var pCloseBtn:Object = null;		//		public function dorm() {			trace('dorm construct');			pBackdrop = this.L2_interactive.dorm.bg;			pMenu = this.L2_interactive.dorm.menu_mc;			pCloseBtn =  this.L2_interactive.dorm.close_btn;			stopAllRoomObjects();			setUpMenus();		}		//		public function init(vRoot:Object) {			trace('[DormRoom: init]');			setSceneAttributes();			pRoot = vRoot;			pRoot.getDormRoomInfo();			setUpMenus();			stopAllRoomObjects();			TweenPlugin.activate([ColorMatrixFilterPlugin, GlowFilterPlugin]);		}		//;		private function setSceneAttributes():void {			var pRetroParralax:Boolean = false;			var pMoonsActive:Boolean = true;			var pAvatarFront:Boolean = true;			var pAvatarLim_dx:int = 30;			var pAvatarLim_dy:int = 30;			var pGravity:Number = .5;			var pAvatarSize:Number = 1.2;			var pAvatarSilhouetteClr:uint = 0x000033;			var pAvaSilClrAmount:int = 80;			var pAvatarLayerArray:Array = [[0,1,true]];			var pReflectionArray:Array = null;			pSceneAttributes.pAvatarFront = pAvatarFront;			pSceneAttributes.pAvatarLim_dx = pAvatarLim_dx;			pSceneAttributes.pAvatarLim_dy = pAvatarLim_dy;			pSceneAttributes.pGravity = pGravity;			pSceneAttributes.pAvatarSize = pAvatarSize;			pSceneAttributes.pAvatarSilhouetteClr = pAvatarSilhouetteClr;			pSceneAttributes.pAvaSilClrAmount = pAvaSilClrAmount;			pSceneAttributes.pReflectionArray = pReflectionArray;			pSceneAttributes.pAvatarLayerArray = pAvatarLayerArray;			pSceneAttributes.pMoonsActive = pMoonsActive;			pSceneAttributes.pRetroParralax = pRetroParralax;			pSceneAttributes.pVectorScene = true;		}		//;		private function stopAllRoomObjects():void {			mcArr = new Array(pBackdrop.lights_mc,pBackdrop.plant_mc,pBackdrop.basket_mc,pBackdrop.closet_btn,pBackdrop.border_mc,pBackdrop.wall_mc,pBackdrop.floor_mc,pBackdrop.table_mc);			for (var i:uint = 0; i < mcArr.length; i++) {				var mc:MovieClip = mcArr[i];				mc.stop();				mc.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);				mc.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);				mc.addEventListener(MouseEvent.CLICK, clickHandler);				mc.mouseChildren = false;				mc.buttonMode = true;			}		}		//		private function setUpMenus():void {			pMenu.gotoAndStop(1);			setUpMenu('light', menuLight);			setUpMenu('plant', menuPlant);			setUpMenu('basket', menuBasket);			pMenu.toggle_mc.mouseChildren = pMenu.visible = pMenu.menuColors.visible = false;			pMenu.addEventListener(MouseEvent.CLICK, clickHandler);			pCloseBtn.addEventListener(MouseEvent.CLICK, closeDorm);		}		//		public function setUpDormRoom(a:Array) {			trace('setUpDormRoom');			//trace(a);			wallColor = a[0];			pBackdrop.wall_mc.gotoAndStop(wallColor);			trimColor = a[1];			pBackdrop.border_mc.gotoAndStop(trimColor);			pBackdrop.table_mc.gotoAndStop(trimColor);			floorColor = a[2];			pBackdrop.floor_mc.gotoAndStop(floorColor);			if (a[4] == pBackdrop.lights_mc.totalFrames)				pBackdrop.lights_mc.alpha = 0;			pBackdrop.lights_mc.gotoAndStop(a[4]);			if (a[5] == pBackdrop.plant_mc.totalFrames)				pBackdrop.plant_mc.alpha = 0;			pBackdrop.plant_mc.gotoAndStop(a[5]);			if (a[6] == pBackdrop.basket_mc.totalFrames)				pBackdrop.basket_mc.alpha = 0;			pBackdrop.basket_mc.gotoAndStop(a[6]);		}		//;		public function setUpQuestItems(a:Array) {			trace('setUpQuestItems');			for (var i:uint = 0; i < a.length; i++) {				pBackdrop.getChildByName('reward' + a[i] + '_mc').visible = true;			}		}		//adds items to menu dynamically for the lights, plants and baskets based on items in the library		private function setUpMenu(s:String, mc:MovieClip) {			for (var i = 1; i < 100; i++) {				try {					i < 10 ? addMenuItem(getDefinitionByName(s + '0' + i) as Class) : addMenuItem(getDefinitionByName(s + i) as Class);				} catch (e:Error) {					i = 100;				}			}			pMenu.addChild(mc);			mc.visible = false;		}		private function addMenuItem(c:Class) {			var mc:SimpleButton = new c();			var l:uint = c.toString().length;			var s:String = c.toString().slice(l - 3, l - 1);//the number at the end of the class name			var t:uint = (Number(s) - 1) % 3;			switch (t) {//position the x of the movieclip				case 0 :					mc.x = (35 - mc.width) / 2 + 5;					break;				case 1 :					mc.x = (35 - mc.width) / 2 + 40;					break;				case 2 :					mc.x = (35 - mc.width) / 2 + 75;					break;			}			t = (Number(s) - 1) / 3;			switch (t) {//position the y of the movieclip				case 0 :					mc.y = (45 - mc.height) / 2 + 5;					break;				case 1 :					mc.y = (45 - mc.height) / 2 + 50;					break;				case 2 :					mc.y = (45 - mc.height) / 2 + 95;					break;			}			s = c.toString().slice(7,l - 3);//get the type in the name of the movieclip			switch (s) {				case 'light' :					menuLight.addChild(mc);					break;				case 'plant' :					menuPlant.addChild(mc);					break;				case 'basket' :					menuBasket.addChild(mc);					break;			}		}		//		private function removeClicks() {			for (var i:uint = 0; i < mcArr.length; i++) {				var mc:MovieClip = mcArr[i];				mc.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);				mc.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);				mc.removeEventListener(MouseEvent.CLICK, clickHandler);			}		}		//		private function addClicks() {			for (var i:uint = 0; i < mcArr.length; i++) {				var mc:MovieClip = mcArr[i];				mc.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);				mc.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);				mc.addEventListener(MouseEvent.CLICK, clickHandler);			}		}		//		private function rollOverHandler(e:MouseEvent) {			if (e.target.alpha == 0) {//show 'empty' frame				TweenMax.to(e.target, .25, { colorMatrixFilter: { brightness:2.8 }, glowFilter: { alpha:50, blurX:15, blurY:15, strength:1.5 } } );				e.target.alpha = 100;			} else if (e.target.name == 'closet_btn' || e.target.name == 'lights_mc' || e.target.name == 'plant_mc' || e.target.name == 'basket_mc') {				TweenMax.to(e.target, .25, { colorMatrixFilter: { brightness:1.5 }, glowFilter: { alpha:50, blurX:15, blurY:15, strength:1.5, color:0xffffff } } );			} else {				trace(e.target.name + ' ' + e.target.currentFrame);				if (e.target.name == 'border_mc') {					pBackdrop.table_mc.gotoAndStop(pBackdrop.table_mc.currentFrame + 1);				} else if (e.target.name == 'table_mc') {					pBackdrop.border_mc.gotoAndStop(pBackdrop.border_mc.currentFrame + 1);				}				e.target.gotoAndStop(e.target.currentFrame + 1);			}		}		//		private function rollOutHandler(e:MouseEvent) {			if (e.target.currentFrame == e.target.totalFrames && (e.target.name != 'border_mc' && e.target.name != 'wall_mc' && e.target.name != 'floor_mc' && e.target.name != 'table_mc'  && e.target.name != 'closet_btn')) {				e.target.alpha = 0;			} else if (e.target.name == 'closet_btn' || e.target.name == 'lights_mc' || e.target.name == 'plant_mc' || e.target.name == 'basket_mc') {				TweenMax.to(e.target, .25, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );			} else {				if (e.target.name == 'border_mc') {					pBackdrop.table_mc.gotoAndStop(pBackdrop.table_mc.currentFrame - 1);				} else if (e.target.name == 'table_mc') {					pBackdrop.border_mc.gotoAndStop(pBackdrop.border_mc.currentFrame - 1);				}				e.target.gotoAndStop(e.target.currentFrame - 1);			}		}		//		private function clickHandler (e:MouseEvent) {			trace(e.target.name);			if (e.target.name.toString().indexOf('instance') == -1 && e.target.name.toString().indexOf('color') == -1) {				if (!pMenu.visible) {					mouseX > 870 ? pMenu.x = 870 : pMenu.x = mouseX;					mouseY > 320 ? pMenu.y = 320 : pMenu.y = mouseY;				}				switch (e.target.name) {					case 'table_mc':					case 'border_mc': {						menu = 'border';						pMenu.menuColors.visible = pMenu.visible = true;						pMenu.toggle_mc.visible = false;						pMenu.menuColors.gotoAndStop(1);						pBackdrop.table_mc.gotoAndStop(pBackdrop.table_mc.currentFrame - 1);						pBackdrop.border_mc.gotoAndStop(pBackdrop.border_mc.currentFrame - 1);						removeClicks();					break; }					case 'lights_mc': {						menu = 'lights';						menuLight.visible = pMenu.visible = pMenu.toggle_mc.visible = true;						if (e.target.currentFrame != e.target.totalFrames)							pMenu.toggle_mc.check_mc.visible = true;						else {							pMenu.toggle_mc.check_mc.visible = false;							e.target.alpha = 0;						}						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );						removeClicks();					break; }					case 'plant_mc': {						menu = 'plant';						menuPlant.visible = pMenu.visible = pMenu.toggle_mc.visible = true;						if (e.target.currentFrame != e.target.totalFrames)							pMenu.toggle_mc.check_mc.visible = true;						else {							pMenu.toggle_mc.check_mc.visible = false;							e.target.alpha = 0;						}						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );						removeClicks();					break; }					case 'basket_mc': {						menu = 'basket';						menuBasket.visible = pMenu.visible = pMenu.toggle_mc.visible = true;						if (e.target.currentFrame != e.target.totalFrames)							pMenu.toggle_mc.check_mc.visible = true;						else {							pMenu.toggle_mc.check_mc.visible = false;							e.target.alpha = 0;						}						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );						removeClicks();					break; }					case 'wall_mc': {						menu = 'wall';						pMenu.menuColors.visible = pMenu.visible = true;						pMenu.toggle_mc.visible = false;						pMenu.menuColors.gotoAndStop(3);						e.target.gotoAndStop(e.target.currentFrame - 1);						removeClicks();					break; }					case 'floor_mc': {						menu = 'floor';						pMenu.menuColors.visible = pMenu.visible = true;						pMenu.toggle_mc.visible = false;						pMenu.menuColors.gotoAndStop(2);						e.target.gotoAndStop(e.target.currentFrame - 1);						removeClicks();					break; }					case 'close_menu_btn': {						if (menuLight.visible && (pBackdrop.lights_mc.currentFrame != pBackdrop.lights_mc.totalFrames || !pMenu.toggle_mc.check_mc.visible))							menuLight.visible = pMenu.visible = false;						else if (menuPlant.visible && (pBackdrop.plant_mc.currentFrame != pBackdrop.plant_mc.totalFrames || !pMenu.toggle_mc.check_mc.visible))							menuPlant.visible = pMenu.visible = false;						else if (menuBasket.visible && (pBackdrop.basket_mc.currentFrame != pBackdrop.basket_mc.totalFrames || !pMenu.toggle_mc.check_mc.visible))							menuBasket.visible = pMenu.visible = false;						else if (pMenu.menuColors.visible) {							pMenu.menuColors.visible = pMenu.visible = false;							pMenu.toggle_mc.visible = true;						}						addClicks();					break; }					case 'toggle_mc': {						e.target.check_mc.visible = !e.target.check_mc.visible;						switch (menu) {							case 'lights': {								if (pBackdrop.lights_mc.alpha == 0) {									pBackdrop.lights_mc.gotoAndStop(lastLight);									pBackdrop.lights_mc.alpha = 100;								}								else {									lastLight = pBackdrop.lights_mc.currentFrame;									pBackdrop.lights_mc.alpha = 0;									pBackdrop.lights_mc.gotoAndStop(pBackdrop.lights_mc.totalFrames);								}							break; }							case 'plant': {								if (pBackdrop.plant_mc.alpha == 0) {									pBackdrop.plant_mc.gotoAndStop(lastPlant);									pBackdrop.plant_mc.alpha = 100;								}								else {									lastPlant = pBackdrop.plant_mc.currentFrame;									pBackdrop.plant_mc.alpha = 0;									pBackdrop.plant_mc.gotoAndStop(pBackdrop.plant_mc.totalFrames);								}							break; }							case 'basket': {								if (pBackdrop.basket_mc.alpha == 0) {									pBackdrop.basket_mc.gotoAndStop(lastBasket);									pBackdrop.basket_mc.alpha = 100;								}								else {									lastBasket = pBackdrop.basket_mc.currentFrame;									pBackdrop.basket_mc.alpha = 0;									pBackdrop.basket_mc.gotoAndStop(pBackdrop.basket_mc.totalFrames);								}							break; }						}					break; }					case 'closet_btn':						updateDB();						pRoot.dormRoomLoadCloset();						break;				}			}			else { //in the menu				var l:uint = e.target.toString().length;				trace(e.target.toString().slice(8, l - 3));				switch (e.target.toString().slice(8, l - 3)) {					case 'light': {						pBackdrop.lights_mc.alpha = 100;						pBackdrop.lights_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));						pMenu.toggle_mc.check_mc.visible = true;					break; }					case 'plant': {						pBackdrop.plant_mc.alpha = 100;						pBackdrop.plant_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));						pMenu.toggle_mc.check_mc.visible = true;					break; }					case 'basket': {						pBackdrop.basket_mc.alpha = 100;						pBackdrop.basket_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));						pMenu.toggle_mc.check_mc.visible = true;					break; }					default: { //color						trace('menu ' + menu);						l = e.target.name.toString().length;						var frame:uint = e.target.name.toString().slice(l - 1, l) * 2 - 1;						switch(menu) {							case 'border': {								trimColor = frame;								pBackdrop.border_mc.gotoAndStop(frame);								pBackdrop.table_mc.gotoAndStop(frame);							break; }							case 'wall': {								wallColor = frame;								pBackdrop.wall_mc.gotoAndStop(frame);							break; }							case 'floor': {								floorColor = frame;								pBackdrop.floor_mc.gotoAndStop(frame);							break; }						}					break; }				}			}		}		//		private function closeDorm(e:MouseEvent):void {			updateDB();			pRoot.closeDormRoom();		}		//;		private function updateDB() {			var obj:Object = new Object();			obj.wallColor = wallColor;			obj.trimColor = trimColor;			obj.floorColor = floorColor;			obj.lights = pBackdrop.lights_mc.currentFrame;			obj.plants = pBackdrop.plant_mc.currentFrame;			obj.basket = pBackdrop.basket_mc.currentFrame;			pRoot.updateDormRoom(obj);		}		//		private function traceOut(txt:String){					}		//;		public function deleteMe() {			trace('[DormRoom: deleteMe]');			pRoot = null;			pSceneAttributes = null;			pBackdrop = null;			mcArr = [];			menuLight = null;			menuPlant = null;			menuBasket = null;			menu = null;			removeClicks();			pMenu.removeEventListener(MouseEvent.CLICK, clickHandler);			while (numChildren > 0) {				var mc:MovieClip = getChildAt(0) as MovieClip;				removeChildAt(0);			}		}	}}