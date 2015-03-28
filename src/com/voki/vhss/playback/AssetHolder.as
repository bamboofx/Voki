/**
* ...
* @author David Segal
* @version 0.1
* @date 12.03.2007
* 
*/

package com.voki.vhss.playback {
	
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import com.oddcast.utils.ErrorReportingLoader;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import com.voki.vhss.events.AssetEvent;

	public class AssetHolder extends Sprite{
		protected var stack:Dictionary;
		protected var type:String;
		protected var active_asset_data:LoadedAssetStruct;
		//protected var last_asset_data:LoadedAssetStruct;
		
		protected var loading_asset_data:LoadedAssetStruct;
	
		function AssetHolder($type:String = "asset"):void
		{
			//trace("AssetHolder constructor");
			type = $type;
			stack = new Dictionary();
		}
	
		public function displayAsset($asset:LoadedAssetStruct):void	
		{
			if ($asset == null || $asset.url == null)
			{
				removeActiveAsset();
				active_asset_data = null;
			}
			else
			{
				//if (active_asset_data != null) last_asset_data = active_asset_data;
				//active_asset_data = $asset;
				//var _index:String = MD5.hash($asset.url);
				//var _id:uint = active_asset_data.id;
				//if (stack[_index] == null) // new asset to load
				//{
					//var _url:String = $asset.url;
					
					//active_asset_data.display_obj = loadAsset($asset);
					//loadAsset(active_asset_data);
					//stack[_index] = active_asset_data;
				//}
				//else  // asset already loaded
				//{
					//active_asset_data = stack[_index];
					if (active_asset_data == null || $asset.url != active_asset_data.url) // swap asset with another that was already loaded
					{
						removeActiveAsset();
						active_asset_data = $asset;
						//addChild(Loader(active_asset_data.display_obj).contentLoaderInfo.content);// __ REMOVE __
						if (active_asset_data.display_obj != null) try { addChild(active_asset_data.display_obj); } catch (e:Error) {}
					}
					//else  // new asset is already on the stage
					//{
					//	active_asset_data = last_asset_data;
					//}
					//e_completeHandler(new Event(Event.INIT));
				//}			
			}
		}
		
		public function loadAsset($asset:LoadedAssetStruct):void //DisplayObject
		{
			if ($asset.url != null)
			{
				var t_index:String = escape($asset.id.toString()+$asset.url);
				if (stack[t_index] == null)
				{
					//----trace("AssetHolder --- -ds- loadAsset :: NEED TO LOAD :: " + $asset.type+"  type: "+type);
					loading_asset_data = $asset;
					stack[t_index] = $asset;
					var _a_reg:URLRequest = new URLRequest($asset.url);
					var _a_loader:ErrorReportingLoader = new ErrorReportingLoader();
					var t_context:LoaderContext = getLoaderContext($asset);
					var _info:LoaderInfo = LoaderInfo(this.loaderInfo);
					configureListeners(_a_loader.contentLoaderInfo);
					$asset.loader = _a_loader;
					_a_loader.load(_a_reg, t_context);
				}
				else
				{
					//----trace("AssetHolder --- loadAsset :: ALREADY LOADED :: " + $asset.type+"  type: "+type);
					loading_asset_data = stack[t_index];
					$asset.loader = loading_asset_data.loader;
					$asset.display_obj = loading_asset_data.display_obj;
					e_completeHandler(new Event(Event.INIT));
				}
			}
			else
			{
				loading_asset_data = $asset;
				e_completeHandler(new Event(Event.INIT));
			}	
		}
		
		public function getLoadedAsset($str:String):LoadedAssetStruct
		{
			//----trace("AssetHolder -- get loaded asset");
			var t_index:String = escape($str);
			//if (stack[t_index] != null)
			//{
				return stack[t_index];
			//}
			//else
			//{
			//	return null;
			//}
		}
		
		protected function getLoaderContext($asset:LoadedAssetStruct):LoaderContext
		{
			var t_lc:LoaderContext = new LoaderContext();
			if ($asset.url.indexOf(".swf") == -1 )
			{
				//----trace("ASSET HOLDER --- getLoaderContext =======  check policy file " +$asset);
				t_lc.checkPolicyFile = true;
			}
			return t_lc;
		}
		
		protected function removeActiveAsset():void
		{
			//----trace("ASSET HOLDER :: removeActiveAsset");
			try 
			{
				//removeChild(Loader(last_asset_data.display_obj).contentLoaderInfo.content);// __ REMOVE __
				removeChild(active_asset_data.display_obj);
			} 
			catch (err:Error)
			{
				//----trace("ASSET HOLDER :: "+type+" :: ERROR ::  initHandler :: nothing to remove ::: "+err.toString());
			}
		}
		
		protected function setType($str:String):void
		{
			type = $str;
		}
		
		protected function configureListeners(dispatcher:IEventDispatcher):void 
		{
			dispatcher.addEventListener(Event.INIT, e_initHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, e_httpStatusHandler);
			dispatcher.addEventListener(Event.COMPLETE, e_completeHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, e_ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, e_openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, e_progressHandler);
			dispatcher.addEventListener(Event.UNLOAD, e_unLoadHandler);
        }
        
        public function destroy():void
        {
        	for each (var t_obj:Object in stack)
        	{
        		if (t_obj != null && t_obj is LoadedAssetStruct)
        		{
        			var t_las:LoadedAssetStruct = LoadedAssetStruct(t_obj);
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
	
		/*	
		protected function e_completeHandler(event:Event):void 
		{
			//----trace("AssetHolder --- completeHandler: " + type +" targ: "+event.target+ "   url : "+event.currentTarget);
			if (event.target is LoaderInfo)
			{ 
				var t_li:LoaderInfo = LoaderInfo(event.target);
				//----trace("AssetHolder --- COMPLETE  CONTENT TYPE: "+t_li.contentType);
				trace("\t--- openHandler cont: "+t_li.content);
				trace("\t--- openHandler cli: "+t_li.loader.contentLoaderInfo);
			}
			//dispatchEvent(new AssetEvent(AssetEvent.ASSET_LOADED));
        }
		*/
		
		// Events
		protected function e_initHandler($ev:Event):void
		{
			if ($ev.target is LoaderInfo)
			{
				loading_asset_data.display_obj = LoaderInfo($ev.target).content;
			}
		}
		
		protected function e_httpStatusHandler(event:HTTPStatusEvent):void 
		{
		}

		protected function e_completeHandler(event:Event):void 
		{
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_INIT, loading_asset_data)) ;
		}

		protected function e_ioErrorHandler(event:IOErrorEvent):void 
		{
			e_completeHandler(new Event("null"));
		}

		protected function e_openHandler(event:Event):void 
		{
			//trace("AssetHolder --- openHandler: type: "+type+" targ: "+event.target+" event: " + event);
			
		}

		protected function e_progressHandler(event:ProgressEvent):void 
		{
		}

		protected function e_unLoadHandler(event:Event):void 
		{
			//----trace("AssetHolder --- unLoadHandler: type: "+type+" targ: "+event.target+" event: " + event);
		}	
	}
}