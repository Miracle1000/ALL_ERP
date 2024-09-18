
function setInVal(id,valstr)
{
$("#"+id+"").val(valstr);
}
var publicWorkID,publicColor="",publicColorstr,publicSetWIdStr,publicWorkName,publicSetID="";
var bclick=false;
$(document).ready(function(){
$("#topWorkBoor tr td").click(function(){
publicWorkID=this.id;
publicColor=$("#"+publicWorkID+"").attr("bgcolor");
publicWorkName=$("#"+publicWorkID+"").html().split("&nbsp;")[1];
publicSetID=publicWorkID.split("topW-")[1];
//alert(publicSetID);
});

$("#Calendar table tr td").mousedown(function()
{ 
//alert(0);
 bclick=true;
 
});
$("#Calendar table tr td").mouseup(function()
{ 
//alert(0);
 bclick=false;
 
});

$("#Calendar table tr td").mousemove(function(){
		//alert(publicColor);
	//	if(bclick)
		
	if(this.id!=""&&this.id!=null&&publicSetID!="undefined"&&publicSetID!=""&&bclick)
	{
	$("#"+this.id+"").css("background-color",publicColor);
	//alert(this.id);
	$("#"+this.id+" .wkc").html("<span style=\"color:"+publicColor+"\" class="+this.id.split("-")[0]+"-"+publicSetID+">"+publicWorkName+"</span>");
	}
	
	});
	
	$("#save").click(function()
{ 
//alert($("#Calendar table tr td").id);
 //bclick=true;
 var GetClassWork=GetClass("Dday");
 var GetClassWorkStr,GetWorkDateName,GetClassWorkName=new Array(),GetWorkDateNameList=new Array();
//alert(GetClassWork[6].id);
//alert($("#"+GetClassWork[0].id+" .wkc").html());
 for(i=0;i<GetClassWork.length;i++)
 {
 try{
 GetClassWorkStr=$("#"+GetClassWork[i].id+" .wkc SPAN")[0].className;
 GetWorkDateName=(GetClassWork[i].id).split("_")[1];
 //alert(GetWorkDateName);
 }
 catch(e4){GetClassWorkStr="";GetWorkDateName="";}
 if(GetClassWorkStr!=""&&GetClassWorkStr!="undefined")
 GetClassWorkName.push(GetClassWorkStr);
 GetWorkDateNameList.push(GetWorkDateName);
 }
 if(GetClassWork.length!=GetClassWorkName.length)
 {
 alert("还有分组未完成排班！");
 }
else
{
//updateWorkClass("["+GetClassWorkName+"]","["+GetWorkDateNameList+"]");
 $.ajax({
       url:"kq_fc_SchedulUpdate.asp?workList="+GetClassWorkName+"&dateList="+GetWorkDateNameList+"&r="+ Math.random()+"",
       type:"post",
	   dataType:"html",
		 beforeSend:function(){$("#status").html("<span color=#ff0000>正在保存...</span><img src='../images/loading.gif'>");},
		 //$("#save").val("正在保存..."),
	   success:function(data){
		 //alert(data);
		// $("#status").html(eval("("+data+")"))
		//$("#save").val("保存成功")
		  },
			//error:function(data){$("#status").html(data);},
		 // $("#DHMonth").html(s);,
		 complete:function(data){
		//alert(data);
		 $("#status").html("保存成功");

		 }

   });
 }

});
	
	});
	$("ul:first").dragsort();
	
		function GetClass(className){return getElementsByClassName(className)}
		var $c=function(array){var nArray = [];for (var i=0;i<array.length;i++) nArray.push(array[i]);return nArray;};
		Array.prototype.each=function(func){for(var i=0,l=this.length;i<l;i++) {func(this[i],i);};};
		
		var getElementsByClassName=function(cn){
			var hasClass=function(w,Name){
					var hasClass = false;
					w.className.split(' ').each(function(s){
							if (s == Name) hasClass = true;
							});
					return hasClass;
					}; 
			var elems =document.getElementsByTagName("*")||document.all;
			var elemList = [];
			$c(elems).each(function(e){
			if(hasClass(e,cn)){elemList.push(e);}
			})
		return $c(elemList);
		}
		

//}
	
