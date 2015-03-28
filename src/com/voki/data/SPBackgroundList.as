package com.voki.data {
	import com.oddcast.utils.XMLLoader;
	import flash.events.EventDispatcher;
	import com.oddcast.event.AlertEvent;
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPBackgroundList extends EventDispatcher{
		private var categoryArr:Array;
		private var bgsByCatArr:Array;
		private var accountBgArr:Array;
		
		public static var typeTitles:Object;
		public static const PRIVATE_CATEGORY:int = 999;
		
		public function SPBackgroundList() {
			bgsByCatArr = new Array();
			
			typeTitles = new Object();
			typeTitles[SPBackgroundStruct.ALL_TYPES] = "All";
			typeTitles[SPBackgroundStruct.IMAGE_TYPE] = "Image";
			typeTitles[SPBackgroundStruct.VIDEO_TYPE] = "Video";
		}
		
//-------------------------------------------------------------------------------------

		public function nameExists(name:String):Boolean
		{
			if (accountBgArr != null)
			{				
				for (var i:int = 0; i <  accountBgArr.length; ++i )
				{
					var b:SPBackgroundStruct = SPBackgroundStruct(accountBgArr[i]);
					if (b.name.toLowerCase() == name.toLowerCase())
					{
						return true;
					}
				}				
			}
			return false;
		}
		
		public function getCategoryArr(callback:Function) {
			loadCategories(callback);
		}
		
		private function loadCategories(callback:Function) {
			if (categoryArr != null) {
				callback(categoryArr);
			}
			else {
				var url:String=SessionVars.baseURL+"getBgCategories/partnerId="+SessionVars.partnerId+"/doorId="+SessionVars.doorId+"&levelId="+SessionVars.level;
				XMLLoader.loadXML(url,gotCategories,callback);
			}
		}
		
		private function gotCategories(_xml:XML,callback:Function) {
			categoryArr = parseCategories(_xml);
			categoryArr.sortOn("name",Array.CASEINSENSITIVE);
			callback(categoryArr);
		}
		
		private function parseCategories(_xml:XML):Array {
			var subcats:XMLList=_xml.CATEGORY.SUBCAT;

			var catId:int;
			var catName:String;
			var cat:SPCategory;
			var catArr:Array = new Array();
			
			for (var i:int=0;i<subcats.length();i++) {
				catId=parseInt(subcats[i].@ID.toString());
				catName = unescape(subcats[i].@NAME.toString());
				cat = new SPCategory(catId, catName);
				catArr.push(cat);
			}
			//catArr.push(new SPCategory( -1, "All"));
			return(catArr);
		}
		
//--------------------------------------------------------------
		
		
		public function getBgsByCatId(callback:Function, catId:int) {
			if (categoryArr == null) throw new Error("SPBgList::getBgsByCatId : You should load categories before making this call");
			
			if (bgsByCatArr[catId] != undefined) {
				callback(bgsByCatArr[catId]);
			}
			else {
				var url:String=SessionVars.baseURL+"getBackgrounds/partnerId="+SessionVars.partnerId+"/catId="+catId+"&doorId="+SessionVars.doorId+"&levelId="+SessionVars.level+"&as=3";
				XMLLoader.loadXML(url,gotBgs,catId,callback)
			}
		}

		private function gotBgs(_xml:XML,catId:int,callback:Function) {
			var bgArr:Array = parseBgXML(_xml,catId, this);
			bgsByCatArr[catId] = bgArr;
			callback(bgArr);
		}

		public static function parseBgXML(_xml:XML, catId:int, p:* = null) {
			if (_xml.localName() == "ERROR")
			{
				p.dispatchEvent(new AlertEvent(AlertEvent.FATAL,"sp701","The account you are logged into and the scene you are viewing do not match. Please close and reopen the editor from your account."));
				return;
			}
			
			var baseUrl:String=_xml.@BASEURL;
			var id:Number;
			var thumbUrl:String;
			var bgUrl:String
			var desc:String;
			var bg:SPBackgroundStruct;
			var transform:Object;
			var bgXML:XML;
			var arr=new Array();
			
			for (var i = 0; i < _xml.BG.length(); i++) {
				bgXML = _xml.BG[i];
				id=parseInt(bgXML.@ID)
				desc=unescape(bgXML.@DESC);
				thumbUrl=baseUrl+bgXML.@THUMB;
				bgUrl = baseUrl + bgXML.@FILENAME;	
				transform = { scaleX:int(bgXML.@SCALE) / 100, scaleY:int(bgXML.@SCALE) / 100 };
				trace("transform scaleX="+transform.scaleX+", scaleY="+transform.scaleY);
				bg = new SPBackgroundStruct(bgUrl, id, thumbUrl, desc, catId, transform);
				//var extension:String = bgUrl.slice(bgUrl.lastIndexOf(".") + 1);
				//if (extension == "flv") bg.typeId = SPBackgroundStruct.VIDEO_TYPE;
				//else bg.typeId = SPBackgroundStruct.IMAGE_TYPE;
				bg.type = bgXML.@TYPE;
				arr.push(bg);
			}
			return(arr);
		}
		
//--------------------------------------------------------------

		public function getAccountBackgroundsByType(callback:Function, typeName:String = null) {
			if (typeName == null) typeName = SPBackgroundStruct.ALL_TYPES;
			if (accountBgArr == null) {
				var rand=Math.floor(Math.random()*100000);
				var url:String;
				if (SessionVars.loggedIn) 
					url = SessionVars.localBaseURL + "getAccBackgrounds.php?as=3&rand=" + rand + "&accId=" + SessionVars.acc;
				else
				{
					url = SessionVars.localBaseURL+"getUploaded.php?type=bg&as=3&rand="+rand;
				}
				XMLLoader.loadXML(url, gotAccountBackgrounds, callback, typeName);
			}
			else callback(filterByType(accountBgArr, typeName));
			
			/*
			 * var url:String;
				var rand:String = Math.floor(Math.random() * 100000).toString();
				if (SessionVars.loggedIn) url=SessionVars.localBaseURL+"getAccAudios.php?rand="+rand+"&accId="+SessionVars.acc;
				else url=SessionVars.localBaseURL+"getUploaded.php?type=audio&rand="+rand;
				XMLLoader.loadXML(url, gotAccountAudios, callback,isGetAllAudios)
				*/
			
		}
		
		private function gotAccountBackgrounds(_xml:XML, callback:Function,typeName:String) {
			accountBgArr = parseBgXML(_xml,PRIVATE_CATEGORY, this);
			callback(filterByType(accountBgArr, typeName));
		}
		
		private function filterByType(bgArr:Array, typeName:String):Array {
			if (typeName == SPBackgroundStruct.ALL_TYPES) return(bgArr);
			var arr:Array = new Array();
			var bg:SPBackgroundStruct;
			for (var i:int = 0; i < bgArr.length; i++) {
				bg = bgArr[i];
				if (bg.type == typeName) arr.push(bg);
			}
			return(arr);
		}
		
		public function removeAccountBackgroundWithId(id:int) {
			if (accountBgArr == null) return;
			var bg:SPBackgroundStruct;
			for (var i:int = 0; i < accountBgArr.length; i++) {
				bg = accountBgArr[i];
				if (bg.id == id) {
					accountBgArr.splice(i, 1);
					i--;
				}
			}
		}
		
		public function addAccountBackground(bg:SPBackgroundStruct) {
			if (accountBgArr == null) return;
			if (accountBgArr.indexOf(bg)==-1) accountBgArr.push(bg);
		}
		
		public function getLoadedAccountBackgroundArr():Array {
			return(accountBgArr);
		}
	}
	
}