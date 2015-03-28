

//mains.as
//function doMain()
//{
trace("EngineV3::BackwardCompatible (UI_Models)");

	this.UI_Models = new Array();
	//trace("ENGINE -- create UI_Models "+this.UI_Models+"   "+this);
    this.initColor();
    this.initAcc(engineRef.host);
	this.initInterface();
	this.travel(engineRef.model,0);
	//engineRef.UI_Models = this.UI_Models;
	engineRef.host.UI_Models = this.UI_Models;
//}

function GroupsList(type,hostPath){
	this.ar = new Array();
	this.type=type;
	this.hostPath=hostPath;
}

function travel(obj,level){

	if (obj.emotional){
		emotion.registerListener(obj);
	}	
    for (var p in obj){
        if (typeof eval(obj+ "." + p) == "movieclip" && p != "sound" && p != "engine" && level<250){
        	this.travel(eval(obj+ "." + p),level+1);
        }
    }   

    if ( obj != this ){
    	this.c_grp.travelHandler(obj);
    	this.a_grp.travelHandler(obj)
        this.r_grp.travelHandler(obj);
    }
}


//interface.as

// range group class (FOR SIZES AND PARENT TO ALPHA AND ACCESSORIES)
function R_Group(name, high, low, varName, saveStr, type){
    this.name=name;
    this.high=high;
    this.low=low;
    this.varName=new String(""+varName);
    this.type=type;
    this.saveStr=saveStr;
}

//aging controlable group class
function AGE_Group(name, high, _hp){
	this.hostPath=_hp;
	this.base = R_Group;
	this.isEnabled = true;
	this.base(name, high, 1, name, name);
	delete this.base;
	this.constructor.prototype.__proto__ = R_Group.prototype;
	this.ar = new Array();
}

// alpha controlable group class
function AL_Group(name){
    this.base = R_Group;
    this.base(name,100,0,"",name);
    delete this.base;
    this.name = name;
    this.constructor.prototype.__proto__ = R_Group.prototype;
    this.ar = new Array();
}

// color controlable group class
function C_Group(name){
    this.name=name;
    this.saveStr=name;
    this.ar = new Array();
}


function initInterface(){
    this.acsrLoadedNum = 0;

    // INTERFACE OBJECTS INITAITION

    //***** RANGE GROUP (FOR SIZES AND PARENT TO ALPHA AND ACCESSORIES)

    R_Group.prototype.getValue = function(){
        if (this.type == 1 || this.type == 3)
		    return eval(this.varName)._xscale;
		if (this.type == 2)
        	return eval(this.varName)._yscale;
    }

    R_Group.prototype.setValue = function(value){
        if (this.type == 1 || this.type == 3)
        	eval(this.varName)._xscale=value;
        if (this.type == 2 || this.type == 3)
        	eval(this.varName)._yscale=value;
        if (this.name == "head height")
        	eval(this.varName)._parent.backhair._yscale=value;
        if (this.name == "head width")
        	eval(this.varName)._parent.backhair._xscale=value;
    }

    this.r_grp = new GroupsList("range",engineRef.host);

    this.r_grp.configHandler = function(configObj){
        for ( var i=0; i < this.ar.length; i++){
	        var confStr=this.ar[i].saveStr;
	        var confVal=(Number(configObj[confStr]) <= 0) ? 101 : configObj[confStr];
	        this.ar[i].setValue( confVal );
	    }
	}

    this.r_grp.travelHandler = function(obj){
		if (obj.al_grp != null ){
			grp_name=obj.al_grp;
			if ( this[grp_name] == null ){
				this[grp_name] = new AL_Group(grp_name);
				this.ar.push(this[grp_name]);
			}
			this[grp_name].ar.push(obj);
		}

	   if (obj.age_grp != null){
			grp_name=obj.age_grp;
			if (this[grp_name]==null){
				this[grp_name]= new AGE_Group(grp_name,obj._totalframes, this.hostPath);
				this.ar.push(this[grp_name]);
			}
			this[grp_name].ar.push(obj);
		}
	}

    this.UI_Models.push(this.r_grp);
	//trace("ENGINE ---- UI MODELS  push r_grp: "+this.UI_Models);

    this.r_grp.ar.push( new R_Group("mouth", 150, 50, engineRef.host.mouth,"mscale",3));
    this.r_grp.ar.push( new R_Group("nose", 150, 50, engineRef.host.nose,"nscale",3));
    this.r_grp.ar.push( new R_Group("shoulders", 130, 50, engineRef.model.body,"bscale",1));
    this.r_grp.ar.push( new R_Group("head height", 125, 75, engineRef.host,"hyscale",2));
    this.r_grp.ar.push( new R_Group("head width",125, 75, engineRef.host,"hxscale",1));


    AGE_Group.prototype.getValue = function(){
		return this.ar[0]._currentframe;
    }

    AGE_Group.prototype.setValue = function(value){
	    if (value == 101) value=1;
		for ( i=0; i < this.ar.length; i++){
			this.ar[i].gotoAndStop(value);
		}
		ftr=.3;
		this.hostPath.mouth.tt._yscale=this.hostPath.ttyo-((value*ftr)*3);
		this.hostPath.mouth.lips._yscale=this.hostPath.mouthyo-((value*ftr)*3);
    }

    //***** ALPHA GROUP

    AL_Group.prototype.getValue = function(){
        return this.ar[0]._alpha;
    }

    AL_Group.prototype.setValue = function(value){
    	if (value == 101) value = 0;
        for ( i=0; i < this.ar.length; i++){
            //trace("set ALPHA *** "+ this.ar[i]+"    value = "+value);
            this.ar[i]._alpha=value;
        }
    }
	this.mouthyo=this.mouth.lips._yscale;
	this.ttyo=this.mouth.tt._yscale;

}// INIT INTERFACE END

