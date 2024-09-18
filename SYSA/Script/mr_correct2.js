
<!--
function Check()
{   
 
	    var b2 = document.form1.sort1.value.toLowerCase();
        var b9 = document.form1.gate1.value.toLowerCase();
	 if (b2.length<=0)
          {
		window.alert("一级分类修改后不可为空");
		return false;
	}
  
  
 	return true;
}
function checkjg()
{
	var num1_1=document.getElementById("num1_1").value.toLowerCase();
	var num1_2=document.getElementById("num1_2").value.toLowerCase();
	var num1_3=document.getElementById("num1_3").value.toLowerCase();
	if (document.getElementById("num1_1").checked){
	   //开启部门价格策略
	   if(num1_1!=num1_3){
	   //非默认选项
		 if(confirm("当前产品价格策略较多，更新当前部门价格策略可能需要一些时间，是否确认继续？")){
		   return true;
		 }else{
			return false;
		 }
	   }else{
	       return true;
	   }
	}else if (document.getElementById("num1_2").checked){
	   //开启部门价格策略
	   if(num1_2!=num1_3){
	   //非默认选项
		  return true;
	   }else{
	     return true;
	   }
	}else{
	 return true;
	}

}
//-->
