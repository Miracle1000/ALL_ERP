


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.getElementById("B").value;
	var C=document.getElementById("C8").value;
    var url = "../manager/search_yh.asp?B="+escape(B)+"&C="+escape(C) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function nodeAction(obj,tp){
	ajaxSubmit(tp);
	if(!obj) return;
	jQuery(obj).hide().siblings().show();
}