// A notification from a dependent group of clips (hair)
// if the dependent is a group than the call comes from an arbitrary member (hairl)
// used to trigger a change in the depending group (hat)
function    onFrameChnage(obj,dep){
    if (obj.lastFrame !=  obj._currentframe || obj.counter == 2){
        obj.counter++;
        //trace(" HAT : " + obj[dep] + " cur " + obj._currentframe + " last " + obj.lastFrame);
        if (obj.counter == 2){
            obj.gotoAndStop(obj._currentframe);
        }else{
            this.a_grp[dep].setEnabled(obj[dep]);
        }
    }
    obj.lastFrame=obj._currentframe;
    obj.stop();
}

//color.as

function initColor(){
	
	// color controlable group class
	this.c_grp = new this.GroupsList("color");
	this.c_grp.travelHandler = function(obj){
		if (obj.c_grp != null){
			this.addGroupMember(obj, obj.c_grp);
		}
	}

	this.c_grp.addGroupMember = function(in_obj, in_name){		
		grp_name=in_name;
		if ( this[grp_name] == null ){
			this[grp_name] = new C_Group(grp_name);
			this.ar.push(this[grp_name]);
		}
		this[grp_name].ar.push(in_obj);
	}

	this.c_grp.configHandler = function(configObj){
		for ( var i=0; i < this.ar.length; i++){
			var grp_name=this.ar[i].name;
			var tmp_bb=  getColorVal(grp_name,"b",configObj ) ;
			var tmp_rb=  getColorVal(grp_name,"r",configObj ) ;
			var tmp_gb=  getColorVal(grp_name,"g",configObj ) ;
			if (tmp_bb == "" || tmp_rb == "" || tmp_gb == "") continue;
			//trace(" CONFIGURE COLOR :  NAME "+ grp_name + " tmp_bb " + tmp_bb + " tmp_rb " + tmp_rb  + " tmp_gb " + tmp_gb);

			tmpCT = {bb:tmp_bb,rb:tmp_rb ,gb:tmp_gb};
			this.ar[i].setColor(tmpCT);
		}
	}

	this.UI_Models.push(this.c_grp);
	//trace("ENGINE ---- UI MODELS  push c_grp: "+this.UI_Models);
	
	function C_Group(name){
		this.name=name;
		this.saveStr=name;
		this.ar = new Array();
	}

	C_Group.prototype.setColor = function(transObj){
		for ( i=0; i < this.ar.length; i++){
			//trace("setColor ***"+ this.ar[i]+"   "+transObj.rb);
			tmpClr = new Color( this.ar[i]);
			tmpClr.setTransform({rb: transObj.rb, gb: transObj.gb, bb: transObj.bb});
		}
	}

	C_Group.prototype.getColor = function(){
		tmpColor=new Color( this.ar[0] );
		return tmpColor.getTransform();
	}

	function mouthColor(name){
		super(name);
	}

	mouthColor.prototype = new C_Group();

}

//accessoires.as

// acssesories controlable group class
function A_Group(name){    
    this.constructor.prototype.__proto__ = R_Group.prototype;
    this.ar = new Object();
}

//***** ACCESSORIES GROUP

A_Group.prototype.getValue = function(){
	return this.ar[0]._currentframe;
}

A_Group.prototype.setValue = function(value,target){
	for ( i=0; i < this.ar.length; i++){
		accH=this.ar[i];
		if (accH[value] == undefined){
			this.ar[i].acl.duplicateMovieClip( value);
			tmpItem=accH[value];			
			tmpItem.listener=target;
			target.counter++;
			tmpItem.holder.loadMovie(target.map.baseUrl+ this.name + accH.type + "/" + value + ".swf");////target.map[this.name].items[value-1]
		}else{
			// replace existing acc
		}
	}
}


function initAcc(target){
	//trace( " init accessories #################################### target = " + target);
	this.a_grp = new this.GroupsList("accessories");
	this.a_grp.listener=target;

	var rootURL = new String(engineRef.host._url);
	index=rootURL.lastIndexOf("/");
	if (this.rootURL.lastIndexOf("file")  == 0 && index == 6){
		this.rootURL="";
	}else{
		this.rootURL=this.rootURL.substring(0,index+1);
	}
	this.a_grp.travelHandler = function(obj){		
		if (obj.a_grp != null ){			
			grp_name=obj.a_grp;			
			if ( this[grp_name] == null ){
				this[grp_name] = new A_Group(grp_name);
				this.ar.push(this[grp_name]);
			} else if (this[grp_name].high == -1){
				this[grp_name].high=this.map[grp_name].items.length;// V1 obj._totalframes;
			}			
			this[grp_name].ar[obj.type]=obj;
		}
	}
	this.UI_Models.push(this.a_grp);
	//trace("ENGINE ---- UI MODELS  push a_grp: "+this.UI_Models);
}


