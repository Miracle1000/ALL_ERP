<!--
var isemail_cs=1;
var isemail_ms=1;
var isemail_qf=1;
var openSendTime=1;
var xmlHttp = GetIE10SafeXmlHttp();
function frameResize() {
    try {
        document.getElementById("cFF3").style.height = I2.document.documentElement.scrollHeight + 0 + "px";

    } catch (e) {
        parent.document.getElementById("cFF3").style.height = document.documentElement.scrollHeight + 0 + "px";

    }

}
function setparentheight() {
    frameResize();
}
function $(name){
	return document.getElementById(name);
}
function showmenu(self,showname){
	var tableObj=self.parentNode.parentNode;
	for(var i=0;i<tableObj.rows.length;i++){
		var tdObj=tableObj.rows(i).cells(0);
		if(tdObj==self){
			var old=tdObj.className;
			tdObj.className=(old=="menutab"?"menutab_hover":"menutab");
		}else if(tdObj==$(showname)){
			var old=tdObj.className;
			tdObj.className=(old=="menulist"?"menulist_hover":"menulist");
		}else{
			if(tdObj.id){
				tdObj.className="menulist";
			}else{
				tdObj.className="menutab";
			}
		}
	}
}
function switchMenu(self){
	var subobj=self.getElementsByTagName("ul")[0];
	if(self.className=="hover"){
		self.className="";
		subobj.style.display="none";
	}else{
		self.className="hover";
		subobj.style.display="block";
	}
}
function showHidaLeftMenu(self){
	var leftObj=$("leftmenuall");
	if(leftObj.style.display=="none"){
		leftObj.style.display="block";
		self.src="../images/hideleft.gif";
	}else{
		leftObj.style.display="none";
		self.src="../images/showleft.gif";
	}
}


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.getElementById("B").value;
	var C=document.getElementById("C8").value;
    var url = "../message/search_yh.asp?B="+escape(B)+"&C="+escape(C) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_cp();
  };
  xmlHttp.send(null);  
}
function updatePage_cp() {
  if (xmlHttp.readyState < 4) {
	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cp_search.innerHTML=response;
	xmlHttp.abort();
  }
}

function ajaxSubmit2(sort1){
    setTimeout("ajaxSubmit(2);",500);
}
function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//打开、关闭抄送
function email_cs(){
	if(isemail_cs==1)
	{	
		//if((document.getElementById("recver").value.indexOf(";")>0))
//		{
//			//alert(document.getElementById("recver").value.indexOf(";"))
//			if((document.getElementById("recver").value.split(";").length)<3){
//				isemail_cs=0;
//				document.getElementById("email_cs").style.display="inline";
//				document.getElementById("email_e_cs").innerText="删除抄送";
//			}
//			else{
//				alert("群发不能抄送！");
//			}
//		}
//		else{
			isemail_cs=0;
			document.getElementById("email_cs").style.display="";
			document.getElementById("email_e_cs").innerText="删除抄送";
		//}
	}
	else{
		isemail_cs=1;
		document.getElementById("email_cs").style.display="none";
		document.getElementById("email_e_cs").innerText="添加抄送";
	}
	try{parent.frameResize();}catch(e){}
}
//打开、关闭抄送
function email_ms(){
	if(isemail_ms==1){
		
	//	if((document.getElementById("recver").value.indexOf(";")>0))
//	{
//		//alert(document.getElementById("recver").value.indexOf(";"))
//		if((document.getElementById("recver").value.split(";").length)<3)
//		{
//			isemail_ms=0;
//			document.getElementById("email_ms").style.display="inline";
//			document.getElementById("email_e_ms").innerText="删除密送";
//			}
//		else
//		{
//		alert("群发不能密送！");
//		}
//	}
//		else
//{
			isemail_ms=0;
		document.getElementById("email_ms").style.display="";
		document.getElementById("email_e_ms").innerText="删除密送";
//}
//	
//
	}
	else{
		isemail_ms=1;
		document.getElementById("email_ms").style.display="none";
		document.getElementById("email_e_ms").innerText="添加密送";

	}
	try{parent.frameResize();}catch(e){}
}
//打开、关闭 使用群发单显 
function email_qf(){
	if(isemail_qf==1){
		
		document.getElementById("email_cs").style.display="none";
		document.getElementById("email_e_cs").style.display="none";
		document.getElementById("email_e_cs_l").style.display="none";

		document.getElementById("email_ms").style.display="none";
		document.getElementById("email_e_ms").style.display="none";
		document.getElementById("email_e_ms_l").style.display="none";
		
		document.getElementById("email_e_qf").innerText="取消群发单显";
		document.getElementById("email_e_qf_value").value = 1
		isemail_qf=0;
	}else
	{
		isemail_qf=1;
		document.getElementById("email_e_cs").style.display="";
		document.getElementById("email_e_cs_l").style.display="";
		
		document.getElementById("email_e_ms").style.display="";
		document.getElementById("email_e_ms_l").style.display="";
		
		if (isemail_ms==0 ){
			document.getElementById("email_ms").style.display="";
		}
		if(isemail_cs==0){
			document.getElementById("email_cs").style.display="";
		}
		
		document.getElementById("email_e_qf").innerText="使用群发单显";
		document.getElementById("email_e_qf_value").value = 0
	}
	
}
// 是否定时发送开启
function sendTime()
{
	if(openSendTime==1){
		document.getElementById('sendTime').style.display='inline';
		openSendTime=0;
	}
	else{
			document.getElementById('sendTime').style.display='none';
			openSendTime=1;
	}
		
}
// 删除附件

