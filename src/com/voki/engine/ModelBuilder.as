package com.voki.engine
{
	
	import com.adobe.serialization.json.JSON;
	import com.voki.engine.events.ModelBuilderEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
		
	public class  ModelBuilder extends EventDispatcher{
		
		private var _mcModel:MovieClip;
		private var _mcMouth:MovieClip;
		private var _docRef:DisplayObjectContainer;
		private var _oModelVars:Object;
		private var _oHostVars:Object;
		private var _apiModel:*;
		
		private var _appDomain:ApplicationDomain;
		
		private var _oModelMap:Object;
		private var _arrModelClassMap:Array;
		private var _arrModelClassMCs:Array;
		private var _arrAnimHairMCs:Array;
		private var _arrAnimsMCs:Array;
		
		private var _timer:Timer;
		private var _bModelReady:Boolean;
		private var _bMouthColorable:Boolean;
		private var _nMouthVersion:Number;
		private var _bMouthEmbedded:Boolean; //autophoto
		private var _bModelBuilderError:Boolean;
		
		function ModelBuilder(api:*,appDomain:ApplicationDomain)
		{
			_bModelBuilderError = false;
			_timer = new Timer(EngineV5Constants.ATTACH_MODEL_TIMEOUT);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
			_timer.start();			
			_appDomain = appDomain;						
			_apiModel = api;			
			var mouthData:URLVariables = new URLVariables(_apiModel.getMouthData());
			_nMouthVersion = Number(mouthData.version);			
			_bMouthColorable = Number(mouthData.colorable)==1;
			//trace("EngineV5::ModelBuilder::ModelBuilder mouth colorable? "+_bMouthColorable);
			_arrModelClassMap = new Array();
			_arrModelClassMap["model"] = "Model";
			_arrModelClassMap["costume_f"] 	= "Costume_f";
			_arrModelClassMap["necklace_f"] = "Necklace_f";
			_arrModelClassMap["shoes_l"] 	= "Shoes_l";
			_arrModelClassMap["shoes_r"] 	= "Shoes_r";
			_arrModelClassMap["hair_l"] 	= "Hair_l";
			_arrModelClassMap["hair_r"] 	= "Hair_r";
			_arrModelClassMap["hair_b"] 	= "Hair_b";
			_arrModelClassMap["fhair_l"] 	= "Fhair_l";
			_arrModelClassMap["fhair_r"] 	= "Fhair_r";
			_arrModelClassMap["hat_l"] 		= "Hat_l";
			_arrModelClassMap["hat_r"] 		= "Hat_r";
			_arrModelClassMap["hat_b"] 		= "Hat_b";
			_arrModelClassMap["glasses_l"] 	= "Glasses_l";
			_arrModelClassMap["glasses_r"] 	= "Glasses_r";
			_arrModelClassMap["bottom_f"] 	= "Bottom_f";
			_arrModelClassMap["props_f"] 	= "Props_f";
			_arrModelClassMap["props_b"] 	= "Props_b";
			_arrModelClassMap["engine"] 	= "Engine";
			_arrModelClassMap["mouth_f"] 	= "Mouth_f";								
			_arrModelClassMCs = new Array();
			updateMirroredFragments();
			//hold instances of all model classes
			for (var i:String in _arrModelClassMap)
			{
				if (_arrModelClassMap[i] is Function) continue;
				//trace("EngineV5::ModelBuilder::"+i+"->"+_arrModelClassMap[i]);
				if (_appDomain.hasDefinition(_arrModelClassMap[i]))
				{
					var modelClass:Class = _appDomain.getDefinition(_arrModelClassMap[i]) as Class;
					var modelObj:Object = new modelClass();
					if (!modelObj.error)
					{
						_arrModelClassMCs[i] = modelObj;
					}
					else
					{
						trace("EngineV5::ModelBuilder Mouth is not an external accessory -> rmove from map list")
						_bMouthEmbedded = true;
						delete _arrModelClassMap[i];
					}
				}
				else
				{
					trace("EngineV5::ModelBuilder no definition of "+_arrModelClassMap[i]);
					delete _arrModelClassMap[i];
				}
			}
			
			_oModelMap = com.adobe.serialization.json.JSON.decode(_apiModel.getMap());
			_oModelVars = new Object();
			for (var j:String in _oModelMap["~mc"])
			{
				//trace("model vars *** "+j+"->"+_oModelMap["~mc"][j]);
				_oModelVars[j] = _oModelMap["~mc"][j];
			}
			_oHostVars = new Object();
			for (var k:String in _oModelMap["~mc~host"])
			{
				//trace("host vars *** "+k+"->"+_oModelMap["~mc~host"][k]);
				_oHostVars[k] = _oModelMap["~mc~host"][k];
			}
			//traceMap();									
		}
		
		public function build(doc:DisplayObjectContainer,modelClass:Object):MovieClip
		{
			_docRef = doc;	
			modelClass.visible = false;
			_mcModel = modelClass as MovieClip;		
			_mcModel.name = "model";
			
			_mcModel.addEventListener(Event.ADDED, modelDisplayObjectReady);
			
			_docRef.addChild(_mcModel);
			//_mcModel.addEventListener(Event.ADDED, modelDisplayObjectReady);
			_mcModel.gotoAndStop(2);
			
			//setTimeout(function(){iterateChildren(_mcModel);}, 3000);
			
			return _mcModel;
		}
		
		private function iterateChildren(container:DisplayObjectContainer):void
		{
			//trace("iterateChildren: "+ container.numChildren + '; '+ getQualifiedClassName(container) );
			for(var i:uint = 0; i<container.numChildren; i++){
				var child:* = container.getChildAt(i);
				//trace("iterateChildren: "+ child + '; '+ getQualifiedClassName(child) );
				objectReady(child);
				if(child is DisplayObjectContainer){
					if((child as DisplayObjectContainer).numChildren) iterateChildren(child as DisplayObjectContainer);
				}
					
			}
			
		}
		private function objectReady(obj:DisplayObject):void
		{	
			if(obj == null) return;
			if (obj is Shape)
			{
				return;
			}
			if (getQualifiedClassName(obj) == "Hair_b" || getQualifiedClassName(obj) == "Hair_l" || getQualifiedClassName(obj) == "Hair_r")
			{
				if (_arrAnimHairMCs == null) _arrAnimHairMCs = new Array();
				_arrAnimHairMCs.push(obj);
				//registerHairAnimations(obj, true);
			}
			if (obj.name.indexOf("attached")>=0)
			{
				//trace("EngineV5::ModelBuilder::modelDisplayObjectReady attached "+obj.name);
				
				(obj as MovieClip).stop(); //make sure to stop also attached movieclips
				return;
			}
			if (obj is MovieClip)
			{
				//trace("EngineV5::ModelBuilder::modelDisplayObjectReady loaded "+obj.name);
				findAnims(obj as MovieClip);
				
				
				//hide old stuff such as sound and eye managers
				if ((obj.name=="sound" || obj.name=="eyes" || obj.name=="engine") && obj.parent.name=="host")
				{
					obj.visible = false;
				}
				else
				{
					applyCodeFromMap(MovieClip(obj),MovieClip(obj.parent));
				}															
				
			}
		}
		public function getModelVar(varname:String):*
		{
			
			return _oModelVars[varname];
		}
		
		public function getHostVar(varname:String):*
		{
			//check in host and then in model
			if (_oHostVars[varname] is String)
			{
				return _oHostVars[varname];
			}
			else if (_oModelVars[varname] is String)
			{
				return _oModelVars[varname]
			}
			else
			{
				return null;
			}			
		}
		
		public function getMouthVersion():Number
		{
			return _nMouthVersion;
		}
		
		private function timerHandler(evt:TimerEvent):void
		{
			if(_mcModel.numChildren > 0 && _mcModel.getChildAt(0) != null) iterateChildren(_mcModel);
			else return;
			if (_bModelReady)
			{
				if (_bModelBuilderError)
				{
					_timer.stop();
					return;
				}
				
				_mcModel.visible = true;
				//trace("EngineV5::ModelBuilder::timerHandler calling ModelBuilderEvent.MODEL_READY");
				_mcModel.removeEventListener(Event.ADDED,modelDisplayObjectReady);				
				
				//trace('ModelBuilder::timerHandler _mcMouth='+_mcMouth);
				if (_bMouthColorable && _mcMouth!=null)
				{					
					
					_mcMouth.lips.c_grp = "mouth";
				}
				var modelReadyData:Object = new Object();
				modelReadyData.mouth = _mcMouth!=null?_mcMouth:new MovieClip();
				modelReadyData.autophoto = _bMouthEmbedded;
				dispatchEvent(new ModelBuilderEvent(ModelBuilderEvent.MODEL_READY,modelReadyData));
				startModelAnims();
				_timer.stop();
			}
			else
			{
				_bModelReady = true;
			}
		}
		
		private function updateMirroredFragments():void
		{			
			var urlVars:URLVariables = new URLVariables(_apiModel.getMirrored());
			for (var i:String in urlVars)
			{
				trace("EngineV5::ModelBuilder::updateMirroredFragments "+i+"-->"+urlVars[i]);
				//support both types of assignments left=right or right=left
				if (_arrModelClassMap[urlVars[i]].length>0)
				{
					//trace('_arrModelClassMap[urlVars[i]].length>0 map['+i+']='+_arrModelClassMap[urlVars[i]]); 
					_arrModelClassMap[i] = _arrModelClassMap[urlVars[i]];
					//_arrModelClassMap[urlVars[i]] = _arrModelClassMap[i];
				}
				/*
				else
				{ 
					trace('!! _arrModelClassMap[urlVars[i]].length>0');
					_arrModelClassMap[i] = _arrModelClassMap[urlVars[i]];
					
				}
				*/
			}
			
		}
		
		private function modelDisplayObjectReady(evt:Event):void
		{
			
			//trace("EngineV5::ModelBuilder::modelDisplayObjectReady -- "+getQualifiedClassName(evt.target)+" name: "+evt.target.name);
			
			if (evt.target is Shape)
			{
				return;
			}
			if (getQualifiedClassName(evt.target) == "Hair_b" || getQualifiedClassName(evt.target) == "Hair_l" || getQualifiedClassName(evt.target) == "Hair_r")
			{
				if (_arrAnimHairMCs == null) _arrAnimHairMCs = new Array();
				_arrAnimHairMCs.push(evt.target);
				//registerHairAnimations(evt.target, true);
			}
			if (evt.target.name.indexOf("attached")>=0)
			{
				//trace("EngineV5::ModelBuilder::modelDisplayObjectReady attached "+evt.target.name);
				
				evt.target.stop(); //make sure to stop also attached movieclips
				return;
			}
			if (evt.target is MovieClip)
			{
				//trace("EngineV5::ModelBuilder::modelDisplayObjectReady loaded "+evt.target.name);
				findAnims(evt.target as MovieClip);
						
				
				//hide old stuff such as sound and eye managers
				if ((evt.target.name=="sound" || evt.target.name=="eyes" || evt.target.name=="engine") && evt.target.parent.name=="host")
				{
					evt.target.visible = false;
				}
				else
				{
					applyCodeFromMap(MovieClip(evt.target),MovieClip(evt.target.parent));
				}															
				
			}
			/*
			if (evt.target.parent.name=="lips" || vt.target.parent.name=="tt")
			{
				trace("**************************** "+evt.target.name +" in "+evt.target.parent.name)
				MovieClip(evt.target.parent).stop();
				evt.target.stop();
			}
			*/
			
			_bModelReady = false;
		}
		
		private function startModelAnims():void
		{
			trace("MODEL BUILDER --- DO START MODEL ANIMS");
			if (_arrAnimsMCs)
			{
				for (var i:int = 0; i < _arrAnimsMCs.length; ++i)
				{
					var t_mc:MovieClip = MovieClip(_arrAnimsMCs[i]);
					trace("MODEL BUILDER --- name "+t_mc.name);
					if (t_mc.name.indexOf("anim_loop") == 0)
					{
						t_mc.play();
					}
					else if (t_mc.name.indexOf("anim_1x") == 0)
					{
						var t_stop_anim:Function = t_mc.stop;
						t_mc.addFrameScript(t_mc.totalFrames-1, t_stop_anim);
						t_mc.play();
					}
				}	
			}
		}
		
		public function findAnims(in_mc:MovieClip):void
		{
			//trace("ENGINE V5 :: ModelBuilder -- find anims "+in_mc.name+" childern num: "+in_mc.numChildren+" totalframes: "+in_mc.totalFrames);
			if(in_mc.name.indexOf("anim_") == 0)
			{
				if (_arrAnimsMCs == null) _arrAnimsMCs = new Array();
				_arrAnimsMCs.push(in_mc);
			}
			in_mc.stop();
			/* 
			if (in_mc.name.indexOf("anim_loop") != 0 && in_mc.name.indexOf("anim_1x") != 0)
			{
				in_mc.stop();
			}
			else if (in_mc.name.indexOf("anim_1x") == 0)
			{
				var t_stop_anim:Function = in_mc.stop;
				in_mc.addFrameScript(in_mc.totalFrames-1, t_stop_anim);
				//in_mc.addFrameScript(1, function():void{ trace("anim_ HI !! my name is "+this); });
				//in_mc.addEventListener(Event.ENTER_FRAME, function():void{trace("anim_ cf: "+in_mc.currentFrame)});
			} */
			if (in_mc.name != "sound" && in_mc.name != "eyes" && in_mc.name != "engine")
			{
				for (var i:int = 0; i < in_mc.numChildren; ++i)
				{
					if (in_mc.getChildAt(i) is MovieClip) findAnims(in_mc.getChildAt(i) as MovieClip);
				}	
			}
		}
		
		
		public function getHairAnimations():Array
		{
			return (_arrAnimHairMCs == null) ? new Array() : _arrAnimHairMCs;
		}
		
		public function getModelAnimations():Array
		{
			return (_arrAnimsMCs == null) ?  new Array() : _arrAnimsMCs;
		}
		
		private function applyCodeFromMap(mc:MovieClip,mcParent:MovieClip):void
		{
			if (mc==null || mcParent==null)
			{
				trace("EngineV5::ModelBuilder::applyCodeFromMap error");
				traceMap();				
				dispatchEvent(new ModelBuilderEvent(ModelBuilderEvent.MODEL_ERROR,"An error occured reading Map Data movieclips don't exist"));
			}
			for (var index:String in _oModelMap)
			{				
				var splitArr:Array = index.split("~");
				if (splitArr[splitArr.length-1]==mc.name)
				{
					//check the parent as well to make sure we read the correct mapped object
					//if doesn't match continue searching
					if (splitArr.length>1 && (splitArr[splitArr.length-2]!=mcParent.name && splitArr[splitArr.length-2].length>0))
					{
						continue;
					}
						//trace("EngineV5::ModelBuilder::applyCodeFromMap mc.name="+mc.name+" found in map");
						//copy vars
					for (var varName:String in _oModelMap[index])
					{
						//trace("EngineV5::ModelBuilder::applyCodeFromMap "+mc.name+"."+varName+"="+_oModelMap[index][varName]);
						mc[varName] = _oModelMap[index][varName];
						if (mc[varName]=="mouth" && _bMouthEmbedded)
						{
							trace("EngineV5::ModelBuilder::applyCodeFromMap mouth embedde4d "+mc.name+" (parnet="+mc.parent.name+")");
							if (_mcMouth==null)
							{
								_mcMouth = mc.acc_mouth;
							}
							try
							{
								_mcMouth[varName] = _oModelMap[index][varName];
							}
							catch (e:Error)
							{
								var errorStr:String = "A problem occured with the mouth. Could not find "+varName+" index="+index;
								dispatchEvent(new ModelBuilderEvent(ModelBuilderEvent.MODEL_ERROR,errorStr));
								//trace("EngineV5::ModelBuilderEvent.MODEL_ERROR "+errorStr);
								_bModelBuilderError = true;
							}								
						}
						else
						{
							if (varName=="a_grp") //found the a_grp code attach the accessory and hide generator 
							{
								if (mc.numChildren>0)
								{
									mc.getChildAt(0).visible = false;								
									var arrKey:String = mc[varName]+"_"+_oModelMap[index]['type'];								
									
									
									//trace("EngineV5::ModelBuilder::apllyCodeFromMap key in _arrModelClassMap["+(mc[varName]+"_"+_oModelMap[index]['type'])+"]");								
									trace("EngineV5::ModelBuilder apllyCodeFromMap arrKey="+arrKey+", mc.name="+mc.name+" isMovieClip?"+(mc is  MovieClip));//attach "+(mc[varName]+"_"+_oModelMap[index]['type']));
									_arrModelClassMCs[arrKey].name = mc.name+"_attached";																										
									var tempMC:DisplayObject = mc.addChild(_arrModelClassMCs[arrKey]);
									if (mc.name=="mouth")
									{
										_mcMouth = MovieClip(tempMC);
									}
									
								}
							}
						}
					}
				}
			}
		}
		
		public function destroy():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER,timerHandler);
				_timer = null;
			}
			if (_mcModel)
			{
				_mcModel.removeEventListener(Event.ADDED, modelDisplayObjectReady);
				removeAllDOCs(_mcModel);
				_mcModel = null;
			}
			if (_docRef)
			{
				removeAllDOCs(_docRef);
				_docRef = null;
			}
			if (_mcMouth)
			{
				removeAllDOCs(_mcMouth);
				_mcMouth = null;
			}
		}
		
		private function removeAllDOCs($doc:DisplayObjectContainer):void
		{
			trace("REMOVE ALL DOCs");
			while ($doc.numChildren > 0)
			{
				if ($doc.getChildAt(0) is DisplayObjectContainer && DisplayObjectContainer($doc.getChildAt(0)).numChildren > 0)
				{
					removeAllDOCs($doc.getChildAt(0) as DisplayObjectContainer);
				}
				$doc.removeChildAt(0);
			}
		}
		
		private function traceMap():void
		{
			for (var i:* in _oModelMap)
			{
				trace(i+"->"+_oModelMap[i]);
				for (var j:* in _oModelMap[i])
				{
					trace("		"+j+"-->"+_oModelMap[i][j]);
				}
			}
		}
		
	}
	
}