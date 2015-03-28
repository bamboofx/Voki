/**
* ...
* @author David Segal
* @version 0.1
* @date 06.20.08
* 
*/

package com.voki.vhss.playback
{
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.event.SkinEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	

	public class SkinHolder extends AssetHolder 
	{
		
		private var active_skin:MovieClip;
		private var skin_volume:Number = 1;
		
		public function SkinHolder($type:String = "skin"):void
		{
			super($type);
		}
		
		public override function displayAsset($asset:LoadedAssetStruct):void
		{
			super.displayAsset($asset);
			if ($asset == null || $asset.url == null)
			{
				active_skin = null;
			}
			else
			{
				active_skin = MovieClip(active_asset_data.display_obj);
				active_skin.addEventListener(SkinEvent.PLAY, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.LEAD_ERROR, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.LEAD_SUCCESS, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.MUTE, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.NEXT, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.PREV, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.SAY_AI, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.SAY_FAQ, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.SEND_LEAD, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.PAUSE, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.UNMUTE, e_dispatchEvent);
				active_skin.addEventListener(SkinEvent.VOLUME_CHANGE, e_dispatchEvent);
				//if (t_conf_xml != null) active_skin.configureSkin(SkinStruct(active_asset_data).configXML);
				//----trace("SKIN HOLDER --- displayAsset  -- volume: " + skin_volume);
				setVolumeSlider(skin_volume);
			}
		}
		
		override protected function removeActiveAsset():void
		{
			//----trace("SKIN HOLDER -- removeActiveAsset");
			if (active_asset_data != null && active_asset_data.display_obj != null)
			{
				var t_do:MovieClip = MovieClip(active_asset_data.display_obj);
				t_do.removeEventListener(SkinEvent.PLAY, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.LEAD_ERROR, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.LEAD_SUCCESS, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.MUTE, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.NEXT, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.PREV, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.SAY_AI, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.SAY_FAQ, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.SEND_LEAD, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.PAUSE, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.UNMUTE, e_dispatchEvent);
				t_do.removeEventListener(SkinEvent.VOLUME_CHANGE, e_dispatchEvent);
			}
			super.removeActiveAsset();
		}
		
		override protected function getLoaderContext($asset:LoadedAssetStruct):LoaderContext
		{
			var t_lc:LoaderContext = new LoaderContext();
			if ($asset.url.indexOf(".swf") == -1 )
			{
				//----trace("SKIN HOLDER --- getLoaderContext =======  check policy file " +$asset);
				t_lc.checkPolicyFile = true;
			}
			t_lc.applicationDomain = new ApplicationDomain();
			return t_lc;
		}
		
		// Public API
		public function configureSkin($xml:XML):void
		{
			active_skin.configureSkin($xml);
		}
		
		public function activatePlayButton():void
		{
			//trace("SKIN HOLDER --- Activate play button --- " + active_skin.talkEnded);
			if (active_skin != null) active_skin.talkEnded();
		}
		
		public function activatePauseButton():void
		{
			//trace("SKIN HOLDER --- Activate pause button --- " + active_skin.talkStarted);
			if (active_skin != null) active_skin.talkStarted();
		}
		
		public function getWatermarkPosition():Object
		{
			return active_skin.getWatermarkPosition();
		}
		
		public function activateMuteButton():void
		{
			//----trace("SKIN HOLDER --- Activate mute button -- ");
		}
		
		public function activateUnmuteButton():void
		{
			//----trace("SKIN HOLDER --- Activate unmute button -- ");
		}
		
		public function setAIResponse(_resp:String):void
		{
			if (active_skin != null) active_skin.setAIResponse(_resp);
		}
		
		/**
		 * Sets a volume value on the skin volume control so the active skin can update its view
		 * @param	$vol	Range between [0, 1]
		 */
		public function setVolumeSlider($vol:Number):void
		{
			//----trace("SKIN HOLDER --- Activate volume button -- " + $vol);
			skin_volume = $vol;
			if (active_skin != null)
			{
				active_skin.setVolume(skin_volume);
			}
		}
		
		public function getSkinMask():MovieClip
		{
			return MovieClip(active_skin.getChildByName("mask"));
		}
		
		public function setLeadResponse($b:Boolean):void
		{
			active_skin.onLeadResponse($b);
		}
		
		override public function destroy():void
		{
			removeActiveAsset();
			for each (var t_obj:Object in stack)
        	{
        		if (t_obj && t_obj is LoadedAssetStruct)
        		{
        			var t_las:LoadedAssetStruct = LoadedAssetStruct(t_obj);
        			var t_do:MovieClip = MovieClip(t_las.display_obj);
					t_do.removeEventListener(SkinEvent.PLAY, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.LEAD_ERROR, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.LEAD_SUCCESS, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.MUTE, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.NEXT, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.PREV, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.SAY_AI, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.SAY_FAQ, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.SEND_LEAD, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.PAUSE, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.UNMUTE, e_dispatchEvent);
					t_do.removeEventListener(SkinEvent.VOLUME_CHANGE, e_dispatchEvent);
					if (t_las.loader.contentLoaderInfo)
    				{
        				var t_cli:LoaderInfo = t_las.loader.contentLoaderInfo;
						t_cli.removeEventListener(Event.INIT, e_initHandler);
						t_cli.removeEventListener(HTTPStatusEvent.HTTP_STATUS, e_httpStatusHandler);
						t_cli.removeEventListener(Event.COMPLETE, e_completeHandler);
						t_cli.removeEventListener(IOErrorEvent.IO_ERROR, e_ioErrorHandler);
						t_cli.removeEventListener(Event.OPEN, e_openHandler);
						t_cli.removeEventListener(ProgressEvent.PROGRESS, e_progressHandler);
						t_cli.removeEventListener(Event.UNLOAD, e_unLoadHandler);
    				}
					t_las.loader.unload();
					t_las.loader = null;
					t_las.display_obj = null;
        		}
			}
			//super.destroy();
		}
		
		// Event
		private function e_dispatchEvent($ev:*):void
		{
			//trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			var se:SkinEvent = new SkinEvent($ev.type, $ev.obj);
			dispatchEvent(se);
			//dispatchSkinEvent($ev);
		}
		
		/*
		private function e_skinPlay($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinPause($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinMute($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinUnmute($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinPrev($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinNext($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinVolume($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinSayAI($ev:*):void
		{
			//----trace("SKIN HOLDER --- event -- e_skinSayAI " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinSayFAQ($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinLeadSend($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinLeadSuccess($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		
		private function e_skinLeadError($ev:*):void
		{
			//----trace("SKIN HOLDER --- event " + $ev.type +"   obj: " + $ev.obj);
			dispatchSkinEvent($ev);
		}
		*/
	}
	
}