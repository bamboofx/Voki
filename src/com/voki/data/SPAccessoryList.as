﻿package com.voki.data {
	import com.oddcast.utils.XMLLoader;
	import com.oddcast.vhost.accessories.AccessoryData;
	import flash.events.EventDispatcher;
	import com.oddcast.event.AlertEvent;
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPAccessoryList extends EventDispatcher{
		private var modelId:int;
		private var typeId:int;
		private var isPrivate:Boolean;
		
		private var accountAccessoryArr:Array; //i.e. private accessories
		private var categoryArr:Array;
		private var accessoriesByCatArr:Array;
		
		public static const PRIVATE_CATEGORY:int = 999;
		public static const VIEW_ALL_CATEGORY:int = 0;
		
		public function SPAccessoryList($modelId:int,$typeId,$isPrivate:Boolean) {
			modelId = $modelId;
			typeId = $typeId;
			isPrivate = $isPrivate;
			
			accessoriesByCatArr = new Array();
		}
		
//-------------------------------------------------------------------------------------

		private function loadAccountAccessories(callback:Function) {
			if (isPrivate) {
				//private types can have public and private accessories
				var url=SessionVars.localBaseURL+"getAccAccessories.php?modelId="+modelId+"&typeId="+typeId+"&as=3&accId="+SessionVars.acc;
				XMLLoader.loadXML(url, gotAccountAccessories,callback);
			}
			else {
				//public types only have public accessories - i.e. no private accessories
				accountAccessoryArr = [];
				loadCategories(callback);
			}
		}
		
		private function gotAccountAccessories(_xml:XML,callback:Function) {
			accountAccessoryArr = parseAccessories(_xml,PRIVATE_CATEGORY);
			loadCategories(callback);
		}
		
//-------------------------------------------------------------------------------------

		public function getCategoryArr(callback:Function) {
			if (accountAccessoryArr == null) {
				loadAccountAccessories(callback);
			}
			else loadCategories(callback);
		}
		
		private function loadCategories(callback:Function) {
			if (categoryArr != null) {
				callback(categoryArr);
			}
			else {
				var url=SessionVars.baseURL+"getAccessoryCategories/partnerId="+SessionVars.partnerId+"/modelId="+modelId+"&typeId="+typeId+"&doorId="+SessionVars.doorId;
				XMLLoader.loadXML(url, gotCategories, callback);
			}
		}
		
		private function gotCategories(_xml:XML,callback:Function) {
			categoryArr = parseCategories(_xml);
			
			//if there are private accessories, add a "private" category
			if (accountAccessoryArr != null && accountAccessoryArr.length > 0) {
				var privateCat:SPCategory = new SPCategory(PRIVATE_CATEGORY, "Private");
				categoryArr.push(privateCat);
			}
			
			//if there is more than one category, add a "view all" category
			if (categoryArr.length > 1) {
				var viewAllCategory = new SPCategory(VIEW_ALL_CATEGORY, "View All");
				categoryArr.push(viewAllCategory);
			}
			
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
				//if (cname=="All Models") ALL_CATEGORY=cid;
			}
			return(catArr);
		}
		
//-------------------------------------------------------------------------------------

		public function getAccessoriesByCatId(callback:Function,catId:int) {
			if (categoryArr == null) throw new Error("SPAccessoryList::getAccessoriesByCatId : You should load categories before making this call");
			
			//if this is the special "private" category, we already have the accModelArr array, so
			//no calls need to be made to the server.  populate the selector from that array
			//otherwise make a call to getModels.php
			if (catId==PRIVATE_CATEGORY) {
				callback(accountAccessoryArr);
			}
			else if (accessoriesByCatArr[catId] != undefined) {
				callback(accessoriesByCatArr[catId]);
			}
			else {
				var url:String=SessionVars.baseURL+"getAccessories/partnerId="+SessionVars.partnerId+"/modelId="+modelId+"&typeId="+typeId+"&catId="+catId+"&doorId="+SessionVars.doorId+"&as=3";
				XMLLoader.loadXML(url,gotAccessories,catId,callback)
			}
		}
		
		private function gotAccessories(_xml:XML, catId:int,callback:Function) {
			var accArr:Array=parseAccessories(_xml,catId);
			
			//add private accessories to "view all" category
			if (catId == VIEW_ALL_CATEGORY) accArr = accArr.concat(accountAccessoryArr);
			
			accessoriesByCatArr[catId] = accArr;
			
			callback(accArr);
		}

		private function parseAccessories(_xml:XML,catId:int):Array {
			if (_xml.localName() == "ERROR")
			{
				dispatchEvent(new AlertEvent(AlertEvent.FATAL,"sp701","The account you are logged into and the scene you are viewing do not match. Please close and reopen the editor from your account."));
				return new Array();
			}
			var baseUrl:String = _xml.@BASEURL;
			//baseUrl= "http://content.dev.oddcast.com/vhss_dev/ccs1/mam"; //hack until php scripts are completed
			//var accTypeId:int = AccessoryData.getTypeId(_xml.@TYPE);
			
			var acc:AccessoryData;
			var accArr:Array = new Array();
			var accXML:XML;
			var fragXML:XML;
			
			var xid:int;
			var xname:String;
			var xthumb:String;
			var xcompat:int;
			var fragUrl:String;
			
			for (var i = 0; i < _xml.ITEM.length(); i++) {
				accXML = _xml.ITEM[i];
				xid = parseInt(accXML.@ID);
				xname = accXML.@NAME;
				xthumb = baseUrl + accXML.@THUMB;
				xcompat = parseInt(accXML.@COMPATID);
				acc = new AccessoryData(xid, xname, typeId, xthumb, xcompat);

				for (var j = 0; j < accXML.FRAGMENT.length(); j++) {
					fragXML = accXML.FRAGMENT[j];
					fragUrl = baseUrl + fragXML.@FILENAME;
					//fragUrl = fragUrl.split("/fragment").join("/f9_fragment"); //hack until php scripts are completed
					acc.addFragment(fragXML.@TYPE, fragUrl);
				}
				acc.catId = catId;
				accArr.push(acc);
			}
			return(accArr);
		}
	}
	
}