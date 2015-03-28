package com.voki.data {
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.utils.XMLLoader;
	import flash.events.EventDispatcher;
	import com.oddcast.event.AlertEvent;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPModelList extends EventDispatcher{
		private var categoryArr:Array; //array of categories
		private var ownedModelIdArr:Array;  //array of ids of source models which are owned in this users account
		private var accModelArr:Array;		//array of custom models owned by this account
		private var modelsByCatArr:Array;	//array of models found in sourceModelArr indexed by catId and genderId.
		private var sourceModelArr:Array;	//unique array of models indexed by id
		
		public static var PRIVATE_CATEGORY:int=999;

		public function SPModelList() {
			modelsByCatArr = new Array();
			sourceModelArr = new Array();
		}
		
//-------------------------------------------------------------------------------------

		private function loadAccountModels(callback:Function):void {
			if (SessionVars.loggedIn) {
				var url:String = SessionVars.localBaseURL + "getAccModels.php?rand=" + Math.round(Math.random()*1000000) + "&as=3&accId="+SessionVars.acc;
				XMLLoader.loadXML(url,gotAccountModels,callback)
			}
			else {
				accModelArr = [];
				loadCategories(callback);
			}
		}

		private function gotAccountModels(_xml:XML,callback:Function):void {
			//this function is only called once per init and the account models are saved in the accModelArr array
			accModelArr = parseModelXML(_xml, true,PRIVATE_CATEGORY);
			loadCategories(callback);
		}
		
//-------------------------------------------------------------------------------------

		public function getCategoryArr(callback:Function) {
			if (accModelArr == null) {
				loadAccountModels(callback);
			}
			else loadCategories(callback);
		}
		
		public function removeAccountModelWithId(id:int) {
			if (accModelArr == null) return;
			var model:SPHostStruct;
			for (var i:int = 0; i < accModelArr.length; i++) {
				model = accModelArr[i];
				if (model.id == id) {
					accModelArr.splice(i, 1);
					i--;
				}
			}
		}
		
		private function loadCategories(callback:Function) {
			if (categoryArr != null) {
				callback(categoryArr);
			}
			else {
				var url:String=SessionVars.baseURL+"getModelCategories/partnerId="+SessionVars.partnerId+"/spFlag=1&doorId="+SessionVars.doorId;
				XMLLoader.loadXML(url, gotCategories, callback);
			}
		}
		
		private function gotCategories(_xml:XML,callback:Function) {
			categoryArr = parseCategories(_xml);
			if (accModelArr != null && accModelArr.length > 0) {
				var privateCat:SPCategory = new SPCategory(PRIVATE_CATEGORY, "Private");
				categoryArr.push(privateCat);
			}			
			categoryArr.sortOn("name", Array.CASEINSENSITIVE);
			for (var i:int = 0; i < categoryArr.length; ++i)
			{
				if (SPCategory(categoryArr[i]).name.charAt(0) == "0")
				{
					SPCategory(categoryArr[i]).name = SPCategory(categoryArr[i]).name.substr(1);
				}
			}
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
				if (catName.toLowerCase() == "all models")
				{
					catName = "0" + catName;
				}
				cat = new SPCategory(catId, catName);
				cat.gender = parseInt(subcats[i].@GENDER);
				catArr.push(cat);
				//if (cname=="All Models") ALL_CATEGORY=cid;
			}
			return(catArr);
		}
		
//--------------------------------------------------------------
		
		
		public function getModelsByCatId(callback:Function, catId:int, genderId:int = 0) {
			if (categoryArr == null) throw new Error("SPModelList::getModelsByCatId : You should load categories before making this call");
			
			//if this is the special "private" category, we already have the accModelArr array, so
			//no calls need to be made to the server.  populate the selector from that array
			//otherwise make a call to getModels.php
			if (catId==PRIVATE_CATEGORY) {
				callback(accModelArr);
			}
			else if (modelsByCatArr[catId] != undefined&&modelsByCatArr[catId][genderId]!=undefined) {
				callback(modelsByCatArr[catId][genderId]);
			}
			else {
				var url:String=SessionVars.baseURL+"getModels/partnerId="+SessionVars.partnerId+"/genId="+genderId+"&catId="+catId+"&spFlag=1&doorId="+SessionVars.doorId+"&as=3";
				XMLLoader.loadXML(url,gotModels,catId,genderId,callback)
			}
		}

		public function addPrivateModel(model:SPHostStruct):void
		{
			accModelArr.push(model);
		}
		
		private function gotModels(_xml:XML,catId:int,genderId:int,callback:Function) {
			var modelArr:Array = parseModelXML(_xml, false, catId);
			
			var model:SPHostStruct;
			for (var i:int = 0; i < modelArr.length; i++) {
				model = modelArr[i];
				if (sourceModelArr[model.id] == undefined) sourceModelArr[model.id] = model;
			}
			
			//add private models to "all" category
			//if (catId==ALL_CATEGORY) modelArr=modelArr.concat(accModelArr)
			
			if (modelsByCatArr[catId] == undefined) modelsByCatArr[catId] = new Array();
			modelsByCatArr[catId][genderId] = modelArr;
			
			callback(modelArr);
		}
		
		private function parseModelXML(_xml:XML,accModels:Boolean,catId:int):Array {
			
			if (_xml.localName() == "ERROR")
			{
				dispatchEvent(new AlertEvent(AlertEvent.FATAL,"sp701","The account you are logged into and the scene you are viewing do not match. Please close and reopen the editor from your account."));
				return new Array();
			}
			
			//returns an array of model objects
			//accModels is set to true to parse the getAccModels.php call - including the SOURCE=1/0 variable
			//accModles set to false to parse the getModels.php call
			var numModels:int=parseInt(_xml.@NUM);
			var thumbBaseUrl:String=_xml.@THUMB_BASE_URL;
			var ohBaseUrl:String = _xml.@OH_BASE_URL;
			var modelObjs:XMLList = _xml.MODEL;
			var i:int;
			var j:int;			
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
			
			var id:int;
			var level:int;
			var thumbUrl:String;
			var ohUrl:String
			var name:String;
			var model:SPHostStruct;
			var modelArr = new Array();
			
			if (accModels) ownedModelIdArr=new Array(); // !

			for (i=0;i<modelObjs.length();i++) {
				id = parseInt(modelObjs[i].@ID)
				
				//save memory if this source model is already parsed
				if (!accModels && sourceModelArr[id] != undefined) {
					modelArr.push(sourceModelArr[id]);
					continue;
				}
				
				//don't add this to account models, but mark this model id as owned for source models
				if (accModels&&modelObjs[i].@SOURCE=="1") {
					ownedModelIdArr.push(id);
					continue;
				}
				
				name=unescape(modelObjs[i].@NAME);
				level=parseInt(modelObjs[i].@LEVEL.toString());
				thumbUrl = thumbBaseUrl + modelObjs[i].@THUMB;
				engineId=parseInt(modelObjs[i].@ENGINEID.toString());
				if (int(modelObjs[i].@IS3D) == 1)
				{
					ohUrl = thumbBaseUrl + modelObjs[i].@OH;
				}
				else
				{
					ohUrl = ohBaseUrl + modelObjs[i].@OH;
					ohUrl = ohUrl.split("oh.swf").join("ohv2.swf");
					ohUrl = ohUrl.split("char.dev.oddcast.com").join("content.dev.oddcast.com/char");
				}
				
				model = new SPHostStruct(ohUrl, id, thumbUrl, name);
				model.level = level;
				model.catId = catId;
				model.isOwned = (model.level <= SessionVars.level);
				if (engineArr[engineId] != undefined) model.engine = engineArr[engineId];
				model.type = String("host_" + model.engine.type).toLowerCase();
				model.is3d = (int(modelObjs[i].@IS3D) == 1);
				trace("SitepalV5::SPModelList::parseModelXML set model.type to =" + model.type);
				model.modelGenderId = parseInt(modelObjs[i].@GENDERID.toString());
				
				if (accModels) {
					if (!SessionVars.photofaceSaveAllowed && model.is3d)
					{
						model.isOwned=false;
					}
					else
					{
						model.isOwned = true;
					}
					model.isPrivate=true;
					model.catId = PRIVATE_CATEGORY;					
				}
				else {
					if (ownedModelIdArr != null)
					{
						for (j=0;j<ownedModelIdArr.length;j++) {
							//check if model is in the list of owned models; if so, set it as owned
							if (model.id==ownedModelIdArr[j]) {
								model.isOwned=true;
								break;
							}
						}
					}
				}
				
				if (SessionVars.mode==SessionVars.DEMO_MODE) model.isOwned=true; //in demo mode you can't purchase models
				
				modelArr.push(model);
			}
			return(modelArr)
		}
		
	}
	
}