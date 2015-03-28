package com.voki.vhss.playback
{
	public interface IBackgroundAPI
	{
		function setVolume(value:Number):void;
		function bgPlay(offset:Number=0):void;
		function bgStop():void;
		function bgReplay():void;
		function bgPause():void;
		function bgResume():void;
		function getStatus():String;
		function destroy():void;
		function displayBgFrame(offset:Number = 0):void
		
	}
}