// JavaScript Document

	var base={
  	getEle:function (name,obj){  //以ID获取元素节点
  		var obj=obj || document;
  		return obj.getElementById(name);
  	},
  	addCls:function (obj,cn) {
  		return obj.className += " " + cn;
  	},
  	delCls:function (obj,cn) {
  		return obj.className = obj.className.replace(new RegExp("\\s*"+cn+"\\s*")," ");
  	},
  	hasCls:function (obj,cn) {
  		return (new RegExp("\\b"+cn+"\\b")).test(obj.className);
  	},
  	getEleFromCls:function(obj,cn){
  		var obj=obj || document;
  		var allNode=obj.getElementsByTagName("*");
  		var ret=[];
  		for(var i in allNode){
  			if(this.hasCls(allNode[i],cn)){
  				ret.push(allNode[i]);
  			}
  		}
  		return ret;
  	}
  }
  
  window.onload=function(){
  	var nav=base.getEleFromCls(document,'nav');
  	var container=base.getEleFromCls(document,'container');
  	var sign=0;
	
	function navClick(obj,i){
  		navId=obj.getAttribute('rel');
  		for(var i in container){
  			var defaultS=container[i].style.display;
  			container[i].style.display='none';
  			if(base.hasCls(container[i],'container'+navId)){
  				if(!defaultS||defaultS=='none')
  					container[i].style.display='block'
  				else
  					container[i].style.display='none';
  			}
  		}
  		if(sign&&i){
  			window.location.hash=navId;
  		}
  		sign=1;
  	}
	
  	for(i in nav){
  		nav[i].onclick=function(){
  			navClick(this,i);
  		}
  	}
  	
  	nav[0].onclick();
  }
