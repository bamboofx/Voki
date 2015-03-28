package com.voki.panels {
	import com.oddcast.event.AlertEvent;
	import com.oddcast.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import com.voki.data.SessionVars;
	import com.voki.data.SPHostStruct;
	import com.voki.events.AssetIdEvent;
	import flash.external.ExternalInterface;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class BuyModelPopup extends MovieClip {
		public var buyUI:MovieClip;
		public var upgradeUI:MovieClip;
		public var basicMsg:MovieClip;
		public var buyBtn:SimpleButton;
		public var upgradeBtn:SimpleButton;
		public var tf_price:TextField;
		
		private var popupOpened:Boolean = false;
		private var curModel:SPHostStruct;
		private var pollTimer:Timer;
		private var startTime:int;
		private var expiryTimeLimit:int=0;
		private var isPolling:Boolean;
		
		//an array of model ids that the user has tried to buy
		//implement polling so that if the user buys one of them polling stops
		private var modelPollingIdArr:Array; 
		
		public function BuyModelPopup() {
			visible = false;
			gotoScreen(basicMsg);
			
			buyBtn=buyUI.buyBtn as SimpleButton;
			tf_price=buyUI.tf_price as TextField;
			upgradeBtn=upgradeUI.upgradeBtn as SimpleButton;
			
			buyBtn.addEventListener(MouseEvent.CLICK, onBuy);
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgrade);
			
			pollTimer = new Timer(30000, 1);
			pollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, pollServer);
			modelPollingIdArr = new Array();
		}
		
		public function openWithModel($model:SPHostStruct) {
			popupOpened = true;
			var isNewModel:Boolean = ($model == null || curModel == null || $model.id != curModel.id);
			curModel = $model;
			if (SessionVars.mode==SessionVars.PARTNER_MODE&&!SessionVars.loggedIn) {
				gotoScreen(basicMsg)
				visible=true;			
			}
			else if (SessionVars.level<1) {
				gotoScreen(upgradeUI);
				visible=true;
			}
			else {
				gotoScreen(buyUI);
				if (isNewModel) {
					//get the price of the model before showing the popup
					var url:String=SessionVars.baseURL+"getModelPrice/modelId="+curModel.id+"&doorId="+SessionVars.doorId;
					XMLLoader.loadXML(url, gotPrice);
				}
				else visible = true;
			}
		}
		
		public function closeWin() {
			popupOpened = false;
			visible = false;
		}
		
		private function gotoScreen(mc:MovieClip) {
			buyUI.visible = (mc == buyUI);
			upgradeUI.visible = (mc == upgradeUI);
			basicMsg.visible = (mc == basicMsg);
		}
		
		private function gotPrice(_xml:XML) {
			var priceStr:String = _xml.@PRICE;
			
			//convert string to money format
			if (priceStr.indexOf(".")==-1) priceStr+=".00";
			else if (priceStr.length-priceStr.indexOf(".")==1) priceStr+="00";
			else if (priceStr.length-priceStr.indexOf(".")==2) priceStr+="0";
			if (priceStr.indexOf("$")==-1) priceStr="$"+priceStr;

			tf_price.text=priceStr;
			if (popupOpened) visible=true;
		}
		

