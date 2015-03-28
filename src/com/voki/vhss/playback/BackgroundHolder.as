/**
* ...
* @author Dave Segal
* @version 0.1
* @date 12.03.2007
* 
*/

package com.voki.vhss.playback
{
	
	
	import com.oddcast.assets.structures.BackgroundStruct;
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.utils.ErrorReportingLoader;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	
	import com.voki.vhss.Constants;

	public class BackgroundHolder extends AssetHolder 
	{
		private static const BG_LIB_URL:String = "VHSSBgLib.swf";
		
		private static var anim_frame_rate:int = 12;
		
		private var bg_ss_api:IBackgroundAPI;
		private var bg_lib_ldr:ErrorReportingLoader;
		private var bg_lib_ready:Boolean = false;
		
		public function setVolume(value:Number):void
		{
			if (bg_ss_api)
				bg_ss_api.setVolume(value);
		}
		
		public function BackgroundHolder($type:String = "bg"):void
		{
			super($type);
		}
		
		public override function loadAsset($asset:LoadedAssetStruct):void
		{
			//----trace("BG HOLDER- --- loadAsset :: " + $asset+"  type: "+type);
			var t_bg_asset:BackgroundStruct = BackgroundStruct($asset);
			var t_do:DisplayObject;
			var bg_class:Object;
			switch (t_bg_asset.type)
			{
				//case "photo":
				//	super.loadAsset($asset);
				//	break;
				//case "anim":
				//	super.loadAsset($asset);
				//	break;
				
				case "video":
					//super.loadAsset($asset);
					loading_asset_data = $asset;
					if (bg_lib_ready)
					{
						if (bg_lib_ldr.contentLoaderInfo.applicationDomain.hasDefinition("vhss.playback.BgVideoPlayer"))
						{
							bg_class = bg_lib_ldr.contentLoaderInfo.applicationDomain.getDefinition("vhss.playback.BgVideoPlayer") as Class;
							
							t_do = new bg_class(t_bg_asset);
							t_bg_asset.display_obj = t_do;
							t_do.addEventListener(Event.INIT, e_completeHandler);
							t_do.addEventListener(Event.COMPLETE, e_playbackComplete);
						}
						else
						{
							trace("BGHOLDER -- ERROR loading class from lib");
							e_completeHandler(new Event("null"));
						}
						
					}
					else
					{
						loadBgLib();
					}
					break;
				case "slideshow":
					//t_do = super.loadAsset($asset);
					loading_asset_data = $asset;
					if (bg_lib_ready)
					{
						if (bg_lib_ldr.contentLoaderInfo.applicationDomain.hasDefinition("vhss.playback.BgSlideshowPlayer"))
						{
							bg_class = bg_lib_ldr.contentLoaderInfo.applicationDomain.getDefinition("vhss.playback.BgSlideshowPlayer") as Class;
							
							t_do = new bg_class($asset.url);
							t_bg_asset.display_obj = t_do;
							t_do.addEventListener(Event.INIT, e_completeHandler);
							t_do.addEventListener(Event.COMPLETE, e_playbackComplete);
						}
						else
						{
							trace("BGHOLDER -- ERROR loading class from lib");
							e_completeHandler(new Event("null"));
						}
					}
					else
					{
						loadBgLib();
					}
					break;
				default:
					//t_bg_asset.bg_type = "anim";
					super.loadAsset($asset);
			}
			//return t_do;
		}
		
		public override function displayAsset($asset:LoadedAssetStruct):void
		{
			stop();
			super.displayAsset($asset);
			var t_bg_asset:BackgroundStruct = BackgroundStruct(active_asset_data);
			//var _do:DisplayObject = active_asset_data.display_obj;
			bg_ss_api = null;
			if (t_bg_asset == null) return;
			switch (t_bg_asset.type)
			{
				//case "anim":
				//	MovieClip(t_bg_asset.display_obj).stop();
					//for each (var $i:* in t_bg_asset.display_obj)
					//{
						//if ($i is MovieClip)
						//{
							//trace("BACKGROUND ANIM  CYCLE --- "+$i);//+"  "+MovieClip($i).name);
						//}
					//}
					//break;
				case "photo":
					try
					{
						var _bmp:Bitmap = Bitmap(t_bg_asset.display_obj);
						_bmp.smoothing = true;
					}
					catch (error:Error){}
					break
				case "slideshow":
					bg_ss_api = IBackgroundAPI(t_bg_asset.display_obj);
					//bg_ss_api.setBackground(t_bg_asset);
					//addChild(bg_ss_api);
					break;
				case "video":
					bg_ss_api = IBackgroundAPI(t_bg_asset.display_obj);
					break;
			}
		}
		
		public function play():void
		{
			//----trace("BG HOLDER -- play "+bg_ss_api);
			if (bg_ss_api != null) bg_ss_api.bgPlay();
		}
		
		public function resume():void
		{
			//----trace("BG HOLDER -- resume "+bg_ss_api);
			if (bg_ss_api != null) bg_ss_api.bgResume();// bg_ss_api.bg_play(bg_ss_api.pauseOffset);
		}
		
		public function replay():void
		{
			//----trace("BG HOLDER -- replay "+bg_ss_api);
			if (bg_ss_api != null) bg_ss_api.bgReplay();
		}
		
		public function stop():void
		{
			if (bg_ss_api != null) bg_ss_api.bgStop();
		}
		
		public function pause():void
		{
			//----trace("BG HOLDER -- pause "+bg_ss_api);
			if (bg_ss_api != null) bg_ss_api.bgPause();
		}
		
		public function displayBgFrame(offset:Number = 0):void
		{
			if (bg_ss_api != null) bg_ss_api.displayBgFrame(offset);
		}
		
		public function getStatus():String
		{
			return (bg_ss_api != null) ? bg_ss_api.getStatus() : "";
		}
		
		public override function destroy():void
		{
			for each (var t_obj:Object in stack)
        	{
        		if (t_obj != null && t_obj is BackgroundStruct)
        		{
        			var t_las:BackgroundStruct = BackgroundStruct(t_obj);
        			if ((t_las.type == "slideshow" || t_las.type == "video") && t_las.display_obj)
        			{
        				IBackgroundAPI(t_las.display_obj).destroy();
        			}
        			if (t_las.loader)
        			{
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
					t_las.destroy();
        		}
        	}
        	while(this.numChildren > 0) removeChildAt(0);
		}
		
		private function loadBgLib():void
		{
			if (!bg_lib_ldr)
			{
				bg_lib_ldr = new ErrorReportingLoader();
				bg_lib_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteLoadLib);
				bg_lib_ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorLoadLib);
				
				
				
				
				var t_url:String = Constants.PLAYER_URL;
				t_url = t_url.split("?")[0].split("\\").join("/"); // replace backslash with slash
				t_url = t_url.substring(0, t_url.lastIndexOf("/")+1);
				
				//trace("BGHOLDER -- load bg url:: "+t_url + BG_LIB_URL);
				bg_lib_ldr.load(new URLRequest(t_url + BG_LIB_URL));
			}
			else
			{
				e_completeHandler(new Event("null"));
			}
		}
		
		//Events
		
		//Loader Events
		private function e_playbackComplete($ev:Event):void
		{
			//trace("Background Holder -- playback complete");
			dispatchEvent($ev);
		}
		
		private function onCompleteLoadLib(event:Event):void
		{
			bg_lib_ready = true;
			loadAsset(loading_asset_data);
		}
		
		private function onErrorLoadLib(event:Event):void
		{
			e_completeHandler(new Event("null"));
		}
	}
}