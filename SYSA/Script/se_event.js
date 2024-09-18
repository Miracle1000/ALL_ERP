

function callServer2() {
  var url = "../sort3/liebiao_Service.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);  

}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();	
	
  }
}

//客户分类选择节点
function checkAll2(str){
	var a=document.getElementById("u"+str).getElementsByTagName("input");
	var b=document.getElementById("e"+str);
	for(var i=0;i<a.length;i++){
		a[i].checked=b.checked;
	}
}


//新增代码 处理input 冲突问题
$(function(){
	$("#advancedSearch").click(function(){
		var newHtml=$("#ht1").contents().find("#pro_sort").html().replace(/A2/g,'pA2').replace(/s_s_/g,'ss_s_').replace(/t_s_/g,'tt_s_').replace(/d_s_/g,'dd_s_');
		if(newHtml!=null){
			$("#ht1").contents().find("#pro_sort").html(newHtml);
		}
	});

});


