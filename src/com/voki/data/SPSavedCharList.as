//<PUPPET_LIST OH="http://char.dev.oddcast.com">
//<PUPPET CHARURL="/oh/108/845/1364/2057/0/860/313/302/0/0/oh.swf?cs=ababab7:2402524:2c40406:5018180:0:101:101:101:101:101:1:0:0" THUMB="http://vhost.dev.oddcast.com/content/STAGING/vhss/user/070/1460/thumbs/show_15439.jpg?1225137710" NAME="test"/>

package com.voki.data {
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.vhost.OHUrlParser;
	import flash.events.EventDispatcher;
	import com.oddcast.event.AlertEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPSavedCharList extends EventDispatcher{
		private var savedCharList:Array;
			
		public function getModels(callback:Function) {
			if (savedCharList != null) {
				callback(savedCharList);
				return;
			}
			
			var url:String=SessionVars.localBaseURL+"getCurAccScenesList.php?as=3&accId="+SessionVars.acc;
			XMLLoader.loadXML(url, gotModels,callback);
		}
		
		private function gotModels(_xml:XML,callback:Function) {
			if (_xml.localName() == "ERROR")
			{
				dispatchEvent(new AlertEvent(AlertEvent.FATAL,"sp701","The account you are logged into and the scene you are viewing do not match. Please close and reopen the editor from your account."));
				return;
			}
			var ohBaseUrl:String = _xml.@OH.toString();
			var contentBaseUrl:String = _xml.@BASE_URL;
			var puppetList:XMLList = _xml.PUPPET;
			
			var engineBaseUrl:String = _xml.ENGINES[0].@BASE_URL;
			var engineObjs:XMLList = _xml.ENGINES[0].ENGINE;
			var engineId:uint;
			var engineUrl:String;
			var engineArr:Array = new Array();
			var engine:EngineStruct;
			for (i = 0; i < engineObjs.length(); i++) {
				engineId = parseInt(engineObjs[i].@ID);
				engineUrl = engineObjs[i].@URL;
				if (engineUrl.length > 0) engineUrl = engineBaseUrl + engineUrl;
				engine = new EngineStruct(engineUrl, engineId, engineObjs[i].@TYPE.toUpperCase());
				engineArr[engineId]=engine;
			}
			
			var id:Number;
			var thumbUrl:String;
			var ohUrl:String;
			var name:String;
			var model:SPHostStruct;
			savedCharList = new Array();
			
			for (var i=0;i<puppetList.length();i++) {
				name=unescape(puppetList[i].@NAME);
				thumbUrl=puppetList[i].@THUMB;
				if (int(puppetList[i].@IS3D) == 1)
				{
					ohUrl = contentBaseUrl + puppetList[i].@CHARURL;
				}
				else
				{
					ohUrl = ohBaseUrl + puppetList[i].@CHARURL;
					ohUrl = ohUrl.split("char.dev.oddcast.com").join("content.dev.oddcast.com/char");
				}
				id = puppetList[i].@MODELID;
				engineId=parseInt(puppetList[i].@ENGINEID.toString());
				model = new SPHostStruct(ohUrl, id, thumbUrl, name);
				model.isOwned = true;
				model.is3d = (int(puppetList[i].@IS3D) == 1);
				if (engineArr[engineId] != undefined) model.engine = engineArr[engineId];
				model.type = String("host_" + model.engine.type).toLowerCase();
				savedCharList.push(model);
			}
			
			callback(savedCharList);
		}
	}
	
}