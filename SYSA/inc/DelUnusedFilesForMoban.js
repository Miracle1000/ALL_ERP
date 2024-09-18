//提交和离开页面时删除无用的上传文件,可应用于各个引用eWebEditor的页面
//Create by 常明 at 2010-06-25
//修改文件列表
//修改/moban/upload.asp
//修改/moban/eWebEditor.asp
//新增/moban/DelUnusedFiles.asp
//新增/moban/GetUploadFileList.asp
//新增/Inc/DelUnusedFilesForMoban.js
/////////////////////////////////////////////
//版本变更记录
//暂无
////////////////////////////////////////////

var FlgDelAll=true;//用于区分是提交表单还是其他方式离开页面的标识变量
//由于<a href="javascript:void(0)"会触发onbeforeunload事件，所以这里需要判断一下
window.onbeforeunload=function DelAllUPFiles(event)
{
	var clickJs = false;
	var event = event = window.event || event;
	var targHref = window.document.activeElement.href;
	var ie = ! -[1, ];
	if(ie && targHref != null && targHref.indexOf("javascript:void(0)")>=0)
	{
		 clickJs = true;
	}
	
	if(!clickJs && FlgDelAll) 
	{
		GetUploadFileList(1);
		DeleteFileList=UploadFileList;
		DeleteUnusedFiles();
	}
}

var UploadFileList = "";//用于保存所有上传文件的文件名
var DeleteFileList = "";//用于保存所有待删除文件的文件名
var xmlHttpobj = false;
try 
{
  xmlHttpobj = new ActiveXObject("Msxml2.XMLHTTP");
} 
catch (e) 
{
  try 
  {
    xmlHttpobj = new ActiveXObject("Microsoft.XMLHTTP");
  } 
  catch (e2) 
  {
    xmlHttpobj = false;
  }
}
if (!xmlHttpobj && typeof XMLHttpRequest != 'undefined') 
{
  xmlHttpobj = new XMLHttpRequest();
}

//读取服务器端的Session变量中保存的已上传文件列表,结果放入变量UploadFileList
function GetUploadFileList(tindex)
{
  var url = "../moban/GetUploadFileList.asp?t="+tindex+"&"+Math.round(Math.random()*100);
  xmlHttpobj.open("GET", url, false);
  xmlHttpobj.setRequestHeader("If-Modified-Since","0");
  xmlHttpobj.onreadystatechange = function(){
	  if (xmlHttpobj.readyState == 4) 
	  {
	    UploadFileList = xmlHttpobj.responseText;
			xmlHttpobj.abort();
	  }
	}
  xmlHttpobj.send(null);  
}

//通过将已上传文件列表中的文件于当前编辑器中的代码比较得出待删除文件列表,结果放入变量DeleteFileList
function GetDeleteFileList()
{
  if(UploadFileList.length!=0)
  {
  	var AllContent = eWebEditor1.eWebEditor.document.body.innerHTML;
		var myReg=/<A href=\"(http:\/\/.*)?\/(.*\/)?moban\/upimages\/\d+.[A-Za-z0-9]+\" target=_blank><\/A>/gi ;
		var blankflist="";
		while(result = myReg.exec(AllContent))
		{
				blankflist+=blankflist==""?result[0].replace(/(<A href=\"(http:\/\/.*)?\/(.*\/)?moban\/upimages\/|\" target=_blank><\/A>|&nbsp;|<p>|<\/p>)/gi,""):","+result[0].replace(/(<A href=\"(http:\/\/.*)?\/(.*\/)?moban\/upimages\/|\" target=_blank><\/a>|&nbsp;|<p>|<\/p>)/gi,"");
		}

  	var arrFiles = UploadFileList.split(",");
  	for(var i=0 ;i<arrFiles.length;i++)
  	{
  		if(AllContent.indexOf(arrFiles[i])<0 || (","+blankflist+",").indexOf(","+arrFiles[i]+",")>=0)
  		{
  			DeleteFileList+=DeleteFileList==""?arrFiles[i]:","+arrFiles[i];
  		}
  	}
  }
}

//删除待删除文件列表中的文件
function DeleteUnusedFiles()
{
  var url = "../moban/DelUnusedFiles.asp?f="+DeleteFileList+"&r="+Math.round(Math.random());
  xmlHttpobj.open("GET", url, false);
  xmlHttpobj.setRequestHeader("If-Modified-Since","0"); //不缓存Ajax
  xmlHttpobj.onreadystatechange = function(){
	  if (xmlHttpobj.readyState == 4)
	  {
			xmlHttpobj.abort();
			DeleteFileList="";
			UploadFileList="";
	  }
  };
  xmlHttpobj.send(null); 
	return true;
}

//当用户因提交表单而离开页面时调用
function DelUnusedFilesBeforeSubmit()
{
	FlgDelAll=false;
	GetUploadFileList(0);
	GetDeleteFileList();
	DeleteUnusedFiles();
	return true;
}

//document.write("<button onclick='javascript:GetUploadFileList(1);alert(UploadFileList);'>GetUploadFileList</button>");
//document.write("<button onclick='javascript:GetUploadFileList(0);alert(UploadFileList);'>GetUploadFileList2</button>");

