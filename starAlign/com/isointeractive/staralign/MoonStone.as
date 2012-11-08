package com.isointeractive.staralign {
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.ColorTransformPlugin;

	TweenPlugin.activate([GlowFilterPlugin]);
	TweenPlugin.activate([ColorTransformPlugin]);
	
	public class MoonStone extends MovieClip{
		
		private var _activated:Boolean = false;

		public function MoonStone() {
			
			spotlight_mc.alpha = 0;
			
		}
		
		public function addStoneColor(clr:Number, t:Number):void{
			TweenMax.to(this, t*.4, {ease:Linear.easeNone, colorTransform:{tint:clr, tintAmount:.3}, onComplete:removeStoneColor, onCompleteParams:[t]});
		}
		
		public function removeStoneColor(t:Number):void{
			TweenMax.to(this, t*.4, {delay:t*.2, ease:Linear.easeNone, colorTransform:{tintAmount:0}, onComplete:deactivate});
		}
		
		public function addSpotlight(t:Number):void{
			TweenMax.to(this.spotlight_mc, t*.1, {ease:Quad.easeOut, delay:t*.4, alpha:1, onComplete:removeSpotlight, onCompleteParams:[t]});
		}
		
		public function removeSpotlight(t:Number):void{
			TweenMax.to(this.spotlight_mc, t*.1, {ease:Quad.easeIn, alpha:0});
		}
		
		public function addGlow(clr:Number, t:Number):void{
			TweenMax.to(this, t*.4, {ease:Linear.easeNone,glowFilter:{color:0xFFFFFF, blurX:15, blurY:15, strength:2, alpha:1}, onComplete:removeGlow, onCompleteParams:[t]});
		}
		
		public function removeGlow(t:Number):void{
			TweenMax.to(this, t*.4, {delay:t*.2, ease:Linear.easeNone, delay:4, glowFilter:{blurX:0, blurY:0, strength:0, alpha:0}});
		}
		
		public function beginHighlight(clr:Number, time:Number):void{
			if(!activated){
				spotlight_mc.alpha = 0;
				
				addStoneColor(clr, time);
				addSpotlight(time);
				addGlow(clr, time);
				_activated = true;
			}
		}
		
		public function get activated():Boolean{
			return _activated;
		}
		
		private function deactivate():void{
			_activated = false;
		}

	}
	
}
