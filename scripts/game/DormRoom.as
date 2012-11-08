package scripts.game {
	/**
	 * ...
	 * @author Stephen Synowsky
	 */
	import com.greensock.TweenMax;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	public class DormRoom extends MovieClip {
		private var world:Object;
		
		var mcArr:Array;
		var menuLight:MovieClip = new MovieClip();
		var menuPlant:MovieClip = new MovieClip();
		var menuBasket:MovieClip = new MovieClip();
		var menu:String;
		var wallColor:uint = 1;
		var trimColor:uint = 1;
		var floorColor:uint = 1;
		var lastLight:uint = 1;
		var lastPlant:uint = 1;
		var lastBasket:uint = 1;
		
		public function DormRoom() {
			trace('[DormRoom]');
			//if (stage) init(); //for local testing
			//else addEventListener(Event.ADDED_TO_STAGE, init); //for local testing
		}
		
		//private function init(e:Event = null):void { //for local testing
		public function init(w:Object) { //for in game
			//removeEventListener(Event.ADDED_TO_STAGE, init); //for local testing
			world = w; //for in game
			world.getDormRoomInfo(); //for in game
			trace('[DormRoom: init]');
			menu_mc.gotoAndStop(1);
			setUpMenu('light', menuLight);
			setUpMenu('plant', menuPlant);
			setUpMenu('basket', menuBasket);
			mcArr = new Array(bg.lights_mc, bg.plant_mc, bg.basket_mc, bg.closet_btn, bg.border_mc, bg.wall_mc, bg.floor_mc, bg.table_mc);
			for (var i:uint = 0; i < mcArr.length; i++) {
				var mc:MovieClip = mcArr[i];
				mc.stop();
				mc.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				mc.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				mc.addEventListener(MouseEvent.CLICK, clickHandler);
				mc.mouseChildren = false;
				mc.buttonMode = true;
			}
			menu_mc.toggle_mc.mouseChildren = menu_mc.visible = menu_mc.menuColors.visible = false;
			menu_mc.addEventListener(MouseEvent.CLICK, clickHandler);
			close_btn.addEventListener(MouseEvent.CLICK, function() {
				updateDB();
				world.closeDormRoom();
			});
			TweenPlugin.activate([ColorMatrixFilterPlugin, GlowFilterPlugin]);
		}
		
		public function setUpDormRoom(a:Array) {
			trace('setUpDormRoom');
			//trace(a);
			wallColor = a[0];
			bg.wall_mc.gotoAndStop(wallColor);
			trimColor = a[1];
			bg.border_mc.gotoAndStop(trimColor);
			bg.table_mc.gotoAndStop(trimColor);
			floorColor = a[2];
			bg.floor_mc.gotoAndStop(floorColor);
			if (a[4] == bg.lights_mc.totalFrames)
				bg.lights_mc.alpha = 0;
			bg.lights_mc.gotoAndStop(a[4]);
			if (a[5] == bg.plant_mc.totalFrames)
				bg.plant_mc.alpha = 0;
			bg.plant_mc.gotoAndStop(a[5]);
			if (a[6] == bg.basket_mc.totalFrames)
				bg.basket_mc.alpha = 0;
			bg.basket_mc.gotoAndStop(a[6]);
		}
		
		public function setUpQuestItems(a:Array) {
			trace('setUpQuestItems');
			for (var i:uint = 0; i < a.length; i++)
				bg.getChildByName('reward' + a[i] + '_mc').visible = true;
		}
		
		//adds items to menu dynamically for the lights, plants and baskets based on items in the library
		private function setUpMenu(s:String, mc:MovieClip) {
			for (var i = 1; i < 100; i++) {
				try {
					i < 10 ? addMenuItem(getDefinitionByName(s + '0' + i) as Class) : addMenuItem(getDefinitionByName(s + i) as Class);
				}
				catch (e:Error) {
					i = 100;
				}
			}
			menu_mc.addChild(mc);
			mc.visible = false;
		}
		
		private function addMenuItem (c:Class) {
			var mc:SimpleButton = new c();
			var l:uint = c.toString().length;
			var s:String = c.toString().slice(l - 3, l - 1); //the number at the end of the class name
			var t:uint = (Number(s) - 1) % 3;
			switch (t) { //position the x of the movieclip
				case 0:
					mc.x = (35 - mc.width) / 2 + 5;
					break;
				case 1:
					mc.x = (35 - mc.width) / 2 + 40;
					break;
				case 2:
					mc.x = (35 - mc.width) / 2 + 75;
					break;
			}
			t = (Number(s) - 1) / 3;
			switch (t) { //position the y of the movieclip
				case 0:
					mc.y = (45 - mc.height) / 2 + 5;
					break;
				case 1:
					mc.y = (45 - mc.height) / 2 + 50;
					break;
				case 2:
					mc.y = (45 - mc.height) / 2 + 95;
					break;
			}
			s = c.toString().slice(7, l - 3); //get the type in the name of the movieclip
			switch (s) {
				case 'light':
					menuLight.addChild(mc);
					break;
				case 'plant':
					menuPlant.addChild(mc);
					break;
				case 'basket':
					menuBasket.addChild(mc);
					break;
			}
		}
		
		private function removeClicks() {
			for (var i:uint = 0; i < mcArr.length; i++) {
				var mc:MovieClip = mcArr[i];
				mc.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				mc.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				mc.removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
		
		private function addClicks() {
			for (var i:uint = 0; i < mcArr.length; i++) {
				var mc:MovieClip = mcArr[i];
				mc.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				mc.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				mc.addEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
		
		private function rollOverHandler (e:MouseEvent) {
			if (e.target.alpha == 0) { //show 'empty' frame
				TweenMax.to(e.target, .25, { colorMatrixFilter: { brightness:2.8 }, glowFilter: { alpha:50, blurX:15, blurY:15, strength:1.5 } } );
				e.target.alpha = 100;
			}
			else if (e.target.name == 'closet_btn' || e.target.name == 'lights_mc' || e.target.name == 'plant_mc' || e.target.name == 'basket_mc')
				TweenMax.to(e.target, .25, { colorMatrixFilter: { brightness:1.5 }, glowFilter: { alpha:50, blurX:15, blurY:15, strength:1.5, color:0xffffff } } );
			else {
				trace(e.target.name + ' ' + e.target.currentFrame);
				if (e.target.name == 'border_mc')
					bg.table_mc.gotoAndStop(bg.table_mc.currentFrame + 1);
				else if (e.target.name == 'table_mc')
					bg.border_mc.gotoAndStop(bg.border_mc.currentFrame + 1);
				e.target.gotoAndStop(e.target.currentFrame + 1);
			}
		}
		
		private function rollOutHandler (e:MouseEvent) {
			if (e.target.currentFrame == e.target.totalFrames && (e.target.name != 'border_mc' && e.target.name != 'wall_mc' && e.target.name != 'floor_mc' && e.target.name != 'table_mc'  && e.target.name != 'closet_btn'))
				e.target.alpha = 0;
			else if (e.target.name == 'closet_btn' || e.target.name == 'lights_mc' || e.target.name == 'plant_mc' || e.target.name == 'basket_mc')
				TweenMax.to(e.target, .25, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );
			else {
				if (e.target.name == 'border_mc')
					bg.table_mc.gotoAndStop(bg.table_mc.currentFrame - 1);
				else if (e.target.name == 'table_mc')
					bg.border_mc.gotoAndStop(bg.border_mc.currentFrame - 1);
				e.target.gotoAndStop(e.target.currentFrame - 1);
			}
		}
		
		private function clickHandler (e:MouseEvent) {
			trace(e.target.name);
			if (e.target.name.toString().indexOf('instance') == -1 && e.target.name.toString().indexOf('color') == -1) {
				if (!menu_mc.visible) {
					mouseX > 870 ? menu_mc.x = 870 : menu_mc.x = mouseX;
					mouseY > 320 ? menu_mc.y = 320 : menu_mc.y = mouseY;
				}
				switch (e.target.name) {
					case 'table_mc':
					case 'border_mc': {
						menu = 'border';
						menu_mc.menuColors.visible = menu_mc.visible = true;
						menu_mc.toggle_mc.visible = false;
						menu_mc.menuColors.gotoAndStop(1);
						removeClicks();
					break; }
					case 'lights_mc': {
						menu = 'lights';
						menuLight.visible = menu_mc.visible = menu_mc.toggle_mc.visible = true;
						if (e.target.currentFrame != e.target.totalFrames)
							menu_mc.toggle_mc.check_mc.visible = true;
						else {
							menu_mc.toggle_mc.check_mc.visible = false;
							e.target.alpha = 0;
						}
						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );
						removeClicks();
					break; }
					case 'plant_mc': {
						menu = 'plant';
						menuPlant.visible = menu_mc.visible = menu_mc.toggle_mc.visible = true;
						if (e.target.currentFrame != e.target.totalFrames)
							menu_mc.toggle_mc.check_mc.visible = true;
						else {
							menu_mc.toggle_mc.check_mc.visible = false;
							e.target.alpha = 0;
						}
						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );
						removeClicks();
					break; }
					case 'basket_mc': {
						menu = 'basket';
						menuBasket.visible = menu_mc.visible = menu_mc.toggle_mc.visible = true;
						if (e.target.currentFrame != e.target.totalFrames)
							menu_mc.toggle_mc.check_mc.visible = true;
						else {
							menu_mc.toggle_mc.check_mc.visible = false;
							e.target.alpha = 0;
						}
						TweenMax.to(e.target, 0, { colorMatrixFilter: { }, glowFilter: { alpha:0 } } );
						removeClicks();
					break; }
					case 'wall_mc': {
						menu = 'wall';
						menu_mc.menuColors.visible = menu_mc.visible = true;
						menu_mc.toggle_mc.visible = false;
						menu_mc.menuColors.gotoAndStop(3);
						removeClicks();
					break; }
					case 'floor_mc': {
						menu = 'floor';
						menu_mc.menuColors.visible = menu_mc.visible = true;
						menu_mc.toggle_mc.visible = false;
						menu_mc.menuColors.gotoAndStop(2);
						removeClicks();
					break; }
					case 'close_menu_btn': {
						if (menuLight.visible && (bg.lights_mc.currentFrame != bg.lights_mc.totalFrames || !menu_mc.toggle_mc.check_mc.visible))
							menuLight.visible = menu_mc.visible = false;
						else if (menuPlant.visible && (bg.plant_mc.currentFrame != bg.plant_mc.totalFrames || !menu_mc.toggle_mc.check_mc.visible))
							menuPlant.visible = menu_mc.visible = false;
						else if (menuBasket.visible && (bg.basket_mc.currentFrame != bg.basket_mc.totalFrames || !menu_mc.toggle_mc.check_mc.visible))
							menuBasket.visible = menu_mc.visible = false;
						else if (menu_mc.menuColors.visible) {
							menu_mc.menuColors.visible = menu_mc.visible = false;
							menu_mc.toggle_mc.visible = true;
						}
						addClicks();
					break; }
					case 'toggle_mc': {
						e.target.check_mc.visible = !e.target.check_mc.visible;
						switch (menu) {
							case 'lights': {
								if (bg.lights_mc.alpha == 0) {
									bg.lights_mc.gotoAndStop(lastLight);
									bg.lights_mc.alpha = 100;
								}
								else {
									lastLight = bg.lights_mc.currentFrame;
									bg.lights_mc.alpha = 0;
									bg.lights_mc.gotoAndStop(bg.lights_mc.totalFrames);
								}
							break; }
							case 'plant': {
								if (bg.plant_mc.alpha == 0) {
									bg.plant_mc.gotoAndStop(lastPlant);
									bg.plant_mc.alpha = 100;
								}
								else {
									lastPlant = bg.plant_mc.currentFrame;
									bg.plant_mc.alpha = 0;
									bg.plant_mc.gotoAndStop(bg.plant_mc.totalFrames);
								}
							break; }
							case 'basket': {
								if (bg.basket_mc.alpha == 0) {
									bg.basket_mc.gotoAndStop(lastBasket);
									bg.basket_mc.alpha = 100;
								}
								else {
									lastBasket = bg.basket_mc.currentFrame;
									bg.basket_mc.alpha = 0;
									bg.basket_mc.gotoAndStop(bg.basket_mc.totalFrames);
								}
							break; }
						}
					break; }
					case 'closet_btn':
						updateDB();
						world.dormRoomLoadCloset();
						break;
				}
			}
			else { //in the menu
				var l:uint = e.target.toString().length;
				trace(e.target.toString().slice(8, l - 3));
				switch (e.target.toString().slice(8, l - 3)) {
					case 'light': {
						bg.lights_mc.alpha = 100;
						bg.lights_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));
						menu_mc.toggle_mc.check_mc.visible = true;
					break; }
					case 'plant': {
						bg.plant_mc.alpha = 100;
						bg.plant_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));
						menu_mc.toggle_mc.check_mc.visible = true;
					break; }
					case 'basket': {
						bg.basket_mc.alpha = 100;
						bg.basket_mc.gotoAndStop(e.target.toString().slice(l - 3, l - 1));
						menu_mc.toggle_mc.check_mc.visible = true;
					break; }
					default: { //color
						trace('menu ' + menu);
						l = e.target.name.toString().length;
						var frame:uint = e.target.name.toString().slice(l - 1, l) * 2 - 1;
						switch(menu) {
							case 'border': {
								trimColor = frame;
								bg.border_mc.gotoAndStop(frame);
								bg.table_mc.gotoAndStop(frame);
							break; }
							case 'wall': {
								wallColor = frame;
								bg.wall_mc.gotoAndStop(frame);
							break; }
							case 'floor': {
								floorColor = frame;
								bg.floor_mc.gotoAndStop(frame);
							break; }
						}
					break; }
				}
			}
		}
		
		private function updateDB() {
			var obj:Object = new Object();
			obj.wallColor = wallColor;
			obj.trimColor = trimColor;
			obj.floorColor = floorColor;
			obj.lights = bg.lights_mc.currentFrame;
			obj.plants = bg.plant_mc.currentFrame;
			obj.basket = bg.basket_mc.currentFrame;
			world.updateDormRoom(obj);
		}
		
		public function deleteMe() {
			trace('[DormRoom: deleteMe]');
			world = null;
			mcArr = [];
			menuLight = null;
			menuPlant = null;
			menuBasket = null;
			menu = null;
			removeClicks();
			menu_mc.removeEventListener(MouseEvent.CLICK, clickHandler);
			while (numChildren > 0) {
				var mc:MovieClip = getChildAt(0) as MovieClip;
				removeChildAt(0);
			}
		}
		
	}
}