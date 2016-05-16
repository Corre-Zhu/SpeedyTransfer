// JavaScript Document


        	//苹果手机展示提示
        	if (navigator.userAgent.match(/iPhone/i)) {
        		base.getEle('iosNote').setAttribute("style", "display: block");
        	}
        	
        	//点击事件
        	var hasItem=false;
        	var sendDiv=base.getEle('send');
        	var recDiv=base.getEle('receive');
        	
        	sendButCan.onclick=function(){
        		recDiv.style.display='none';
        		sendDiv.style.display="block";
        		base.addCls(sendButton,'navact');
        		base.delCls(revButton,'navact');
        	}
        	
			revButton.onclick=function(){
				recDiv.style.display='block';
				sendDiv.style.display='none';
				base.addCls(revButton,'navact');
				base.delCls(sendButton,'navact');
        	}
        	
        	if(hasItem){
        		revButton.onclick();
        	}else{
        		sendButton.onclick();
        	}
        	
        	//发送等base.getEleFromCls(base.getEle('sendCan'),'sname')
        	var fileInput=base.getEle('file')
        	fileInput.onchange=function(){
        		file.uploadFile(this);
        	}
        	base.getEle('sendButCan').onclick=function(){
        		fileInput.click();
        	}
        	
        	//点击下载
               	var container_wj=base.getEle('container_wj');
        	var l=base.getEleFromCls(container_wj,'more_load')[0].getElementsByTagName('a')[0];

        	
        	l.onclick=function(evt){
        		evt=base.fixevt(evt);
        		if (navigator.userAgent.match(/Android/i)) {
        			var sign=confirm('是否零流量下载点传APP');
        		}else{
        			var sign=confirm('抱歉,当前点传只支持安卓系统,是否继续零流量下载点传APP');
        		}
        		if(!sign)
        			evt.preventDefault();
        	}