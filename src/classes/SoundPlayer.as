/**********************************************************

This class is to replace V3 SoundPlayer_V3.as include file
It supports 4 types of sound playing:
1. streaming mp3 swf with or without lip data in swf
2. event sound 
3. streaming mp3 swf with lip data in swf (mobile)
4. event device sound (mobile)


***********************************************************/

import dataStructures.FIFOQueue;
import emotion;
import AudioMCListener;
//import util.OC_MovieClipLoader;
import EngineV3;

class SoundPlayer
{
	private var volume:Number;
	private var queue:FIFOQueue;
	private var lipData:Object;
	private var lipMapV2:Array;
	private var audioStartT:Number =0;
	private var audioPauseT:Number =0;
	private var audioResumeT:Number =0;
	private var totalPausedT:Number =0;
	private var soundObj:Sound
	private var audiosHolder:MovieClip;
	private var audiosIndex:Number = 1;
	private var defaultVolume:Number = 70;
	private var lipFPS:Number = 12;
	private var lipUpdateInt:Number = 50; //milisecond
	private var defaultLipFrames:Number = 16;
	private var silentLipUpdateInt:Number = 100;
	private var cycleInterval:Number;
	private var audioType:Number //0 - streaming, 1 - event sound, 2 - streaming mobile, 3 - event mobile
	private var defaultExt:String = ".swf";
	private var engineMC:EngineV3;
	private var lipframedMCs:Array;	
	private var mcListen:AudioMCListener;
	private var isTalking:Boolean = false;
	private var cacheAudios:Boolean = true;
	private var isStreaming:Boolean = true;
	private var isFrozen:Boolean = false;
	private var lastAudio:Object;
	private var silentTalk:Boolean = false;
	private var silentCounter:Number;
	private var interrupt:Boolean;
	private var pendingLoad:Number = 0;
	private var mcLoadArr:FIFOQueue;
	private var newWord:Boolean = false;
	public var addListener:Function;
	public var removeListener:Function;
	public var broadcastMessage:Function;
		
	
	function SoundPlayer(_mc:MovieClip,aType:Number)
	{
		//trace("SoundPlayer consturctor");
		AsBroadcaster.initialize(this);
		audioType = aType>0?aType:0; //streaming is default
		queue = new FIFOQueue();
		audiosHolder = _mc.createEmptyMovieClip("audiosHolder",999);
		soundObj = new Sound(audiosHolder);
		soundObj.setVolume(defaultVolume);
		audiosHolder.audioSeq = new FIFOQueue();
		mcLoadArr = new FIFOQueue();
		audiosHolder.audiosData = new Array();
		engineMC = EngineV3(_mc);		
		lipframedMCs = new Array();
		//the following movieclips are hardcoded for now but they should be
		//replace when the puppet will include the dave's registry class
		addLipFramedMC(engineMC.host.mouth.acc_mouth,"mouth");		
		addLipFramedMC(engineMC.host.facel,"facel");
		addLipFramedMC(engineMC.host.facer,"facer");
		
		//mcLoad = new OC_MovieClipLoader();
		mcListen = new AudioMCListener(this);	
		lipMapV2 = new Array(0,1,2,3,4,5,6,5,8,9,10,1,9,9,8,5);
		broadcastMessage("soundPlayerInit");
		
		
	}
	
	
	public function setAudioType(aType:Number):Void
	{
		audioType = aType;
	}
	public function playAudio(url:String, offsetT:Number, emoArr:Array):Void
	{
		//trace("SoundPlayer playAudio");
		silentTalk = false;
		queue.push({_url:url,offset:offsetT,emo:emoArr});
		pendingLoad++;
		switch(audioType)
		{
			case 0: //streaming swf
				isStreaming = true;
				playStreamingAudio();				
				break;
			case 1:
				isStreaming = false;
				playEventAudio();				
				break;
			case 2:
				isStreaming = true;
				playStreamingAudio(true);				
				break;
			case 3:
				isStreaming = false;
				playEventAudio(true);				
				break;
				
		}
		
	}
	
