// JavaScript Document
function unEnterDown()
{
		if(window.event.keyCode==13) 
			{ 
			window.event.keyCode=0; 
			window.event.cancelBubble=true; 
			window.event.returnValue   =   false; 
			}
}
function getDialog(strUrl,w,H)
{
var div = document.createElement("<div class='trans' oncontextmenu='return false;'>");
var iframe = document.createElement("<iframe class='trans' scrolling='no' style='z-index:98;margin: 0px;padding: 0px;border: none;'>");
document.getElementsByTagName("body")[0].appendChild(iframe);
document.getElementsByTagName("body")[0].appendChild(div);  
 var a = window.showModalDialog(""+strUrl+"", self,'dialogWidth='+ w +'px; dialogHeight='+ H +'px;status=no');
iframe.style.display="none";
div.style.display="none";
}
function txmFocus()
{
	try
	{
		txmfrom.txm.focus();
		}
		catch(e1)
		{
		try
	{
		parent.txmfrom.txm.focus();
		}
		catch(e1)
		{
		}
		}

	}
	function TexTxmFocus(event)
{
	event = event? event: window.event
	if(!event) return;
	var obj = event.srcElement ? event.srcElement:event.target; 
	if(!obj) return ;
	if(obj.name==undefined)
	{
		var eo = null;
		try
		{
			eo = document.getElementsByName("txm")[0];
			//eo.style.cssText = "overflow:hidden;font-size:1px;position:absolute;top:" + (document.body.scrollTop+2) + "px;left:" + (document.body.scrollLeft+2) + "px;border:0px;width:100px;height:100px;background-color:transparent";
			eo.focus();
		}
		catch(e1)
		{
			try
			{
				eo = parent.document.getElementsByName("txm")[0];
				//eo.style.cssText = "overflow:hidden;font-size:1px;position:absolute;top:" + (document.body.scrollTop+2) + "px;left:" + (document.body.scrollLeft+2) + "px;border:0px;width:1px;height:1px;background-color:transparent";
				eo.focus();
			}
			catch(e1)
			{
			}
		}
	}
}
function textRepalce(str)
{
	str=str.replace("<response>","");
	str=str.replace("</response>","");
	str=str.replace("<result>","");
	str=str.replace("</result>","");
	return str;
	}
	
	function getMessage(strUrl,width,height)
{
var div = document.createElement("<div class='trans' oncontextmenu='return false;'>");
var iframe = document.createElement("<iframe class='trans' scrolling='no' style='z-index:98;margin: 0px;padding: 0px;border: none;'>");
document.getElementsByTagName("body")[0].appendChild(iframe);
document.getElementsByTagName("body")[0].appendChild(div);  
var a = window.showModalDialog(""+strUrl+"", self,'dialogWidth='+width+'px; dialogHeight='+height+'px;status=no');
iframe.style.display="none";
div.style.display="none";
}
// 号码排重函数
function checkDoberPhone(strTel)
{
		obj = {};  
		var str = strTel;  
		var arr = str.split(",");  
		for(var i=0; i <arr.length; ++i){  
		obj[arr[i]] = (obj[arr[i]] || 0)+1;  
	}  
		var newStr = "";
for(var c in obj){  
	if(newStr!="")
	{
		newStr = newStr + ","+c;
		}
	else if (newStr=="")
	{
		newStr = newStr +c;
		}
	}
	return newStr;

}

//双击复制id内容为“＝”右边内容
function copyClick(id) 
{ 
	var str = document.getElementById(id).innerHTML
	if(str!="")
	{
		if(str.indexOf("=")>0)
		{
			str=str.split("=")[1];
		}
		str=str.replace(" ","");
	window.clipboardData.setData("Text",str);
	if(getCookie("copyClick")!="yes")
	{
	setCookie("copyClick","yes",1);
	alert("已复制:"+str+"\n(此提示今天将不再提醒)");
	}
	}
} 
//生成一个cookie
function setCookie(name,value,days){
	var exp=new Date();
	exp.setTime(exp.getTime() + days*24*60*60*1000);
	var arr=document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
	document.cookie=name+"="+escape(value)+";expires="+exp.toGMTString();
}
//得到一个cookie
function getCookie(name){
	var arr=document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
	if(arr!=null){
		return unescape(arr[2]);
		return null;
	}
}


