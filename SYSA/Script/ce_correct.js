﻿
$(document).ready(function(){
	if(checkTS7 == true){
		$("#title").autocomplete("getChanceJson.asp",{
			delay:10,              
			minChars:0,              
			matchSubset:0,              
			matchContains:1,              
			cacheLength:10             
		});
		$("#title").result(function(event,data,formatted) {
		if (data&&(checkTS1==true)){
				if(data!=xmTitle){
					$("#queryresult").html("项目已存在");
					$("#flag").val("1");
				}else{
				   $("#queryresult").html("");
				   $("#flag").val("0");
				}
			}
		});
	}
});

function openwin(){
window.open("../search/result4.asp","","height=250,width=450,resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=yes,location=no");
}

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
       url:"getChanceFlag.asp?v="+v+"&r="+ Math.random(),
       type:"post",
	   success:function(msg){
	       if(msg=="1"){
		   	   if(v!=xmTitle){
		   	   		$("#queryresult").html("项目已存在");
					$("#flag").val("1");
			   }else{
				   $("#queryresult").html("");
				   $("#flag").val("0");
			   }
		   }else{
		   	   $("#queryresult").html("");
			   $("#flag").val("0");
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
			    if(v!=xmid){
		   	   		$("#xmid_queryresult").html("编号已存在！");
					$("#flag_xmid").val("1");
				}else{
					$("#xmid_queryresult").html("");
					$("#flag_xmid").val("0");
				}
		   }else{
		   	   $("#xmid_queryresult").html("");
			   $("#flag_xmid").val("0");
		   }
	   }
   });
   }
}

function check_all_zdy(){
  for(var i=1;i<=4 ;i++ )
  {
    check_zdy("zdy"+i);
  }
}

function check_zdy(str){
	var zdy=$("#"+str).val();
	var zdy1=xmzdy1;
	var zdy2=xmzdy2;
	var zdy3=xmzdy3;
	var zdy4=xmzdy4;
	var zdy5=xmzdy5;
	var zdy6=xmzdy6;
	var sqlzdy="";
	switch(str){
	  case "zdy1":sqlzdy=zdy1;break;
	  case "zdy2":sqlzdy=zdy2;break;
	  case "zdy3":sqlzdy=zdy3;break;
	  case "zdy4":sqlzdy=zdy4;break;
	  case "zdy5":sqlzdy=zdy5;break;
	  case "zdy6":sqlzdy=zdy6;break;
	  default:sqlzdy="";break;
	}
	$.ajax({
		url:"getChanceFlag.asp?name="+str+"&zdy="+zdy+"&r="+Math.random(),
		type:"post",
		success:function(msg){
		  $("#flag_zdy"+str).val(msg);
		  if (msg=="1")
		  {
			 if(zdy!=sqlzdy){
		     $("#"+str+"_queryresult").html("已存在相同的记录！");
			 $("#flag_zdy"+str).val("1");
			 }else{
			 $("#"+str+"_queryresult").html("");
			 $("#flag_zdy"+str).val("0"); 
			 }
		  }else{
			 $("#"+str+"_queryresult").html("");
			 $("#flag_zdy"+str).val("0"); 
		  }
		}
	});
}