	private function playStreamingAudio(isMobile:Boolean):Void
	{
		//trace("SoundPlayer playStreamingAudio");
		cacheAudios = isMobile?true:false
		var audioObj:Object = queue.pop();
		var audioKey:String = stripChar(audioObj._url,new Array("/","|",":","."));
		var audioMC:MovieClip;
		var cached:Boolean = false;
		if (audiosHolder[audioKey])
		{
			audioMC = audiosHolder[audioKey]
			cached = true;
		}
		else
		{
			audioMC = audiosHolder.createEmptyMovieClip(audioKey,audiosIndex);		
		}
		audiosHolder.audioSeq.push(audioMC);
		audiosHolder.audiosData[audioKey] = {url:audioObj._url,lip:new Array(),startAt:audioObj.offset};
		audiosIndex = isMobile?audiosIndex:(audiosIndex+1); //increment for non mobile
		//var mcLoad:MovieClipLoader = new MovieClipLoader();
		
		if (cached)
		{
			//trace("audio cahced -> goto audioLoaded");
			audioLoaded(audioMC);
			
		}
		else
		{
			var mcLoad:MovieClipLoader = new MovieClipLoader()
			//mcLoadArr.push(mcLoad);
			mcLoad.addListener(mcListen);					
			//trace("loadClip "+audioObj._url+defaultExt+" into "+audioMC);

			mcLoad.loadClip(audioObj._url+defaultExt,audioMC);												
		}
	}
	
	//same as playStreamingAudio for now
	private function playEventAudio(isMobile:Boolean):Void
	{
		//trace("SoundPlayer playEventAudio");
		playStreamingAudio(isMobile);
	}
	
	public function audioLoadStarted(target_mc:MovieClip):Void
	{
		//trace("SoundPlayer started loading "+target_mc);
		broadcastMessage("speechDownloadStarted",target_mc);
	}
	
	public function audioLoaded(target_mc:MovieClip):Void
	{
		
		//trace("finished loading "+target_mc._name);				
		//trace("f1="+audiosHolder.audiosData[target_mc._name].lip["f1"]);
		//trace("f2="+audiosHolder.audiosData[target_mc._name].lip["f2"]);
		//trace("length="+audiosHolder.audiosData[target_mc._name]["lip"].length);
		//trace("target_mc.lip_string ="+target_mc.lip_string);
		if (target_mc.lip_string.length>0)
		{	
			
			pendingLoad--;
			var lv:Array = parseParam(target_mc.lip_string);			
			for(var i in lv)
			{
				
					
					audiosHolder.audiosData[target_mc._name].lip[i] = lv[i];					
					//trace(i+"->"+lv[i]+" =="+audiosHolder.audiosData[target_mc._name].lip[i]);
				
			}
			
			if (queue.getLength()==0 && pendingLoad==0)
			{	
				mcLoadArr.clear()
				playAudioSequence();
			}
		}
		else
		{
			var lv:LoadVars = new LoadVars();		
			var ptr = this;
			var tname:String = target_mc._name;
			lv.onLoad = function()
			{
				pendingLoad--;
				for (var v in this)
				{
					//trace("v="+v+", this[v]="+lv[v]+"-->"+typeof(lv[v]));
					if (typeof(this[v])!="function")
						ptr.audiosHolder.audiosData[tname].lip[v] = this[v];
				}
				if (queue.getLength()==0 && pendingLoad==0)
				{
					mcLoadArr.clear()
					ptr.playAudioSequence();
				}
				
			}
			lv.load(audiosHolder.audiosData[target_mc._name].url+".lip");	
		}
		
	}
	
	public function audioLoadError(target_mc:MovieClip):Void
	{
		//trace("error loading "+target_mc);
	}
	
	
	private function playAudioSequence(inSeq:Boolean)
	{
		//trace("playAudioSequence")
		if (isTalking) 
		{
			//trace("playAudioSequence exit:isTalking=true");
			return;
		}
		
		var currentAudio:MovieClip = audiosHolder.audioSeq.pop();
		var currentAudioData:Object = audiosHolder.audiosData[currentAudio._name];
		isTalking = true;				
		if (currentAudioData.startAt>0 && isStreaming)
		{
			currentAudio.gotoAndPlay(lipFPS*currentAudioData.startAt)
		}
		else if (isStreaming)
		{
			currentAudio.play();
		}
		else
		{
			//trace("event sound - gotoandstop 2")
			currentAudio.gotoAndStop(2);
		}
		clearInterval(cycleInterval);
		cycleInterval = setInterval(this,"updateLip",lipUpdateInt,currentAudio,currentAudioData);						
		if (!inSeq)
		{
			lastAudio = new Object();
			lastAudio.audioMC = currentAudio;
			lastAudio.audioData = currentAudioData;
			broadcastMessage("talkStarted");			
			audioStartT = getTimer();
		}
	}
	
