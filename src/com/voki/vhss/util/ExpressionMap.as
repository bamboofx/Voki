package com.voki.vhss.util
{
	import com.oddcast.host.api.Expression;
	
	public class ExpressionMap
	{
		/* 
		0 – neutral (stop all expressions. duration is not relevant if 0 is passed)
		1 – happy (closed mouth smile)
		2 – very happy (open mouth smile)
		3 – sad
		4 – angry
		5 – afraid
		6 – disgusted
		7 – surprised
		8 – thinking
		12 – embarrassed (blush)  
		*/
		//Thinking,RightWink,Scream,Sad,LeftWink,Fear,Angry,Surprise,ClosedSmile,OpenSmile,Disgust,Blush,Blink
		public static const exp_ar:Array = new Array("",
												Expression.CLOSED_SMILE,
												Expression.OPEN_SMILE,
												Expression.SAD,
												Expression.ANGRY,
												Expression.FEAR,
												Expression.DISGUST,
												Expression.SURPRISE,
												Expression.THINKING,
												"",
												"",
												"",
												Expression.BLUSH);
		

	}
}