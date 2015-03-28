package com.voki.vhss.playback
{
	import com.oddcast.assets.structures.LoadedAssetStruct;
	
	import flash.display.*;
	import flash.events.*;
	
	public class EngineHolder extends AssetHolder
	{
		public function EngineHolder()
		{
			super();
		}
		
		public override function destroy():void
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
        				if (t_las.loader.content)
        				{
        					trace("ENGINE HOLDER destructor -- destroy engine --- "+MovieClip(t_las.loader.content).destroy);
        					MovieClip(t_las.loader.content).destroy();
        				}
						t_las.loader.unload();
						t_las.loader = null;
        			}
					t_las.destroy();
        		}
        	}
        	while(this.numChildren > 0) removeChildAt(0);
		}
		
	}
}