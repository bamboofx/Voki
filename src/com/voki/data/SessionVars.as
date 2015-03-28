package com.voki.data {
	import com.oddcast.audio.CachedTTS;
	import com.oddcast.utils.OddcastSharedObject;	
	import com.voki.nav.NavigationController;
	
	import flash.display.LoaderInfo;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SessionVars {
		public static var acc:int;
		public static var showId:int;
		public static var sceneId:int;
		public static var slideIndex:int;
		public static var userId:int;
		public static var gAlert:int;
		public static var partnerId:int;
		public static var domain:String;
		public static var swfDomain:String;
		public static var contentPath:String;
		public static var localURL:String;
		public static var acceleratedURL:String;
		public static var navController:NavigationController;
		//public static var acceleratedURL, localURL:String;
		
		public static var localConnectionName:String;
		public static var sessionId:String;
		
		public static var doorId:int;
		public static var adminId:int;
		public static var level:int;
		public static var accountPin:uint;
		public static var otcURL:String;
		public static var otcAppName:String;
		public static var baseURL:String;
		public static var localBaseURL:String;
		public static var adminURL:String;
		public static var playerURL:String;
		private static var _trackingURL:String;
		public static var cacheURL:String;
		public static var userEmail:String;
		public static var ttsEnabled:Boolean
		//public static var isNewScene:Boolean;
		public static var loggedIn:Boolean;
		public static var adminMode:Boolean;
		public static var hasTracking:Boolean = false;
		public static var justRegistered:Boolean=false;
		public static var embedMode:Boolean;
		public static var ttsLimit:uint;		
		public static var audioTimeLimit:Number;
		public static var audioLimit:uint;
		public static var bgLimit:uint;
		public static var mode:String;
		public static var introURL:String;
		
		public static var charEdit_oh:String;
		public static var charEdit_name:String;
		public static var charEdit_pupId:String;
		public static var charEdit_charId:String;
		public static var charEdit_engineUrl:String;
		
		public static var origCharId:int;		
		
		public static var audioDirty:Boolean = false;
		
		public static var editorMode:String;
		public static var editorVer:String;
		
		//the following should be recevied from getAccountInfo
		public static var apcId:int = 52;		
		public static var apcBaseUrl:String = "http://autophoto.dev.oddcast.com/";
		public static var apcSwfBaseUrl:String = "http://content.dev.oddcast.com/autophoto/";
		public static var apcAccBaseUrl:String = "http://autophoto.dev.oddcast.com/";
		
		//public static var apcRetrieveUrl:String = "http://host.staging.oddcast.com/autophoto/getPFModelv2XML.php";
		public static var apEngineId:int = 2;
		public static var apEngineType:String = "3D";
		public static var apEngineUrl:String = "http://content.dev.oddcast.com/char/engines/3D/v1/engine3Dv1.2008.09.09.vhss.swf";// "http://content.dev.oddcast.com/char/engines/3D/v1/engineE3Dv1.2008.09.09.swf";
		public static var apControlUrl:String = "http://content.dev.oddcast.com/ccs1/customhost/3dtemp/ctl/si_race.ctl";
		public static var apSamSetUrl:String = "http://content.dev.oddcast.com/prod/ccs2/mam/de/84/de846.oa1";
		public static var apSamSetId:int = 7;
		public static var oa1_chunk_size:int = 30;
		public static const terms_url:String = "http://www.oddcast.com/user/terms_of_use.php";
		public static const sitepal_url:String = "http://www.sitepal.com";
		public static const oddcast_url:String = "http://www.oddcast.com";
		public static var photofaceSaveAllowed:Boolean;
		public static var defaultVoiceId:int = 3; //Julie (US)
		public static var defaultVoiceEngingId:int = 3; //Julie (US);
		
		public static var sharedObject:OddcastSharedObject;
		
		public static const NORMAL_MODE:String = "default";
		public static const DEMO_MODE:String = "demo";
		public static const PARTNER_MODE:String = "partner";
		public static const SITEPAL_SO_NAME:String = "sitepalv5";
		
		public static var initialPanel:String;
		
		//public static var accPanelDisabled:Boolean = false;
		
		public static function setLoaderInfo(swfInfo:LoaderInfo):void {
			var swfUrl:String = swfInfo.url;
			if (editorMode == "CharacterEditor")
			{
				charEdit_charId = swfInfo.parameters.gCharacterID;
				charEdit_name = swfInfo.parameters.gCharName;
				charEdit_oh = swfInfo.parameters.gCharacterURL;
				charEdit_pupId = swfInfo.parameters.gModelID;
				charEdit_engineUrl = swfInfo.parameters.gCharEngine;
				sceneId = swfInfo.parameters.gSl;
			} else if (editorMode == "SceneEditor")
			{
				slideIndex = swfInfo.parameters.gSlideIndex;
			}
			localURL = "http://"+unescape(swfInfo.parameters.gDS);
			acceleratedURL = "http://"+unescape(swfInfo.parameters.gAS);
						
			var firstDomainSlash:int = swfUrl.indexOf("/", 7);
			if (swfUrl.indexOf("content") == 7) {
				var secondDomainSlash:int = swfUrl.indexOf("/", firstDomainSlash + 1);
				swfDomain = swfUrl.slice(7, secondDomainSlash);
			}
			else swfDomain=swfUrl.slice(7,firstDomainSlash);
			
			//acc=parseInt(swfInfo.parameters.acc);
			showId = parseInt(swfInfo.parameters.gShow);
			for (var i:uint in swfInfo.parameters)
			{
				trace("SessionVars " + i + "=" + swfInfo.parameters[i]);
			}
			//userId = parseInt(swfInfo.parameters.gUserId);
			//adminId = userId;
			/*
			if (swfInfo.parameters.gEmail != null)
			{
				userEmail = Base64.decode(swfInfo.parameters.gEmail);
			}
			*/
			sessionId = swfInfo.parameters.PHPSESSID;
			loggedIn = sessionId != null;
			if (swfInfo.parameters.gMode == "partner") mode = PARTNER_MODE;
			else if (!loggedIn) mode=DEMO_MODE;
			else mode=NORMAL_MODE;
			doorId = swfInfo.parameters.doorId;
			if (swfInfo.parameters.panel != null)
			{
				initialPanel = swfInfo.parameters.panel;
			}
			/*
			lc_name=swfInfo.parameters._lc_name;			
						
			if (swfInfo.parameters.gLoggedIn=="0") loggedIn=false;
			else loggedIn=true;
			*/
			
			
			
			embedMode=(swfInfo.parameters.EmbedCode=="1")
			//trace("EMBED MODE = "+embedMode+"  from "+swfInfo.parameters.EmbedCode)
			
			partnerId = parseInt(swfInfo.parameters.PID);
			//partnerId=16;
			
			baseURL=acceleratedURL+"/php/vhss_editors/";
			localBaseURL=localURL+"/vhss_editors/";
			adminURL = localURL + "/admin/";
			
			//CachedTTS.setDomain(cacheURL);
			//CachedTTS.setServerFolder("c_fs");
			var d:Date = new Date();
			d.setFullYear(d.getFullYear()+3);
			try
			{
				sharedObject = new OddcastSharedObject(SITEPAL_SO_NAME, d);			
			}
			catch (e:Error)
			{
				trace("SHARED OBJECT ERROR !!! " + e.message);
				sharedObject = null;
			}
		}
		
		public static function setFromXML(_xml:XML):void {
			trace("SessionVars::setFromXML = '"+_xml+"'");
			doorId=parseInt(_xml.DOORID.@VAL);
			//adminId=parseInt(_xml.ADMINID.@VAL);
			otcURL=_xml.OTC.@VAL;
			otcAppName=_xml.OTCAPPNAME.@VAL;
			level=parseInt(_xml.LEVEL.@VAL);
			//domain=_xml.SERVER.@VAL;
			accountPin=_xml.ACCOUNTPIN.@VAL==""?0:parseInt(_xml.ACCOUNTPIN.@VAL);
			//userEmail=""//_xml.EMAIL.@VAL;
			if (partnerId<=0) partnerId=_xml.PARTNER_ID.@VAL;
			ttsEnabled=(_xml.TTS.@VAL=="1") //whether or not you can save tts
			contentPath = _xml.CONTENT.@URL;
			playerURL = contentPath+_xml.PLAYER.@VAL;
			introURL = _xml.INTRO.@URL+"editor=1/";
			cacheURL = _xml.CACHE.@URL;

			/*if (_xml.TRACKURL) {
				trackingURL=_xml.TRACKURL.@VAL;
				if (trackingURL.length>0) hasTracking=true;
			}*/
			ttsLimit=parseInt(_xml.TTSLIMIT.@VAL)
			audioTimeLimit=parseFloat(_xml.AUDIOSECONDSLIMIT.@VAL)
			audioLimit=parseInt(_xml.AUDIOLIMIT.@VAL)
			bgLimit=parseInt(_xml.BGLIMIT.@VAL)
			
			//hack - in partner the mode the level is actually 0 (FREE ACCOUNT), but for some reason Sergey
			//has to send me level 3 (GOLD ACCOUNT), so it must be manually set to zero
			if (mode==PARTNER_MODE&&!loggedIn) {
				level=0;
				//trace("SETTING LEVEL=0")
				
				//another hack! - tts not available in partner mode not logged in,
				//even if the PHP tells me it is
				ttsEnabled=false;
			}
			
			apcBaseUrl = _xml.AUTOPHOTO.@URL + "/";
			apcSwfBaseUrl = _xml.AUTOPHOTO.@APCURL;
			apcAccBaseUrl = _xml.AUTOPHOTO.@ACCURL;
			apcId = int(_xml.AUTOPHOTO.@APPID);
			oa1_chunk_size = int(_xml.OA1UPLOADSIZE.@VAL) > 0?int(_xml.OA1UPLOADSIZE.@VAL):oa1_chunk_size;
			apEngineId = int(_xml.AP_ENGINE.@ID);
			apEngineType = String(_xml.AP_ENGINE.@TYPE);
			apEngineUrl = String(_xml.AP_ENGINE.@URL);
			apControlUrl = String(_xml.AP_ENGINE.@CTL);
			apSamSetUrl = String(_xml.AP_ENGINE.@SAMSET);
			apSamSetId = int(_xml.AP_ENGINE.@SAMSETID);
			photofaceSaveAllowed = (_xml.PHOTOFACE.@VAL == "1");
			//acc=_xml=parseInt(_xml.ACCID.@VAL);
			
			CachedTTS.setDomain(cacheURL);
			CachedTTS.setServerFolder(_xml.CACHE.@CDIR);
		}
		
		public static function set trackingURL(url:String):void {
			_trackingURL=url;
			hasTracking = (_trackingURL!=null&&_trackingURL.length > 0);
		}
		public static function get trackingURL():String {
			return(_trackingURL);
		}
		
		public static function set noIntro(b:Boolean):void {
			if (sharedObject == null) return;
			var o:Object = sharedObject.getDataObject();
			o = o == null ? new Object() : o;
			o.appVer = editorVer;
			o.noIntro = b;
			sharedObject.write(o);			
		}
		public static function get noIntro():Boolean {
			if (sharedObject == null) return false;			
			else 
			{
				var o:Object = sharedObject.getDataObject();
				return o.noIntro;
			}
		}
		public static function set noSkinPromo(b:Boolean):void {
			if (sharedObject == null) return;
			var o:Object = sharedObject.getDataObject();
			o = o == null ? new Object() : o;
			o.appVer = editorVer;
			o.noSkinPromo = b;
			sharedObject.write(o);						
		}
		public static function get noSkinPromo():Boolean {
			if (sharedObject == null) return false;			
			else 
			{
				var o:Object = sharedObject.getDataObject();
				return o.noSkinPromo;
			}
		}
		
		public static function setSOVar(varName:String, val:Object):void
		{
			if (sharedObject == null) return;
			var o:Object = sharedObject.getDataObject();
			o = o == null ? new Object() : o;
			o.appVer = editorVer;
			o[varName] = val;
			sharedObject.write(o);						
		}
		
		public static function getSOVar(varName:String):Object
		{
			if (sharedObject == null) return false;			
			else 
			{
				var o:Object = sharedObject.getDataObject();
				return o[varName];
			}
		}
		
		public static function disablePanelByName(s:String, disable:Boolean = true):void
		{
			switch (s)
			{
				case "style":
					navController.setTabDisabledById(2, 1,true);
					break;
				case "color":
					navController.setTabDisabledById(2, 2, true);
					break;
				case "attributes":
					navController.setTabDisabledById(2,3, true);
					break;
				case "expressions":
					navController.setTabDisabledById(2,4, true);
					break;
				case "functions":
					navController.setTabDisabledById(5, 3, disable);
					break;
			}			
		}
		
		public static function selectPanelByName(s:String):void
		{
			switch (s)
			{
				case "color":
					navController.selectPanelById(1, 1);
					break;
				case "attributes":
					navController.selectPanelById(1,2);
					break;
				case "expressions":
					navController.selectPanelById(1,3);
					break;
			}			
		}
	}
	
}