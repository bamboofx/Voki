class emotions.emotionMap{
	static var map = new Array(
		{name:"neutral",	id:0,	def:{browl:1, browr:1, eyel:1, eyer:1, makeupl:1, makeupr:1, mouth:1}},
		{name:"happy",		id:1,	def:{browl:2, browr:2, eyel:2, eyer:2, makeupl:2, makeupr:2, mouth:2}},
		{name:"sad",		id:2,	def:{browl:3, browr:3, eyel:3, eyer:3, makeupl:3, makeupr:3, mouth:3}},
		{name:"angry",		id:3,	def:{browl:4, browr:4, eyel:4, eyer:4, makeupl:4, makeupr:4, mouth:4}},
		{name:"thinking",	id:4,	def:{browl:2, browr:4, eyel:2, eyer:2, makeupl:2, makeupr:2, mouth:5}},
		{name:"surprised",	id:5,	def:{browl:2, browr:2, eyel:5, eyer:5, makeupl:5, makeupr:5, mouth:6}}
	);

	public static function getMap():Array{
		return map;
	}

}