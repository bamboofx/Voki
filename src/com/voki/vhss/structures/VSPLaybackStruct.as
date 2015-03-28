package com.voki.vhss.structures
{
	import com.oddcast.assets.structures.*;

	public class VSPLaybackStruct
	{	
		//this is the pre-photoface source video that was used
		public var videostarSourceStruct:VideoStruct; 
		public var audioURL:AudioStruct;
		public var hostsArr:Array;
		public var keyFileArr:Array;
		
		public function VSPLaybackStruct()
		{
			hostsArr		= new Array();
			keyFileArr		= new Array();
		}
		
		/**
		 * adds another actor to the list
		 * @param	_model model information
		 * @param	keyFile keyfile information for that model
		 */
		public function addActor(_model:HostStruct, keyFile:LoadedAssetStruct) {
			trace('VSPLaybackStruct::addActor - ',_model, keyFile);
			hostsArr.push(_model);
			keyFileArr.push(keyFile);
		}
		
		public function get model():HostStruct {
			return(hostsArr[0]);
		}
	}
}