	private function updateLip(audioMC:MovieClip,audioData:Object)
	{
	
		
		//trace("in updateLip audioMC="+audioMC+", audioMC._currentframe="+audioMC._currentframe);		
		var currentFrame:Number = isStreaming?audioMC._currentframe:getFrameNumber(getTimer(),audioMC._totalframes);
		//trace("------- currentFrame="+currentFrame)
		var lip:Number = audioData.lip["f"+currentFrame];
		var nextLip:Number = audioData.lip["f"+(currentFrame+1)];
		//trace(lipVersionConverter(lip,audioData.lip["lipversion"]))
		//trace("lip="+lip+" curFrame="+audioMC._currentframe+" of "+audioMC._totalframes+" lip[]="+audioData.lip["f"+audioMC._currentframe])
		if (audioMC._currentframe==audioMC._totalframes || currentFrame==-1 || audioMC==undefined || audioData.lip["f"+audioMC._currentframe]==undefined)
		{
			isTalking = false;
			broadcastMessage("audioPlayed",100,audioData.url);
			if (audiosHolder.audioSeq.getLength()>0)
			{
				newWord = true;
				broadcastMessage("audioDone",audioData.url);
				playAudioSequence(true);
			}
			else
			{
				audioSequenceEnded();
			}
		}
		else
		{
			
			moveLipMCFrame(lip,audioData.lip["lipversion"]);
			newWord = (lip==0 && nextLip==0)?true:false;
			engineMC._parent.onSpeechEvent();
				
			
			var percentPlayed:Number = Math.floor((audioMC._currentframe/audioMC._totalframes)*100)
			broadcastMessage("audioPlayed",percentPlayed,audioData.url);
		}
		
	}
	
	
	public function saySilent(t:Number):Void
	{
		//trace("in saySilent");
		silentTalk = true;
		silentCounter = getTimer()+(t*1000);		
		cycleInterval = setInterval(this,"randomLipMove",silentLipUpdateInt);
		
	}
	
	private function randomLipMove(t:Number):Void
	{
		
		
				
		if (silentCounter>getTimer())
		{
			moveLipMCFrame(random(defaultLipFrames)+1,2);
		}
		else
		{
			clearInterval(cycleInterval);
			moveLipMCFrame(1,2);
			silentTalk = false;
			
		}
		
	}
	
	public function setHostVolume(newVol:Number ):Void
	{
	    volume = newVol;
	    //trace('set volume'+volume);
	    soundObj.setVolume(volume);    
	}
	
	public function getHostVolume():Number
	{
		return volume;
	}
	
	public function getNewWord():Boolean
	{
		return newWord;
	}
	
	public function freeze():Void
	{
		if (isStreaming)
		{
			audioPauseT = getTimer();
			emotion.freeze();
			isFrozen = true;
			clearInterval(cycleInterval);	    	
			lastAudio.audioMC.stop();	    	
		}
		else
		{			
			stopAudio();
		}
	}
	
	public function resume():Void
	{
		if (lastAudio.audioMC._currentframe<lastAudio.audioMC._totalframes-1 && isFrozen && !silentTalk)
		{
			audioResumeT = getTimer();
			totalPausedT += audioResumeT-audioPauseT;
			clearInterval(cycleInterval);
			cycleInterval = setInterval(this,"updateLip",lipUpdateInt,lastAudio.audioMC,lastAudio.audioData); //start updating lip frames
			//lipsInt = _global.intManager.addIntObject(this,"updateLipsFrame",updateFrameInt);
			isFrozen = false;
			lastAudio.audioMC.play();
		}	
		else if (silentTalk)
		{		
			audioResumeT = getTimer();
			totalPausedT += audioResumeT-audioPauseT;
			silentCounter+=totalPausedT;
			clearInterval(cycleInterval);
			cycleInterval = setInterval(this,"randomLipMove",silentLipUpdateInt);
			isFrozen = false;
		}
	}
	
