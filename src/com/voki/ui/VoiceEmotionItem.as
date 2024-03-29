﻿package com.voki.ui
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class VoiceEmotionItem 
	{
		
		private var emotionsArray:Array;
		private var voiceName:String;
		
		public function VoiceEmotionItem(  _voiceName:String, _availableEmotions:Array ):void 
		{
			validateArray( _availableEmotions );
			
			voiceName     = _voiceName;
			emotionsArray = _availableEmotions;
		}
		
		/**
		 * Returns the name of the voice.
		 */
		public function get VOICE_NAME():String 
		{
			return voiceName;
		}
		
		/**
		 * Returns an array containing the emotions supported by a voice.
		 */
		public function get EMOTIONS_ARRAY():Array
		{
			return emotionsArray;
		}
		
		/**
		 * Check to ensure that the contents of the array are strings. 
		 */
		private function validateArray( _array:Array ):void
		{
			for (var i:int = 0; i < _array.length; i++) 
			{
				if ( !(_array[i] is String) ) throw new Error( "The emotions array must only contain the name of an emotion as a string." );
			}
		}
		
	}
	
}