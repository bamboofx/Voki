package com.voki.engine
{
	public class EngineV5Constants
	{
		public static const VERSION:Number = 1.1;
		public static const VERSION_INFO:String = "08/17/2009 Flash 9 AS3 engine";
		public static const DEFAULT_FPS:uint = 12; //12
		public static const AUDIO_FPS:uint = 12;
		public static const ANI_WHILE_TALKING_FPS_RATIO:Number = 0.5;
		public static const ATTACH_MODEL_TIMEOUT:uint = 80;
		public static const AGE_FRAMES:uint = 45;
		public static const MOUTH_FRAMES:uint = 16;
		public static const MOUTH_FRAMES_OLD:uint = 12;
		public static const HEAD_Y_MOVEMENT_DURING_SPEECH_RATIO:Number = 0.4;//1
		public static const HEAD_X_MOVEMENT_DURING_SPEECH_RATIO:Number = 0.4;//1
		public static const HEAD_NEW_GAZE_DURING_SPEECH_COUNT:Number = 20;//10
		public static const MOUSE_IDLE_RECENTER_TIME:Number = 2500; //miliseconds
		public static const DECIMAL_PLACES_OF_MODEL_MCS:uint = 2;
		public static const POSSIBLY_MISSING_MODEL_MCS:Array = new Array("browl","browr","hairl","hair_r");
		public static const MOUSE_FOLLOW_DELAY:int = 250;
		
		public static const ENGINE_SOUND_UPDATE_INTERVAL:uint = Math.floor(1000/AUDIO_FPS); //was 40		
		public static const ENGINE_SOUND_SAMPLE_RATE_RATIO:Number = 11025/44100; //sample rate hz: APS created mp3 are at 11025hz while flash play head jumps based on 44100		
		public static const ENGINE_SOUND_WORD_END_PERCENT:Number = 0.25;
		
		public static const ANIM_X_BOUND:Number = 300; //restrict head angular movement
		public static const ANIM_Y_BOUND:Number = 100; //restrict head angular movement
		public static const ANIM_CRACK:Number = 0.5; //crack between face halves
		public static const ANIM_SPEED:Number = 5; //speed of head movemenbt
		public static const ANIM_BREATH_RATIO:Number = 1;
		public static const ANIM_BREATH_SIGN:Number = 1;//which directrion will breathing start with (1 or -1)		
		public static const ANIM_DEFAULT_SCALE:Number = 100; //scale eyes, nose and mouth
		public static const ANIM_DIFF:Number = 1; //???
		public static const BLINK_RATE:int = 6;
		
		public static const ANIM_MAX_X:Number = 27; //max face x???
		public static const ANIM_MIN_X:Number = 20; //min face x???
		public static const ANIM_MAX_Y:Number = 6; //max face y???
		public static const ANIM_MIN_Y:Number = 0; //min face y???
		
		public static const ANIM_EYE_CENTER:Number = 31;
		
		public static const ANIM_CYCLES_UNTIL_RANDOM:int = 10;
		
		//autophoto (jake) parameters
		public static const AP_ANIM_EM:Number = 0.67; //eye movement
		public static const AP_ANIM_EM_RATIO:Number = 1;//eye movement ratio
		public static const AP_ANIM_MM_RATIO:Number = 1;//mouth movement ratio
		public static const AP_ANIM_BM_RATIO:Number = 1;//brow movment ratio
		public static const AP_ANIM_WHITE_LINE_COMPENSATION:Number = 0.8;//try to set as near to one without showing white crack line
		public static const AP_ANIM_WHITE_LIVE_PIXEL_COMPENSATION:Number = 0; //try 0.125 and set above to 1; requires face halfs to be origined on zero.
		public static const AP_ANIM_RECIPROCAL_SCALING:Boolean = false; //set to true for a  "better" way of scaling the face halfs
		public static const AP_ANIM_EYE_SCALING:Number = 0;
		public static const AP_ANIM_RESTRICT_TURNING:Number = 1;
		public static const AP_ANIM_XSCALE_FACTOR:Number = 30;
		public static const AP_ANIM_BACK_HAIR_X_DAMPEN:Number = 5;
		public static const AP_ANIM_BACK_HAIR_ROTATION_DAMPEN:Number = 1.5;
		
		public static const AP_ANIM_Y_OVERALL_FACTOR:Number = 0.5;
		public static const AP_ANIM_Y_HEAD_MOVE_FACTOR:Number = 0;
		public static const AP_ANIM_YSCALE_FACTOR:Number = 8;
		public static const AP_ANIM_Y_FEATURE_MOVE_FACTOR:Number = 0.35;
		public static const AP_ANIM_Y_EM_RATIO:Number = 2;
		public static const AP_ANIM_Y_BM_RATIO:Number = 1;
		public static const AP_ANIM_Y_NM_RATIO:Number = 2;
		public static const AP_ANIM_Y_MM_RATIO:Number = 2;
		public static const AP_ANIM_Y_NOSE_SCALE_RATIO:Number = 0;
		public static const AP_ANIM_NOSE_ROTATION_FACTOR:Number = 0;
		public static const AP_ANIM_Y_EYE_SCALE:Number = 1;
		
		public static const AP_ANIM_EYE_MAX_X:Number = 12;
		public static const AP_ANIM_EYE_MAX_Y:Number = 3;
		public static const AP_ANIM_EYE_X_FACTOR:Number = 25;
		public static const AP_ANIM_EYE_Y_FACTOR:Number = 13;
		public static const AP_ANIM_EYE_ELLIPTIC_MOVE:Number = -1;
		public static const AP_ANIM_EYE_GLINT_MOVE:Number = -1;
		public static const AP_ANIM_EYE_PUPIL:Number = 85;
		public static const AP_ANIM_EYE_PUPIL_SCALE:Number = 60;		
		
		public static const AP_ANIM_GLASSES_FACTOR:Number = -1;
		public static const AP_ANIM_GLASSES_LEFT_SCALE:Number = 1;
		public static const AP_ANIM_GLASSES_RIGHT_SCALE:Number = 1;
		public static const AP_ANIM_GLASSES_LEFT_POS:Number = 0;
		public static const AP_ANIM_GLASSES_RIGHT_POS:Number = 0;
		public static const AP_ANIM_GLASSES_Y_EYES_OFFSET:Number = 0;
		
		
		
	}
}