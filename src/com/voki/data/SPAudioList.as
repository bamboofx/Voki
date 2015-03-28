package com.voki.data {
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.AudioEffect;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.utils.XMLLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.oddcast.event.AlertEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPAudioList extends EventDispatcher {
		private var categoryArr:Array;
		private var accAudioArr:Array;		//array of user audios owned by this account
		private var audiosByCatArr:Array;	//array of arrays of default audios indexed by catId
		private var publicAudioArr:Array;
		private static var currentAudio:AudioData;
		public static var baseUrl:String;
		
		public static var PRIVATE_CATEGORY:int=999;

		public function SPAudioList():void {
			audiosByCatArr = new Array();
		}
		
//-------------------------------------------------------------------------------------
		public function getCategoryArr(callback:Function):void {
			loadCategories(callback);
		}
		
		private function loadCategories(callback:Function):void {
			if (categoryArr != null) {
				callback(categoryArr);
			}
			else {
				var url:String = SessionVars.baseURL + "getAudioCategories/partnerId=" + SessionVars.partnerId + "/doorId=" + SessionVars.doorId + "&levelId=" + SessionVars.level;
				XMLLoader.loadXML(url, gotCategories, callback);
			}
		}
		
		private function gotCategories(_xml:XML,callback:Function):void {
			categoryArr = parseCategories(_xml);
			var privateCat:SPCategory = new SPCategory(PRIVATE_CATEGORY, "Private");
			categoryArr.push(privateCat);
			categoryArr.sortOn("name",Array.CASEINSENSITIVE);
			//categoryArr.unshift(privateCat);
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
			return(catArr);
		}
//-------------------------------------------------------------------------------------
		private function loadAccountAudios(callback:Function,isGetAllAudios:Boolean=false):void {
			if (accAudioArr != null) {
				if (isGetAllAudios) privateAudiosLoaded(callback);
				else callback(accAudioArr);
			}
			else {
				var url:String;
				var rand:String = Math.floor(Math.random() * 100000).toString();
				if (SessionVars.loggedIn) url=SessionVars.localBaseURL+"getAccAudios.php?rand="+rand+"&accId="+SessionVars.acc+"&as=3";
				else url=SessionVars.localBaseURL+"getUploaded.php?type=audio&rand="+rand;
				XMLLoader.loadXML(url, gotAccountAudios, callback,isGetAllAudios)
			}
		}
	
		private function gotAccountAudios(_xml:XML,callback:Function,isGetAllAudios:Boolean):void {
			accAudioArr=parseAudioXML(_xml,true,-1,this);
			if (isGetAllAudios) privateAudiosLoaded(callback);
			else callback(accAudioArr);
			dispatchEvent(new Event("accountAudiosUpdated"));
		}
		
		public function removeAccountAudioWithId(id:int):void {
			if (accAudioArr == null) return;
			var audio:AudioData;
			for (var i:int = 0; i < accAudioArr.length; i++) {
				audio = accAudioArr[i];
				if (audio.id == id) {
					accAudioArr.splice(i, 1);
					i--;
				}
			}
		}
		
		public function addAccountAudio(audio:AudioData):void {
			if (audio == null||accAudioArr==null) return;
			accAudioArr.push(audio);
			dispatchEvent(new Event("accountAudiosUpdated"));
		}
		public function flushAccountAudios():void {
			accAudioArr = null;
		}
		public function getAccountAudioArr():Array { return(accAudioArr);}
//-------------------------------------------------------------------------------------

		public function getAudiosByCatId(callback:Function, catId:int, audioData:AudioData = null):void {
			if (categoryArr == null) throw new Error("SPAudioList::getAudiosByCatId : You should load categories before making this call");
			currentAudio = audioData;
			if (catId==PRIVATE_CATEGORY) {
				loadAccountAudios(callback,false);
			}
			else if (audiosByCatArr[catId] != undefined) {
				callback(audiosByCatArr[catId]);
			}
			else {
				var url:String=SessionVars.baseURL+"getAudios/partnerId="+SessionVars.partnerId+"/doorId="+SessionVars.doorId+"&levelId="+SessionVars.level+"&catId="+catId;
				XMLLoader.loadXML(url,gotAudios,catId,callback)
			}			
		}
		
		private function gotAudios(_xml:XML,catId:int,callback:Function):void {
			var audioArr:Array = parseAudioXML(_xml, false, catId, this);
			audiosByCatArr[catId] = audioArr;
			callback(audioArr);
		}
//-------------------------------------------------------------------------------------
		public function getAllAudios(callback:Function):void {
			loadAccountAudios(callback, true);
		}
		private function privateAudiosLoaded(callback:Function):void {
			if (publicAudioArr==null) {
				var url:String=SessionVars.baseURL+"getAudios/partnerId="+SessionVars.partnerId+"/doorId="+SessionVars.doorId+"&levelId="+SessionVars.level;
				XMLLoader.loadXML(url, gotPublicAudios, callback)
			}
			else publicAudiosLoaded(callback);
		}
		private function gotPublicAudios(_xml:XML, callback:Function):void {
			if (_xml != null) publicAudioArr = parseAudioXML(_xml, true, -1, this);
			publicAudiosLoaded(callback);
		}
		private function publicAudiosLoaded(callback:Function):void {
			callback(accAudioArr.concat(publicAudioArr));
		}
//-------------------------------------------------------------------------------------
		
		public static function parseAudioXML(_xml:XML,isPrivate:Boolean=true,catId:int=-1, p:* = null):Array {
			if (_xml.localName() == "ERROR")
			{
				p.dispatchEvent(new AlertEvent(AlertEvent.FATAL,"sp701","The account you are logged into and the scene you are viewing do not match. Please close and reopen the editor from your account."));
				return(new Array());
			}
			/*<AUDIOS RES="OK" BASEURL="http://vhss-a.oddcast.com/ccs2/vhss/user/b6a/" PHPSESSID="a62f7e998ce10490878a55b2ba7b99f0">
	<AUDIO ID="4650020" URL="37533/audio/1182348202540_37533" TYPE="upload" NAME="micrtest1"/>
	</AUDIOS>*/
			baseUrl =_xml.@BASEURL;

			var audioArr:Array = new Array();
			var audioXML:XML;
			var audio:AudioData;
			var audioUrl:String;
			var audioId:int;
			var audioType:String;
			var audioName:String;
			var bCurrentAudioInList:Boolean;
			for (var i:int = 0; i < _xml.AUDIO.length(); i++) {
				audioXML = _xml.AUDIO[i];
				audioUrl = baseUrl + audioXML.@URL;
				audioId = parseInt(audioXML.@ID);
				audioType = audioXML.@TYPE;
				try
				{
					audioName = decodeURI((unescape(audioXML.@NAME)));
				}
				catch(e:Error)
				{
					audioName = unescape((unescape(audioXML.@NAME)));
				}
				if (audioType == AudioData.TTS) {
					audio = new TTSAudioData(null, null, audioId, audioName);
					//treat this as non-TTS audio - manually set url since we don't have text and voice
					(audio as TTSAudioData).ttsMode = false;
					audio.url = audioUrl;
				}
				else audio = new AudioData(audioUrl, audioId, audioType, audioName);
				if (audioXML.@FX.toString().length>0) {
					audio.fx = AudioEffect.createFromCode(audioXML.@FX.toString());
				}
				audio.isPrivate = isPrivate;
				if (catId!=-1) audio.catId = catId;
				audioArr.push(audio);
				if (currentAudio != null)
				{
					if (audioId == currentAudio.id)
					{
						bCurrentAudioInList = true;
					}
				}
			}
			
			//if current audio is not in the list add it
			//taken away based on bug #1775
			/*
			if (!bCurrentAudioInList && currentAudio!=null)
			{
				currentAudio.name = "Current Audio";
				audioArr.push(currentAudio);
			}
			*/
			
			return(audioArr);
		}
	}
	
}