//---------------------------------------------  CALLBACKS  ----------------------------------------
		
		private function onUpgrade(evt:MouseEvent) {
			openStoreURL();
		}
		
		private function onBuy(evt:MouseEvent) {
			if (SessionVars.mode==SessionVars.DEMO_MODE) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp212","You cannot purchase models in this demo. When you sign up for SitePal, you will be able to add models to your account through the SitePal store."));
			}
			else {
				openStoreURL();
				addModelId(curModel.id);
			}
		}
		
		private function openStoreURL() {
			trace("BuyModelPopup::openStoreURL - " + SessionVars.level);
			
			var url:String = "";
			if (SessionVars.level==0) {
				url = SessionVars.adminURL + "redirector.php?gotostore=1&accID=" + SessionVars.acc + "&page=upgrades.php&departmentSku=SITEPAL_EN";
			}else {
				url = SessionVars.adminURL + "redirector.php?gotostore=1&accID=" + SessionVars.acc + "&page=additionalModels.php&modelId=" + curModel.id;
			}
			
			var req:URLRequest = new URLRequest(url);
			if (!ExternalInterface.available) {
				trace("BuyModelPopup::openStoreURL - ExternalInterface NOT available url='"+url+"'");
				navigateToURL(req, "_blank");					
			} else {
				trace("BuyModelPopup::openStoreURL - ExternalInterface IS available");
				var strUserAgent:String = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
				if ( (strUserAgent.indexOf("firefox")!=-1) || ((strUserAgent.indexOf("msie")!=-1) && (uint(strUserAgent.substr(strUserAgent.indexOf("msie") + 5, 3)) >= 7) ) ) {
					trace("BuyModelPopup::openStoreURL - ExternalInterface.call url='"+url+"'");
					ExternalInterface.call("window.open", req.url, "_blank");
				} else {
					trace("BuyModelPopup::openStoreURL - navigateToURL url='"+url+"'");
					navigateToURL(req, "_blank");
				}
			}					
		}
		
//---------------------------------------------  BUY MODEL POLLING  ----------------------------------------

		private function addModelId(id:int) { //adds id to array and starts polling
			if (modelPollingIdArr.indexOf(id)==-1) { //make sure it isn't already in the array
				modelPollingIdArr.push(id);
				startPolling();
			}
		}
		
		private function removeModelId(id:Number) {
			var pos:int = modelPollingIdArr.indexOf(id);
			if (pos >= 0) modelPollingIdArr.splice(pos, 1);
			if (modelPollingIdArr.length == 0) stopPolling();
		}
		
		private function startPolling() {
			startTime = getTimer();
			if (!isPolling) {
				isPolling = true;
				pollServer();			
			}
		}
		
		private function stopPolling() {
			modelPollingIdArr = new Array();
			isPolling = false;
			pollTimer.stop();
		}
		
		// ping server
		private function pollServer(evt:TimerEvent=null) {
			if (modelPollingIdArr.length>0) {
				var pollUrl:String = SessionVars.adminURL+"checkModelStatus.php?acc="+SessionVars.acc+"&ids="+modelPollingIdArr.join(",");
				XMLLoader.loadXML(pollUrl,onPollingResponse);
			}
			else stopPolling();
		}
		
		// response received
		private function onPollingResponse(_xml:XML) {
			if (_xml.@RES!="OK") {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp210","Error Loading Polling XML"));
				return;
			}
			
			if (expiryTimeLimit<=0) expiryTimeLimit = parseInt(_xml.@TIMEOUT.toString());
			var pollRate:Number = parseFloat(_xml.@POLL_INTERVAL.toString()) * 1000;
			if (isNaN(pollRate)||pollRate<100) {
				dispatchEvent(new AlertEvent(AlertEvent.ERROR, "sp211","Invalid Poll Rate Value"));
				return; //on error
			}
			else pollTimer.delay = pollRate
			
			var modelId:int;
			var isBought:Boolean;
			var modelXML:XML;
			for (var i = 0; i < _xml.MODEL.length(); i++) {
				modelXML = _xml.MODEL[i];
				isBought=(modelXML.@BOUGHT=="1")
				if (isBought) {
					modelId=parseInt(modelXML.@ID.toString());
					removeModelId(modelId);
					//if (modelId==curModel.id) closeWin();
					dispatchEvent(new AssetIdEvent(AssetIdEvent.MODEL_PURCHASED, modelId));
				}
			}
			
			//check for timeout
			var elapsedSec:Number = (getTimer()-startTime)/1000;
			if (elapsedSec>expiryTimeLimit || modelPollingIdArr.length==0) stopPolling();
			else {
				pollTimer.reset();
				pollTimer.start();
			}
		}
	}
	
}