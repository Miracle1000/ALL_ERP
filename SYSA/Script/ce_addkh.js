
function frameResize(){
document.getElementById("mxlist").style.height=I3.document.body.scrollHeight+0+"px";
}
function check_kh(ord) {
  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2();
  };
  xmlHttp.send(null);  
}

function updatePage2() {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	khmc.innerHTML=response;
	xmlHttp.abort();
  }

}

$(document).ready(function(){
	if(checkTS7 == true){
		$("#title").autocomplete("../chance/getChanceJson.asp",{
			delay:10,              
			minChars:0,              
			matchSubset:0,              
			matchContains:1,              
			cacheLength:10             
		});
		$("#title").result(function(event,data,formatted) {
			if (data&&(checkTS1==true)){
				$("#queryresult").html("项目已存在");
				$("#flag").val("1");
			}
		});
	}
});
function checkFlag(){
	var flag=$("#flag").val();
	var flag_xmid=$("#flag_xmid").val();
	var flag_zdy1=$("#flag_zdy1").val();
	var flag_zdy2=$("#flag_zdy2").val();
	var flag_zdy3=$("#flag_zdy3").val();
	var flag_zdy4=$("#flag_zdy4").val();
//	if(flag=="1"){
//		$("#flag").val("项目主题已存在，请检查!");
//		return false;
//	}
//	if(flag_xmid=="1"){
//		$("#flag_xmid").val("项目编号已存在，请检查!");
//		return false;
//	}
//	if(flag_zdy1=="1"){
//		$("#flag_zdy1").val("相同字段已经存在!");
//		return false;
//	}
//	if(flag_zdy2=="1"){
//		$("#flag_zdy2").val("相同字段已经存在!");
//		return false;
//	}
//	if(flag_zdy3=="1"){
//		$("#flag_zdy3").val("相同字段已经存在!");
//		return false;
//	}
//	if(flag_zdy4=="1"){
//		$("#flag_zdy4").val("相同字段已经存在!");
//		return false;
//	}
}

function checkValue(){
   if(checkTS1==true){
	var v=$("#title").val();
	$.ajax({
       url:"../chance/getChanceFlag.asp?v="+v+"&r="+ Math.random(),
       type:"post",
	   success:function(msg){
	       $("#flag").val(msg);
	       if(msg=="1"){
		   	   $("#queryresult").html("项目已存在");
		   }else{
		   	   $("#queryresult").html("");
		   }
	   }
   });
   }
}
function checkxmid(){
   if(checkTS2==true){
	var v=$("#xmid").val();
	$.ajax({
       url:"getChanceFlag.asp?xmid="+v+"&r="+ Math.random(),
       type:"post",
	   success:function(msg){
	       $("#flag_xmid").val(msg);
	       if(msg=="1"){
		   	   $("#xmid_queryresult").html("编号已存在！");
		   }else{
		   	   $("#xmid_queryresult").html("");
		   }
	   }
   });
   }
}
function check_all_zdy(){
  for(var i=1;i<=4 ;i++ )
  {
    check_zdy(i);
  }
}

function check_zdy(str){
	var zdy=$("#"+str).val();
	$.ajax({
		url:"getChanceFlag.asp?name="+str+"&zdy="+zdy+"&r="+Math.random(),
		type:"post",
		success:function(msg){
		  $("#flag_zdy"+str).val(msg);
		  if (msg=="1")
		  {
		     $("#"+str+"_queryresult").html("已存在相同的记录！");
		  }else{
			 $("#"+str+"_queryresult").html("");
		  }
		}
	});
}