function delUpfile(path,id,accid) 
{
	if(path!="")
	{
		alert(path);
		var xmlHttp = false;
		try {
		xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
		try {
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (e2) {
		xmlHttp = false;
		}
		}
		if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
		xmlHttp = new XMLHttpRequest();
		}
		var arrAccess,innerHtmlAcc;
		innerHtmlAcc=document.getElementById("upfileed").innerHTML;
		
		if(innerHtmlAcc!="")
		{
			document.getElementById(accid).style.display="none";
	document.getElementById(id).value="";
		}
  var strsex;
  var url = "delUPfile.asp?path="+escape(path)+"&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function()
	{

  if (xmlHttp.readyState < 4)
	{
 document.getElementById("upfileed").innerHTML="正在删除...";
  }
  if (xmlHttp.readyState == 4) 
	{
    var response = xmlHttp.responseText.split("</noscript>")[1];
			document.getElementById("upfileed").innerHTML="";
		strsex=response;
  }
	
  };

  xmlHttp.send(null); 
	}
}

function reloadOpener1()
{

	try
	{
	window.parent.window.location.reload();
	}
	catch(e1)
	{}
}
function checkRecver(str,id)
{
	if (str.replace(" ","")!=""&&str.replace(" ","")!=null)
	{
	if(!(/^.+\@(\[?)[a-zA-Z0-9\-\.]+\.(com|cn|net|org|info|cc|hk|mobi|biz|tv)$/.test(str)))
	{}
	else
	{
		if(event.keyCode!=8)
		{
		document.getElementById(id).value=str+";";
		}
		}
	}
}
//	alert(0);
//$(document).ready(function(){$("#creatword").click(creatAttach($("#title").value,$("#EmailContent").value));});



function creatAttach(_title,_content,exce) {  
                if(_title=="")
                {   
                    alert("主题不能为空！");
                }
				var xmlHttp = false;
				try {
				xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
				} catch (e) {
				try {
				xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
				} catch (e2) {
				xmlHttp = false;
				}
				}
				if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
				xmlHttp = new XMLHttpRequest();
				} 
				var url="creatAttach.asp";
				//document.write(url);
				var param="title="+UrlEncode(_title)+"&EmailContent="+UrlEncode(_content)+"&exce="+exce+"&date1="+ Math.round(Math.random()*100);
        xmlHttp.open("POST",url,true); 
				xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded"); 
			//	xmlHttp.onreadystatechange = processResponse; 
				xmlHttp.send(param);  
        xmlHttp.onreadystatechange =function(){   
        if(xmlHttp.readyState == 4){ 
	
            if(xmlHttp.status == 200){   
                var res = xmlHttp.responseText;  
					res = res.replace("||{@title}||",_title+"."+exce)
					res = res.replace("||{@title}||",_title+"."+exce)
								//document.write(res);
								updateAttach(res.split("</noscript>")[1]);
               // window.alert(res);   
            }else{   
               // window.alert("请求页面异常");   
            }   
        }   
    } ;   
	   // xmlHttp.send(url,param);   
	try {parent.frameResize();} catch (e) {}
} 
		
		

