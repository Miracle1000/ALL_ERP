<!--
//建立XMLHttpRequest对象
var xmlhttp;
try{
    xmlhttp= new ActiveXObject('Msxml2.XMLHTTP');
}catch(e){
    try{
        xmlhttp= new ActiveXObject('Microsoft.XMLHTTP');
    }catch(e){
        try{
            xmlhttp= new XMLHttpRequest();
        }catch(e){}
    }
}

function getPart(url,partdiv,callBack){
	//alert(url);
	///alert(partdiv);
    xmlhttp.open("get",url,true);
    xmlhttp.onreadystatechange = function(){
        if(xmlhttp.readyState == 4){
            if(xmlhttp.status == 200){
                if(xmlhttp.responseText!=""){
                    document.getElementById(partdiv).innerHTML = unescape(xmlhttp.responseText);
					if (ExampGetMoney && url.indexOf("_lv")>0){
                        ExampGetMoney();
                        if (window.AfterAjax) { window.AfterAjax(); }
					}
					if (callBack){
						callBack.call();
                    }
                }
            }
            else{
            	//document.getElementById(partdiv).innerHTML=xmlhttp.responseText;
              //document.getElementById(partdiv).innerHTML = "数据载入出错";
            }
        }
    }
    xmlhttp.setRequestHeader("If-Modified-Since","0");
    xmlhttp.send(null);
}
//setInterval("getPart('getPart.asp')",1000)
//-->

