package com.isointeractive.staralign {
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.easing.Quad;
	import flash.events.Event;
	import flash.geom.Point;

	TweenPlugin.activate([ColorTransformPlugin]);
	
	public class ConstellationImage extends MovieClip{
		
		private var starArray:Array;
		private var _timerArray:Array;
		private var clr:Number;

		public function ConstellationImage(c:Number = 0xFFFFFF) {
			this.visible = false;
			clr = c;
			starArray = [];
			_timerArray = [];
			initializeStars();
			//TweenMax.to(this, 0, {colorTransform:{tint:0xFF0000, tintAmount:.3}});
			addEventListener(Event.ENTER_FRAME, starUpdate);
			this.scaleX = this.scaleY = .2;
			this.alpha = 0;
			showConstellation();
			/*
			for(var i:int = 0; i < _timerArray.length; i++){
				trace(_timerArray[i].delay + ", " + (_timerArray[i].yPos+278));
			}
			*/
		}
		
		private function initializeStars():void{
			for(var i:int = 0; i < this.numChildren; i++){
				if(this.getChildAt(i) is StarMC){
					starArray.push(this.getChildAt(i));
				}
			}
			
			starArray = mergeSort(starArray);
			
			var xTotal:Number = starArray[starArray.length-1].x - starArray[0].x;
			var xStart:Number = starArray[0].x;
			trace("Difference: " + xTotal);
			
			for(i = 0; i < starArray.length; i++){
				starArray[i].scaleX = starArray[i].scaleY = Math.random()*.5 + 1;
				starArray[i].rotation = Math.random()*20-10;
				starArray[i].setColor(clr);
				starArray[i].glowChance = .05;
				_timerArray.push({delay:((starArray[i].x - xStart)/xTotal), yPos:this.localToGlobal(new Point(0, starArray[i].y)).y});
			}
			
		}
		
		public function setColor(c:Number):void{
			clr = c;
			for(var i:int = 0; i < starArray.length; i++){
				starArray[i].setColor(clr);
			}
		}
		
		private function starUpdate(evt:Event):void{
			for(var i:int = 0; i < starArray.length; i++){
				starArray[i].glowCheck();
				starArray[i].rotation += 2;
			}
		}
		
		public function showConstellation():void{
			this.visible = true;
			TweenMax.to(this, 1.5, {ease:Quad.easeIn, scaleX:1, scaleY:1, alpha:1, onComplete:removeConstellation});
		}
		
		private function removeConstellation():void{
			this.visible = true;
			TweenMax.to(this, 2, {ease:Quad.easeOut, delay:1, alpha:0});
		}
		
		private function mergeSort(arr:Array):Array{
			if(arr.length <= 1){
				return arr;
			}else{
				var topArray:Array = [];
				var bottomArray:Array = [];
				
				var hingeElement:MovieClip = MovieClip(arr.shift());
			
				while(arr.length > 0){
					if(arr[0].x > hingeElement.x){
						topArray.push(arr.shift());
					}else{
						bottomArray.push(arr.shift());
					}
				}
				
				bottomArray.push(hingeElement);
				
				topArray = mergeSort(topArray);
				bottomArray = mergeSort(bottomArray);
				
				topArray = bottomArray.concat(topArray);
				
				return topArray;
			}
		}
		
		public function get timerArray():Array{
			return _timerArray;
		}

	}
	
}
