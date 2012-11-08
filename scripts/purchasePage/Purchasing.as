package scripts.purchasePage
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.system.Security;
	import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
	
	public class Purchasing extends MovieClip
	{
		public function Purchasing() 
		{
			// constructor code			
			AlertWin.FinishBtn.addEventListener(MouseEvent.CLICK, onFinishButtonClick);
			AlertWin.CancelBtn.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
		}
		private function onFinishButtonClick(event:MouseEvent):void
		{ 
			dispatchEvent(new Event("Finished",true));
		}
		private function onCancelButtonClick(event:MouseEvent):void
		{
			dispatchEvent(new Event("Canceled",true));
		}
	}	
}
