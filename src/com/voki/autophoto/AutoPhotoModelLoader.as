﻿package com.voki.autophoto 
{
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.event.EngineEvent;
	import com.oddcast.host.api.API_Constant;
	import com.oddcast.host.api.EditLabel;
	import com.oddcast.host.api.EngineEventStrings;
	import com.oddcast.host.api.events.Event3DFileError;
	import com.oddcast.host.api.FileProgress;
	import com.oddcast.utils.TimerUtil;
	import com.oddcast.utils.Tracer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.*;
	import com.voki.data.SPHostStruct;
	import com.oddcast.event.ProcessingEvent;
	import com.voki.events.SceneEvent;
	
	/**
	 * ...
	 * @author jachai
	 */
	public class AutoPhotoModelLoader extends Sprite
	{
		private var loader3d:Loader;
		private var engine3d:MovieClip;
		private var curEngineUrl3d:String = null;
		public var api:*;
		private var modelToLoad:SPHostStruct;
		private var loadingEngine:Boolean=false;
		private var loadingModel:Boolean=false;
		private var loadingChar:Boolean = false;
		private var curModelUrl:String;	
		private var curModelCharXML:String;
				
		private var fileProgressArray:Array;
		private var progressPollingIntervalMS:Number = 250;
		
		public function AutoPhotoModelLoader() 
		{
			
		}
		
		public function loadModel(model:SPHostStruct) {			
			if (loadingEngine) return;			
			modelToLoad=model;			
			load3D();			
		}
		
		private function load3D() {			
			if (curEngineUrl3d==null||(modelToLoad.engine!=null&&modelToLoad.engine.url!=curEngineUrl3d)) {				
				load3DEngine();
			}
			else load3DModel();
		}
		
		private function load3DEngine() {
			loadingEngine=true;
			curEngineUrl3d=modelToLoad.engine.url;			

			if (loader3d==null) {
				loader3d=new Loader();
				loader3d.contentLoaderInfo.addEventListener(Event.COMPLETE, engine3DLoaded, false, 0, true);
				loader3d.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, engine3DLoadProgress, false, 0, true);
			}
			else loader3d.unload();
			loader3d.load(new URLRequest(curEngineUrl3d));
		}
		
		private function engine3DLoadProgress(evt:ProgressEvent) {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			progressEvent.message = "Loading Engine";
			progressEvent.percent = evt.bytesLoaded / evt.bytesTotal;
			dispatchEvent(progressEvent);
		}
		
		private function engine3DLoaded(evt:Event) 
		{							
			addChild(loader3d);
			var engine:*=loader3d.content as MovieClip;
			engine.init(engine);
			api = engine.getAPI();
			api.addEventListener("configDone",engineReady,false,0,true)			
		}
		
		private function engineReady(evt:Event) {			
			var ctlUrl:String = modelToLoad.engine.ctlUrl;			
			if (ctlUrl == null || ctlUrl == "") controlLoaded(null);
			else {
				api.addEventListener("processingEnded",controlLoaded,false,0,true);
				fileProgressArray = api.loadURLwithProgress(ctlUrl, EditLabel.U_CTL, API_Constant.UNDO_FLAGS_LOAD_CTL);
				TimerUtil.setInterval(controlProgress, progressPollingIntervalMS);
			}
		}
		
		private function controlProgress() {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			progressEvent.message = "Loading Control File";
			progressEvent.percent = calculatePercent(fileProgressArray);
			dispatchEvent(progressEvent);
		}
		
		private function controlLoaded(evt:Event) {
			TimerUtil.stopInterval(controlProgress);
			
			api.removeEventListener("processingEnded",controlLoaded);
			
			api.addEventListener(EngineEventStrings.TALK_STARTED,talkStarted,false,0,true)
			api.addEventListener(EngineEventStrings.TALK_ENDED,talkEnded,false,0,true)
			api.addEventListener(Event3DFileError.EVENT3D_FILE_ERROR,onEngine3dError,false,0,true)
			api.addEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted,false,0,true);
			api.addEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded,false,0,true);
			api.addEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded,false,0,true);
			//api.addEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_DOWN,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_UP,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_MOVE,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.CLICK,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.ROLL_OVER,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.ROLL_OUT,clickEvent,false,0,true);
			loader3d.content.addEventListener(MouseEvent.MOUSE_WHEEL,clickEvent,false,0,true);	
						
			loadingEngine=false;
		
			if (modelToLoad==null) {
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				//dispatchEvent(new ProcessingEvent(ProcessingEvent.DONE,"model"));
			}
			else load3DModel();
		}
		
		private function load3DModel() {
			var url:String=modelToLoad.url;
			if (url==curModelUrl||url==null) {
				if (modelToLoad.charXml != null) load3DCharacter();
				else dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				return;
			}
			loadingModel=true;
						
			curModelUrl = url;
			curModelCharXML = null;
			fileProgressArray=api.loadURLwithProgress(url,EditLabel.U_HEAD,API_Constant.UNDO_FLAGS_LOAD_ZIP);
		}
		
		private function load3DCharacter() {	
			var xmlStr:String = modelToLoad.charXml.toXMLString();
			//the same charXML may represent updated values.
			/*
			if (xmlStr == curModelCharXML) {
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				return;
			}
			*/
			trace("load3dCharacter:: " + xmlStr);
			loadingChar = true;
			curModelCharXML = xmlStr;
			fileProgressArray = api.loadXML(xmlStr);
		}
		
		private function onEngine3dError(evt:*) {
			trace("HostLoader::onEngine3dError - " + evt.toString());
			if (evt.fileDesc == Event3DFileError.FILE_DESC_MP3) talkError(evt);
			/*else if (evt.fileDesc.indexOf(Event3DFileError.FILE_DESC_ACC) == 0) {
				//this is caused by a file load error, not incompatilibility
				//accLoadError(evt);
			}*/
		}
		
		//events
		
		private function clickEvent(evt:MouseEvent) {
			dispatchEvent(evt);
		}
		private function talkStarted(evt:Event) {			
			dispatchEvent(new SceneEvent(SceneEvent.TALK_STARTED));
		}
		private function talkEnded(evt:Event) {			
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ENDED));			
		}
		private function talkError(evt:Event) {			
			dispatchEvent(new SceneEvent(SceneEvent.TALK_ERROR));
		}
		private function accLoaded(evt:Event) {			
			dispatchEvent(new SceneEvent(SceneEvent.ACCESSORY_LOADED));
		}
		
		private function processingStarted(evt:Event) {
			TimerUtil.setInterval(processingProgress,progressPollingIntervalMS);
		}
		private function processingProgress() {
			var progressEvent:ProcessingEvent = new ProcessingEvent(ProcessingEvent.PROGRESS, ProcessingEvent.MODEL);
			if (loadingModel) progressEvent.message = "Loading Head File";
			else if (loadingChar) progressEvent.message = "Loading Character";
			else progressEvent.message = "Loading Host - other process";
			progressEvent.percent = calculatePercent(fileProgressArray);
			dispatchEvent(progressEvent);
		}
		private function calculatePercent(progressArray:Array):Number {
			if (progressArray == null) return(0);
			var totalBytes:Number = 0;
			var loadedBytes:Number = 0;
			var progress:*;
			for (var i:int = 0; i < progressArray.length; i++) {
				progress = progressArray[i];
				totalBytes += progress.filesize;
				loadedBytes += progress.filesize*progress.progress;
			}
			if (totalBytes == 0) return(0);
			else return(loadedBytes / totalBytes);
		}
		
		private function processingEnded(evt:Event) {
			TimerUtil.stopInterval(processingProgress);
			
			Tracer.write("HostLoader::processingEnded - model=" + loadingModel + " char=" + loadingChar);
			
			if (loadingModel) {
				loadingModel=false;
				Tracer.write("HostLoader::processingEnded charXML = "+modelToLoad.charXml);
				if (modelToLoad.charXml==null) {
					Tracer.write("HostLoader::procesingEnded  ## dispatching configdone");
					dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
				}
				else load3DCharacter();
			}
			else if (loadingChar) {
				loadingChar=false;
				Tracer.write("HostLoader::procesingEnded  ## dispatching configdone");
				dispatchEvent(new SceneEvent(SceneEvent.CONFIG_DONE));
			}
		}
		
		public function setMask(in_mask:Sprite) {
			in_mask.visible=false;
			mask=in_mask;
		}
		
		/* removes and destroys all references to the engine, OA1 and loaders */
		public function destroy() {
			TimerUtil.stopInterval(controlProgress);
			TimerUtil.stopInterval(processingProgress);
			if (api!=null) {				
				api.removeEventListener("configDone",engineReady)			
				api.removeEventListener("processingEnded",controlLoaded);
				api.removeEventListener(EngineEventStrings.TALK_STARTED,talkStarted)
				api.removeEventListener(EngineEventStrings.TALK_ENDED,talkEnded)
				api.removeEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted);
				api.removeEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded);
				api.removeEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded);
				api.removeEventListener(EngineEventStrings.TALK_STARTED,talkStarted)
				api.removeEventListener(EngineEventStrings.TALK_ENDED,talkEnded)
				api.removeEventListener(Event3DFileError.EVENT3D_FILE_ERROR,onEngine3dError)
				api.removeEventListener(EngineEventStrings.PROCESSING_STARTED,processingStarted);
				api.removeEventListener(EngineEventStrings.PROCESSING_ENDED, processingEnded);
				api.removeEventListener(EngineEventStrings.ACCESSORY_ENDED, accLoaded);
				/*
				if (api.hasOwnProperty("getConfigController")&&api.getConfigController()!=null) {
					api.getConfigController().removeEventListener(EngineEvent.ACCESSORY_LOADED,accLoaded);
					api.getConfigController().removeEventListener(EngineEvent.ACCESSORY_INCOMPATIBLE, accLoadError);
				}
				*/
				api = null;
			}			
			if (loader3d != null && loader3d.contentLoaderInfo != null) {
				loader3d.contentLoaderInfo.removeEventListener(Event.COMPLETE, engine3DLoaded);
				loader3d.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, engine3DLoadProgress);
			}
			if (loader3d!=null&&loader3d.content!=null) {
				loader3d.content.removeEventListener(MouseEvent.MOUSE_DOWN,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_UP,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_MOVE,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.CLICK,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.ROLL_OVER,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.ROLL_OUT,clickEvent);
				loader3d.content.removeEventListener(MouseEvent.MOUSE_WHEEL, clickEvent);
				trace("HostLoader::destroy -- unloading 3d engine - " + loader3d.content as Object);
//				(loader3d.content as Object).unload();	// this throws errors, jake (engine developer) not sure what this is
				loader3d.unload();
				loader3d = null
			}
			curEngineUrl3d		= null;		// reload the engine
			curModelCharXML		= null;		// reload the model char
			curModelUrl			= null;		// reload the model 
		}
		
		/*	destroy the current loaded host while keeping the OA1 and engine,
		 * this forces the next load to be able to reload the same hosts xml only */
		public function destroy_host(  ):void 
		{
			curModelCharXML		= null;		// reload the model char
		}
	}
	
}