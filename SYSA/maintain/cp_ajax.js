var xmlHttp = GetIE10SafeXmlHttp();



function callServer4(ord,ck,top) {
	var freeRow =  plist.getFreeRow(); // ljh 2014.3.25 xmlHttp.responseText;;
	if(freeRow)
	{
		  var url = "addlistadd.asp?ord="+escape(ord)+"&ck="+ck+"&top="+escape(top);
		  xmlHttp.open("GET", url, false);
		  xmlHttp.onreadystatechange = function(){
			  if (xmlHttp.readyState == 4) {
				var response = xmlHttp.responseText;
				var arr_res = response.split("\2\3\2\1");
				for(var i=0;i<arr_res.length;i++){
					if (arr_res[i]!=""){
						if (!plist.add2(arr_res[i]))
						{
							return;
						}
					}			
				}
				xmlHttp.abort();
			  }
		  };
		  xmlHttp.send(null);  
	}
	else
	{
		window.alert("当前配置最多只允许添加" + (window.mxSpanRows.length-1) + "行。\n\n详细情况，请咨询系统管理员。");
	}
}


function del(str,id){
	plist.del("del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100))

}

function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
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

function callServer6(t,nameitr,ord,id) {
   var w  =t;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}


function getCPYHRec(cpord) {
	if(cpord != ""){
		var yhRecs=document.getElementById('yhRecs');
		var left = (parseInt(event.clientX) + parseInt(document.documentElement.scrollLeft)) - 115;
		var mousey = parseInt(event.clientY);
		var top = mousey+parseInt(document.documentElement.scrollTop);  //鼠标的y坐标
		yhRecs.style.top=top+"px";
		yhRecs.style.left=left+"px";
		yhRecs.innerHTML=""
		yhRecs.style.display = "";

		var url = "common.asp?act=getCPYHRec&ord="+cpord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
		  if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			if (response!=""){
				yhRecs.innerHTML = response;
				var layerh = $(yhRecs).height();
				var winHei = window.document.documentElement.clientHeight || window.body.clientHeight;
				if (mousey + layerh > winHei) {
					left = left + 125;
					top = top-(mousey + layerh-winHei)-10;//10让弹层与窗口底部有一些间距
				}
				yhRecs.style.top = (top < 0 ? 0 : top) + 5 + "px";
				yhRecs.style.left = left + "px";
			}		
			xmlHttp.abort();
		  }
		};
		xmlHttp.send(null);  
	
	}
}

function showDIV(show,v,divid){			//显示/隐藏层
	if(show==1){
		document.getElementById(divid).style.display = "";
	}else if(show==0){
		if(v==""){
			document.getElementById(divid).innerHTML = ""
		}
		document.getElementById(divid).style.display = "none";
	}
}


function chkYHForm(itemID){		//选择养护人员窗口
	var TXUser = document.getElementById("TXUser");
	var txIdStr = ""
	if (itemID!=""){
		txIdStr = "_" + itemID
	}		
	document.getElementById("yhCate"+txIdStr).blur();
	var txCateid = document.getElementById("RemindPerson"+txIdStr).value;
	jQuery('#w2').window('open');
	document.getElementById("w2").style.display = "block";
	TXUser.innerHTML="loading...";
	document.getElementById("itemID").value = itemID;
	var url = "common.asp?act=selectUser&userStr="+txCateid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if (response!=""){
			TXUser.innerHTML = response;
		}		
		xmlHttp.abort();
	  }
	};
	xmlHttp.send(null);  
}

function setYHUser(){		//设置受理人
	var nm = document.getElementsByName("member2")[0];
	var member2 = nm.getAttribute("text");
	userid = nm.value; 
	var itemID = document.getElementById("itemID").value;	
	var txIdStr = ""
	if (itemID!=""){
		txIdStr = "_" + itemID
	}		
	if(itemID=="pi"){
		try{
			jQuery("input[name^='yhCate_']").attr("value",member2);
			jQuery("input[name^='RemindPerson_']").attr("value",userid);
		}catch(e){}
	}else{
		document.getElementById("yhCate"+txIdStr).value = member2;
		document.getElementById("RemindPerson"+txIdStr).value = userid;
	}
	jQuery('#w2').window('close');		
}

function selectAll(){
	var nm = document.getElementsByName("member2")[0];
	var id = nm.id.replace("_w3","");
	var win = document.getElementById(id).contentWindow;
	win.TreeView.CheckAll(	win.TreeView.objects[0]);
}

function selectFan(){
	var nm = document.getElementsByName("member2")[0];
	var id = nm.id.replace("_w3","");
	var win = document.getElementById(id).contentWindow;
	win.TreeView.CheckXOR(	win.TreeView.objects[0]);;	
}

function batSetStatus(v){
	if (v!=""){
		try{
			jQuery("select[name^='status_']").attr("value",v);
		}catch(e){}
	}
}

function checkSubGate(gate, ord){
	jQuery("input[gate"+gate+"='"+ord+"']").attr("checked",function(){
		if (jQuery(this).attr("checked")){
			jQuery(this).attr("checked",false);
		}else{
			jQuery(this).attr("checked",true);
		}
	})
}
