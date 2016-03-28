// JavaScript Document
var xhr = new XMLHttpRequest();
     
    //监听选择文件信息
    function fileSelected() {
		//HTML5文件API操作
		var file = document.getElementById('fileToUpload').files[0];
		if (file) {
			var fileSize = 0;
            if (file.size > 1024 * 1024)
				fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
            else
				fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';
 			document.getElementById('fileName').innerHTML = 'Name: ' + file.name;
			document.getElementById('fileSize').innerHTML = 'Size: ' + fileSize;
			document.getElementById('fileType').innerHTML = 'Type: ' + file.type;
			uploadFile();
		}
	}
     
    //上传文件
    function uploadFile() {
          var fd = new FormData();
          //关联表单数据,可以是自定义参数
          fd.append("fileToUpload", document.getElementById('fileToUpload').files[0]);
 
          //监听事件
          xhr.upload.addEventListener("progress", uploadProgress, false);
          xhr.addEventListener("load", uploadComplete, false);
          xhr.addEventListener("error", uploadFailed, false);
          xhr.addEventListener("abort", uploadCanceled, false);
          //发送文件和表单自定义参数
          xhr.open("POST", "/ws/upload");
          xhr.send(fd);
        }
    //取消上传
    function cancleUploadFile(){
        xhr.abort();
    }
     
    //上传进度
    function uploadProgress(evt) {
          if (evt.lengthComputable) {
            var percentComplete = Math.round(evt.loaded * 100 / evt.total);
            document.getElementById('progressNumber').innerHTML = percentComplete.toString() + '%';
          }
          else {
            document.getElementById('progressNumber').innerHTML = 'unable to compute';
          }
    }
 
    //上传成功响应
    function uploadComplete(evt) {
        //服务断接收完文件返回的结果
        alert(evt.target.responseText);
    }
         
    //上传失败
    function uploadFailed(evt) {
         alert("上传失败");
    }
    //取消上传
    function uploadCanceled(evt) {
        alert("您取消了本次上传.");
    }