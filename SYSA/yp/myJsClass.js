// JavaScript Document
//js自定义Name属性用过遍历获取对象 从而控制对象的其他属性
function setHidden(tagName,Name)
{
	try{
		var tagv = $(tagName+"[name='"+Name+"']");
		if(tagv.is(":hidden")){
			tagv.show();
		}else{
			tagv.hide();
		}
	}catch(e){}
}
// 复选框必选项
function cBoxChoose(Name)
{
	var retBool=false;
	try
	{
		var arr=document.getElementsByName(Name);
		for(i=0;i<arr.length;i++)
		{
			if (arr[i].checked==true)
			{
				retBool=true
			}
		}
	}
	catch(e){}
	return retBool;
}

function addExtenField(url,SubType ,fback){
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var responseText = xmlHttp.responseText;
			if (fback){fback(responseText);}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
}



