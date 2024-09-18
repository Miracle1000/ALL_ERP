
<!--
function checklimit(){
   var ContentType=document.getElementsByName("ContentType");
   var needcontent=0;
   for(var ii=0; ii<ContentType.length;ii++){
	  if (ContentType[ii].checked)
	  {
	     needcontent=ContentType[ii].value;
	  }
   }
   var AutoNext1=document.getElementById("AutoNext1");
   if (AutoNext1.checked||needcontent!=0)
   {
      var mustcontent1=document.getElementById("mustcontent1").getElementsByTagName("input");
	  for (var i=0; i<mustcontent1.length ;i++ )
	  {
	    if (mustcontent1[i].type=="checkbox"&&mustcontent1[i].checked)
	    {
		   return confirm('修改跟进程度将可能影响到所有本分类下的客户，是否确认？');
		   break;
	    }
	  }
	  alert("请选择必填内容！");
	  return false;
   }
	return confirm('修改跟进程度将可能影响到所有本分类下的客户，是否确认？');
}

function checkshday(){
	var isProtect=0;
	var reply1=0;
	var unreplyback1day=0;
	var unreplyback1_1=0;
	var unreplyback1type2=0;
	var unreplyback1day=0;
	if(document.getElementById("isProtect1").checked==true){
		isProtect=1;
	}
	if(isProtect==1){
		if(document.getElementById("reply1").value!=""){
			reply1 = Number(document.getElementById("reply1").value);
			if(document.getElementById("isProtect1").checked==true){
				unreplyback1_1=1
			}
			if(document.getElementById("unreplyback1type2").checked==true){
				unreplyback1type2=1
			}
			if(unreplyback1_1==1 && unreplyback1type2==1){
				unreplyback1day = Number(document.getElementById("unreplyback1day").value);
				if(unreplyback1day<=reply1){
					alert("领用未联系收回天数须大于首次联系天数");
					if(document.getElementById("unreplyback1TypeTip1").style.display=="none"){
						document.getElementById("unreplyback1TypeTip1").style.display="block";
					}
					try{document.getElementById("unreplyback1day").focus();}catch(e){}
					return false;
				}else{
					return true;
				}
			}else{
				return true;
			}
		}
	}else{
		return true;
	}
}

//Function checkmusts(){
   //Return confirm('修改跟进程度将可能影响到所有本分类下的客户，是否确认？');
   //var AutoNext1=document.getElementById("AutoNext1").value;
   //alert(AutoNext1);
//   Return false;
//}
//-->