function NumFix(num,s)
{
	num=parseFloat(num);
	if(num<1)
	{
		Number.prototype.toFixed = function(s)
		{
		  return (parseInt(this * Math.pow( 10, s ) + 0.5)/ Math.pow( 10, s )).toString();
		}
		//return num.(parseInt(this * Math.pow( 10, s ) + 0.5)/ Math.pow( 10, s )).toString();
		
		}
		return num.toFixed(s);
	}


function GB2312UTF8(){
  this.Dig2Dec=function(s){
      var retV = 0;
      if(s.length == 4){
          for(var i = 0; i < 4; i ++){
              retV += eval(s.charAt(i)) * Math.pow(2, 3 - i);
          }
          return retV;
      }
      return -1;
  } 
  this.Hex2Utf8=function(s){
     var retS = "";
     var tempS = "";
     var ss = "";
     if(s.length == 16){
         tempS = "1110" + s.substring(0, 4);
         tempS += "10" +  s.substring(4, 10); 
         tempS += "10" + s.substring(10,16); 
         var sss = "0123456789ABCDEF";
         for(var i = 0; i < 3; i ++){
            retS += "%";
            ss = tempS.substring(i * 8, (eval(i)+1)*8);
            retS += sss.charAt(this.Dig2Dec(ss.substring(0,4)));
            retS += sss.charAt(this.Dig2Dec(ss.substring(4,8)));
         }
         return retS;
     }
     return "";
  } 
  this.Dec2Dig=function(n1){
      var s = "";
      var n2 = 0;
      for(var i = 0; i < 4; i++){
         n2 = Math.pow(2,3 - i);
         if(n1 >= n2){
            s += '1';
            n1 = n1 - n2;
          }
         else
          s += '0';
      }
      return s;      
  }

  this.Str2Hex=function(s){
      var c = "";
      var n;
      var ss = "0123456789ABCDEF";
      var digS = "";
      for(var i = 0; i < s.length; i ++){
         c = s.charAt(i);
         n = ss.indexOf(c);
         digS += this.Dec2Dig(eval(n));
      }
      return digS;
  }
  this.Gb2312ToUtf8=function(s1){
    var s = escape(s1);
    var sa = s.split("%");
    var retV ="";
    if(sa[0] != ""){
      retV = sa[0];
    }
    for(var i = 1; i < sa.length; i ++){
      if(sa[i].substring(0,1) == "u"){
        retV += this.Hex2Utf8(this.Str2Hex(sa[i].substring(1,5)));
		if(sa[i].length){
		  retV += sa[i].substring(5);
		}
      }
      else{
	    retV += unescape("%" + sa[i]);
		if(sa[i].length){
		  retV += sa[i].substring(5);
		}
	  }
    }
    return retV;
  }
  this.Utf8ToGb2312=function(str1){
        var substr = "";
        var a = "";
        var b = "";
        var c = "";
        var i = -1;
        i = str1.indexOf("%");
        if(i==-1){
          return str1;
        }
        while(i!= -1){
		  if(i<3){
                substr = substr + str1.substr(0,i-1);
                str1 = str1.substr(i+1,str1.length-i);
                a = str1.substr(0,2);
                str1 = str1.substr(2,str1.length - 2);
                if(parseInt("0x" + a) & 0x80 == 0){
                  substr = substr + String.fromCharCode(parseInt("0x" + a));
                }
                else if(parseInt("0x" + a) & 0xE0 == 0xC0){ //two byte
                        b = str1.substr(1,2);
                        str1 = str1.substr(3,str1.length - 3);
                        var widechar = (parseInt("0x" + a) & 0x1F) << 6;
                        widechar = widechar | (parseInt("0x" + b) & 0x3F);
                        substr = substr + String.fromCharCode(widechar);
                }
                else{
                        b = str1.substr(1,2);
                        str1 = str1.substr(3,str1.length - 3);
                        c = str1.substr(1,2);
                        str1 = str1.substr(3,str1.length - 3);
                        var widechar = (parseInt("0x" + a) & 0x0F) << 12;
                        widechar = widechar | ((parseInt("0x" + b) & 0x3F) << 6);
                        widechar = widechar | (parseInt("0x" + c) & 0x3F);
                        substr = substr + String.fromCharCode(widechar);
                }
			  }
			  else {
			   substr = substr + str1.substring(0,i);
			   str1= str1.substring(i);
			  }
              i = str1.indexOf("%");
        }

        return substr+str1;
  }
}
