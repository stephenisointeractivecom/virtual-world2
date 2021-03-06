﻿package com.isointeractive.staralign{
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.ColorTransformPlugin;

	TweenPlugin.activate([GlowFilterPlugin]);
	TweenPlugin.activate([ColorTransformPlugin]);
	
	public class StarMC extends MovieClip{
		
		private var _glowChance:Number;
		
		public function StarMC() {
			_glowChance = .01;
		}
		
		public function setColor(starColor:Number):void{
			TweenMax.to(this, 0, {colorTransform:{tint:starColor, tintAmount:(Math.random()*.1 + .1)}});
		}
		
		public function setConstellationColor(starColor:Number):void{
			TweenMax.to(this, 0, {colorTransform:{tint:starColor, tintAmount:.4}});
		}
		
		private function glowIn():void{
			TweenMax.to(this, .1, {glowFilter:{color:0xFFFFFF, blurX:15, blurY:15, strength:6, alpha:1, remove:true}});
		}
		
		private function twinkleIn():void{
			TweenMax.to(this, .1, {alpha:.8, onComplete:twinkleOut});
		}
		
		private function twinkleOut():void{
			TweenMax.to(this, .1, {alpha:1});
		}
		
		public function glowCheck():void{
			if(Math.random() < _glowChance){
				glowIn();
			}
		}
		
		public function initializeRandomStar(sWidth:Number = 0, sHeight:Number = 0, placeOverSky:Boolean = false):void{
			var starScale = Math.random() * .4;
			while(Math.random() > .7 && starScale < .75){
				starScale += Math.random() * .4;
			}
			this.scaleX = this.scaleY = starScale;
			this.rotation = Math.random()*30 - 15;
			
			if(placeOverSky){
				this.x = Math.random()*sWidth;
			} else {
				this.x = sWidth + this.width;
			}
			
			this.y = Math.random()*sHeight;
		}
		
		public function initializeConstellationStar(sWidth:Number, yPos:Number):void{
			var starScale = 1;
			this.scaleX = this.scaleY = starScale;
			this.x = sWidth + this.width;
			this.y = yPos;
		}
		
		public function setStarPath(time:Number, endX:Number, glowMax:Number = 0){
			TweenMax.to(this, time, {ease:Linear.easeNone, x: endX, onComplete:killStar});
			if(glowMax > 0){
				_glowChance = 0;
				var fadeInTime:Number = time-time*(glowMax/this.x);
				TweenMax.to(this, fadeInTime, {ease:Quad.easeIn, glowFilter:{color:0xFFFFFF, blurX:20, blurY:20, strength:5, alpha:.8}});
				TweenMax.to(this, time-fadeInTime, {ease:Quad.easeOut, delay:fadeInTime, glowFilter:{color:0xFFFFFF, blurX:0, blurY:0, strength:0, alpha:0}});
			}
		}
		
		public function activateHighlight():void{
			var sc:Number = this.scaleX;
			TweenMax.to(this, .2, {scaleX:2, scaleY:2, onComplete:deactivateHighlight, onCompleteParams:[sc]});
		}
		
		public function deactivateHighlight(sc:Number):void{
			TweenMax.to(this, .2, {delay:.2, scaleX:sc, scaleY:sc, onComplete:deactivateHighlight, onCompleteParams:[sc]});
		}
		
		public function killStar():void{
			dispatchEvent(new StarAlignEvent(StarAlignEvent.KILL_STAR, {}));
		}
		
		public function set glowChance(n:Number):void{
			_glowChance = n;
		}

	}
	
}
