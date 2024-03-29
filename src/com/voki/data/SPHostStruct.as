﻿package com.voki.data {
	import com.oddcast.assets.structures.HostStruct;
	import com.oddcast.data.IThumbSelectorData;
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.vhost.OHUrlParser;
	import com.oddcast.vhost.accessories.AccessoryData;
	import com.voki.engine.EngineV5;
	
	/**
	 * ...
	 * @author Sam Myer
	 */
	public class SPHostStruct extends HostStruct implements IThumbSelectorData {
		private static var tempCounter:int=1;
		private var _tempId:int = 0;		
		
		private var _thumbUrl:String;
		private var _isPrivate:Boolean = false;
		public var isOwned:Boolean = false;
		
		public var isAutoPhoto:Boolean = false;
		public var autoPhotoSessionId:int;
		public var charXml:XML = null;
		public var oa1Type:int=0;
		
		public var charId:int;
		public var level:int;
		public var is3d:Boolean = false;
		public var isDirty:Boolean; //flag to say if this model needs saving
		public var modelGenderId:int;
		public static const PRIVATE_CATEGORY:int = -999;
		
		private var initialAccArr:Array;
		private var undoInitialAccArr:Array;
		private var availableTypes:Array
		public var loadModelInfo:Boolean = true;
		private var _bModelInfoLoaded:Boolean;
		public static var typeNames:Array;
		
		private var genderId:int;
		
		public function SPHostStruct($charUrl:String,$modelId:int=0,$thumbUrl:String=null,$name:String="") {
			super($charUrl, $modelId);
			
			//engine= new EngineV5();
			_tempId=tempCounter;
			tempCounter++;
			
			thumbUrl=$thumbUrl;
			name = $name;
			catId = -1;
		}
		
		public function get thumbUrl():String {
			return(_thumbUrl);
		}
		
		public function set thumbUrl(s:String):void {
			_thumbUrl=s;
		}
		
		public function get modelId():int {
			return(id);
		}
		
		public function set modelId(n:int):void {
			id = n;
		}
		
		public function get hasId():Boolean {
			return(charId>0);
		}
		
		public function get tempId():int {
			//if (hasId) return(-1);
			//else return(_tempId);
			return(_tempId);
		}
		
		public function get isPrivate():Boolean {
			return(_isPrivate);
		}
		
		public function set isPrivate(b:Boolean):void {
			_isPrivate = b;
		}
		
		public function getInfoXML(callback:Function=null):void {
			trace("SPHostStruct::getInfoXML - callback="+is3d+","+ !loadModelInfo +","+ _bModelInfoLoaded );
			if (is3d || !loadModelInfo || _bModelInfoLoaded){
				callback();
				return;
			}
			trace("SPHostStruct::getInfoXML - "+OHUrlParser.getOHObject("url"));//
			var ohStr:String = OHUrlParser.getOHString(OHUrlParser.getOHObject("url")).split("/").join("|");
			SessionVars.localBaseURL = "http://vhss.oddcast.com/vhss_editors/";
			var url:String=SessionVars.localBaseURL+"getModelInfo.php?modelId="+modelId+"&oh="+ohStr+"&partnerId="+SessionVars.partnerId+"&accId="+SessionVars.acc;
			url ="http://vhss.oddcast.com/vhss_editors/getModelInfo.php?modelId=3336&oh=0|0|0|0|0|0|0|0|0|0|0|&partnerId=1&accId=1617243&demo=1";
			url = "test_model_info.xml";
			//if (model.getPrivate()) url+="&accId="+SessionVars.acc;
			//trace("calling getModelInfo: "+url)
			//if (!scene.model.getPrivate()) url+="&doorId="+SessionVars.doorId;
			if (SessionVars.mode==SessionVars.DEMO_MODE) url+="&demo=1"
			XMLLoader.loadXML(url,parseInfoXML,callback)		
		}
		
		public function parseInfoXML(_xml:XML,callback:Function=null):void {
			genderId=parseInt(_xml.@GENDER);
			//catId=parseInt(_xml.@CATID);
			
			availableTypes=new Array();
			initialAccArr = new Array();
			if (typeNames == null) typeNames = new Array();
			
			var xtype:int;
			var xacc:int;
			var xcomp:int;
			var xcat:int;
			var xtypeName:String;
			var xprivate:Boolean;
			var xpublic:Boolean;
			var acc:AccessoryData;
			
			var item:XML;
			for (var i:uint = 0; i < _xml.ITEM.length(); i++) {
				item = _xml.ITEM[i];
				xacc=parseInt(item.@ACCID);
				xtype=parseInt(item.@ID);
				xcomp=parseInt(item.@COMP)
				xcat = parseInt(item.@CATID);
				xtypeName=item.@TYPE;
				xprivate=(item.@PRIVAT=="1") //has private accessories
				xpublic = (item.@AVAILABLE == "1");// && int(item.@CATID)>0 //has public accessories
				trace("SPHostStruct:: "+xtypeName + " pub, pri = " + xpublic + ", " + xprivate);
				if (xpublic||xprivate) availableTypes.push({typeId:xtype,isPrivate:xprivate})
				typeNames[xtype]=xtypeName;
				if (xacc>0) {
					acc=new AccessoryData(xacc,"",xtype,"",xcomp);
					acc.catId = xcat;
					initialAccArr.push(acc);
				}
			}
			_bModelInfoLoaded = true;
			if (callback != null) callback();
		}
		
		public function getAvailableTypeIds():Array {
			var arr:Array = new Array();
			if (availableTypes != null)
			{
				for (var i:uint = 0; i < availableTypes.length; i++) {
					trace("SPHostStuct::getAvailableTypeIds " + availableTypes[i].typeId);
					var incompatFound:Boolean = false;
					for (var j:int = 0; j < initialAccArr.length; ++j)
					{
						var acc:AccessoryData = initialAccArr[j]
						if (acc.incompatibleWith == availableTypes[i].typeId)
						{
							incompatFound = true;
						}
					}
					if (!incompatFound)
					{
						arr.push(availableTypes[i].typeId);
					}
				}
			}
			return(arr);
			//return(availableTypes)
		}
		
		public function getInitialAccessories():Array {
			return(initialAccArr)
		}
		
		public function removeInitialAccessory(typeId:int):void
		{
			undoInitialAccArr = initialAccArr.slice();
			var tempArr:Array = new Array();//initialAccArr.slice();
			for (var j:int = 0; j < initialAccArr.length; ++j)
			{
				var acc:AccessoryData = initialAccArr[j]
				if (acc.typeId != typeId)
				{
					tempArr.push(acc);
				}
			}			
			initialAccArr = tempArr.slice()
		}
		
		public function undoRemoveInitialAccessory():void
		{
			initialAccArr = undoInitialAccArr.slice();
			undoInitialAccArr = null;
		}
		
		public function typeIsPrivate(typeId:Number):Boolean {
			if (availableTypes == null) return(false);
			for (var i:int=0;i<availableTypes.length;i++) {
				if (availableTypes[i].typeId==typeId) return(availableTypes[i].isPrivate)
			}
			return(false);
		}
		
		public function cloneForPlayer(newCharId:int = -1):HostStruct {
			if (newCharId == -1) newCharId = charId;
			var host:HostStruct = new HostStruct(url, newCharId, type);
			host.engine = engine;
			return(host);
		}
	}
	
}