	public function stopAudio():Void
	{
		audioSequenceEnded()		
	}
	
	public function replay():Void
	{
		//trace("replay")
		if (isTalking) 
		{
			return
		}
		var currentAudio:MovieClip = lastAudio.audioMC;
		isTalking = true;				
		currentAudio.play();
		clearInterval(cycleInterval);
		cycleInterval = setInterval(this,"updateLip",lipUpdateInt,currentAudio,audiosHolder.audiosData[currentAudio._name]);						
		broadcastMessage("talkStarted",audiosHolder.audiosData[currentAudio._name].url);
		audioStartT = getTimer();		
	}
	
	public function getIsFrozen():Boolean
	{
		return isFrozen;
	}
	
	public function getIsTalking():Boolean
	{
		return isTalking;
	}
	
	public function setFPS(f:Number,isEvent:Boolean):Void
	{
		lipFPS = f;
		isStreaming = !isEvent;
		setAudioType(1);
		//trace("in setFPS "+f+", isStreaming="+isStreaming)
		/*
		if (f!=lipFPS)
		{
			trace("in setFPS isStreaming="+isStreaming)
			lipFPS = f;
			isStreaming = false;			
		}
		*/
	}
	
	public function MouthAndJawGotoAndStop(frame:Number)
	{
		engineMC.host.mouth.acc_mouth.gotoAndStop(frame);
		engineMC.jawMoverl.gotoAndStop(frame);
		engineMC.jawMoverr.gotoAndStop(frame);		
		//if(frame<6) trace("MouthAndJawGotoAndStop = "+frame);
	}
	
	public function addLipFramedMC(mc:MovieClip,name:String):Void
	{
		lipframedMCs[name] = mc;
	}
	
	private function moveLipMCFrame(lFrame:Number,lVersion:Number):Void
	{
		for (var i in lipframedMCs)
		{
			lipframedMCs[i].gotoAndStop(lipVersionConverter(lFrame,lVersion,lipframedMCs[i]));
		}
	}
	
	private function getFrameNumber(t:Number,maxFrame:Number):Number
	{
		//trace("maxFrame="+maxFrame)
		var ret:Number = Math.floor(((t-audioStartT-totalPausedT)/1000)*lipFPS);
		//trace("returned frame="+ret);
		return ret<maxFrame?ret:-1
	}
	
	private function parseParam(str:String):Array
	{
		var ret:Array = new Array();
		var pairs:Array = str.split("&");
		for (var i in pairs)
		{
			var varval:Array = pairs[i].split("=");
			ret[varval[0]] = varval[1];
		}
		return ret;
	}
	
	private function audioSequenceEnded():Void
	{
		clearInterval(cycleInterval);
		audioResumeT = 0;
		totalPausedT = 0;
		audioPauseT = 0;
		audioStartT = 0;
		queue.clear();
		isTalking = false;
		isFrozen = false;
		lastAudio.audioMC.gotoAndStop(1);
		//trace("isStreaming="+isStreaming)
		if (!isStreaming)
		{
			//trace("eventSound Stop");
			var eventSound:Sound = new Sound(lastAudio.audioMC);
			eventSound.stop();
		}
		audiosHolder.audioSeq.clear();	
		moveLipMCFrame(1,2);
		//trace("audioSequenceEnded");
		broadcastMessage("talkEnded");
		
	}
		
	
	private function lipVersionConverter(in_num:Number,lipVer:Number,mc:MovieClip):Number{
		//16 is the number of frames of the new lip/mouth
		//since the face may also be affected we check that it complies with 16 frames as well
		if (lipVer>=2 && mc.mouthVersion!=2 && mc._totalframes<16)
		{
			return lipMapV2[in_num];
		}
		else
		{
			return in_num;
		}
	}

	
	private function stripChar(str:String,chArr:Array):String
	{
		var lastPos:Number
		for (var ch in chArr)
		{
			while((lastPos = str.indexOf(chArr[ch]))!=-1)
			{
				str = str.substring(0,lastPos)+str.substr(lastPos+1)
			}
		}
		return str;
	}
	
	
	
}