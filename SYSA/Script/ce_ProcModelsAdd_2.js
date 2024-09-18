
//用于预览
function FnPview(str){
	var valueDates = document.getElementsByName("jh");
	var jhd="";
	var mpk="";
	var jhlista = new Array();
	for(i=0;i<valueDates.length;i++)  
	{
		if (valueDates[i].checked){
			jhlista[jhlista.length] = valueDates[i].value;
			if(document.getElementById("NodeMEX_" +valueDates[i].value).innerText.replace(/\s/g,"") == "") {
				//alert(document.getElementById("sort1"+valueDates[i].value).value+"，还未设置阶段工作！");
				//return false;
			}
			var jhd = document.getElementById("jdtype"+valueDates[i].value).value;
			if(jhd==""){
				//alert(document.getElementById("sort1"+valueDates[i].value).value+"，还未设置阶段工作！");
				//return false;
				mpk = mpk+"K"+jhd;
			}
		}
	}
	document.getElementById("jhlist").value = jhlista.join(",")

	var opener = window.open("procModelsAdd.asp?__msgid=pview","pview","width=900,hegith=600,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=50,scrollbars=yes");				
}

function ddd(addType){
	var valueDates = document.getElementsByName("jh");
	var jhd="";
	var mpk="";
	var jhlista = new Array();
	for(i=0;i<valueDates.length;i++)  
	{
		if (valueDates[i].checked){
			jhlista[jhlista.length] = valueDates[i].value;
			if(document.getElementById("NodeMEX_" +valueDates[i].value).innerText.replace(/\s/g,"") == "") {
				alert("阶段【" + document.getElementById("sort1"+valueDates[i].value).value+"】还未设置具体工作信息！");
				return false;
			}
			var jhd = document.getElementById("jdtype"+valueDates[i].value).value;
			if(jhd==""){
				alert("阶段【" + document.getElementById("sort1"+valueDates[i].value).value+"】还未设置具体工作信息！");
				return false;
				mpk = mpk+"K"+jhd;
			}
		}
	}
	document.getElementById("jhlist").value = jhlista.join(",")

	if(Validator.Validate(document.all.date,2))
	{
		document.date.action="ProcModelsSave.asp?addType=" + addType
		document.date.target="aaax"
		document.all.date.submit();
	}
}
function check(field) {  for (var i = 0; i < field.length; i++) {  field[i].checked = false;}  } 
function uncheck(field) { for (var i = 0; i < field.length; i++) {  field[i].checked = true; }} 
//去掉复选框隐藏子分类
function showsortjh2(obj)       
{         
	var sortjhr;
	if (document.getElementById("sortjhr").checked==true){
			sortjhr = 1;
	}else{
			sortjhr = 0;			
	}
	if(sortjhr == 0){
		for(i=0;i<document.all(obj).length;i++)  
		{
		document.getElementById(document.all(obj)[i].value).style.display="";
		}
	}	
	if (sortjhr == 1) {
	    var htmlArr = document.all(obj);
	    //当name属性为obj的元素个数为一个时，htmlArr为那个元素，此时htmlArr无length属性。
	    if (htmlArr && htmlArr.length+"" == "undefined") { htmlArr = [htmlArr]; }
	    for (i = 0; i < htmlArr.length; i++)
		{       
	        if (htmlArr[i].checked) {
	            document.getElementById(htmlArr[i].value).style.display = "";
	        } else {
	            document.getElementById(htmlArr[i].value).style.display = "none";
		    }
		}
	}	

$('#w').window('close');
}  

//-->