//function creatAttach(_title,_content,exce) 
//{
////$("#err").html(data);
//
//if(_title!=""&&_content!="")
//{
////	$.post("creatAttach.asp",{title:_title,EmailContent:_content},function(data){updateAttach(data.split("</noscript>")[1]);},"html");
//var url="creatAttach.asp";
//var param="title="+_title+"&EmailContent="+escape(_content)+"&exce="+exce+"";
//var xmlHttpRequest;   
//    function createXMLHttpRequest(){   
//        try  
//        {   
//       // Firefox, Opera 8.0+, Safari   
//        xmlHttpRequest=new XMLHttpRequest();   
//        }   
//     catch (e)   
//        {   
//  
//      // Internet Explorer   
//       try  
//          {   
//           xmlHttpRequest=new ActiveXObject("Msxml2.XMLHTTP");   
//          }   
//       catch (e)   
//          {   
//  
//          try  
//             {   
//              xmlHttpRequest=new ActiveXObject("Microsoft.XMLHTTP");   
//             }   
//          catch (e)   
//             {   
//             alert("您的浏览器不支持AJAX！");   
//             return false;   
//             }   
//          }   
//        }   
//  
//    }   
//    //发送请求函数   
//    function sendRequestPost(url,param){   
//        createXMLHttpRequest();   
//        xmlHttpRequest.open("POST",url,true);   
//        xmlHttpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");   
//        xmlHttpRequest.onreadystatechange = processResponse;   
//        xmlHttpRequest.send(param);   
//    }   
//    //处理返回信息函数   
//    function processResponse(){   
//        if(xmlHttpRequest.readyState == 4){   
//            if(xmlHttpRequest.status == 200){   
//                var res = xmlHttpRequest.responseText;  
//								 alert(res);
//								updateAttach(res.split("</noscript>")[1]);
//                
//            }else{   
//               // window.alert("请求页面异常");   
//            }   
//        }   
//    }  
//
//sendRequestPost(url,param);
//}
//else
//{
//	alert("标题或内容不能为空！");
//	}
//	
//}
function updateAttach(data)
{
	//alert(data);
	if(data!=""&&data!=null)
	{
		//document.getElementById("atttb").innerHTML=data;
		var dataArrt=data.split("$|@");
		if (dataArrt.length==4)
		{
		addAtt(dataArrt[0],dataArrt[1],dataArrt[2],dataArrt[3]);
		}
		
//$("#upfileed").html("<p class='accList' id='access0'><img src='img/attachment.gif' />"+data.split("email_Attachments/")[1]+"&nbsp;<a href='###' onclick=delUpfile('"+data+"','uploadfile0','access0')  title='点击删除'>删除</a></p>");
//$("#uploadfile0").val(data);
	}
//$("#EmailContent").val("");
////$(window.frames["eWebEditor1"].document).$("#editareacode")
////$("#editareacode").val("");
//window.frames["eWebEditor1"].document.getElementById("editareacode").value="";
//window.frames["eWebEditor1"].document.getElementById("editarea").src='about:blank';
//window.frames["eWebEditor1"].UpdateValue();
}

  function getsysStatus(){  
				var xmlHttp = false;
				try {
				xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
				} catch (e) {
				try {
				xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
				} catch (e2) {
				xmlHttp = false;
				}
				}
				if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
				xmlHttp = new XMLHttpRequest();
				} 
				var url="getSysStatus.asp?date1="+ Math.round(Math.random()*100);
				
        xmlHttp.open("get",url,false);   
        xmlHttp.onreadystatechange =function(){   
        if(xmlHttp.readyState == 4){   
            if(xmlHttp.status == 200){   
                var res = xmlHttp.responseText;  
								//document.write(res);
								alert(res.split("</noscript>")[1]);
               // window.alert(res);   
            }else{   
               // window.alert("请求页面异常");   
            }   
        }   
    } ;   
        xmlHttp.send(null);   
    }
-->