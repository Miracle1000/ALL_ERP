function getCall(strUrl)
{
		var topwindow = false
		var win = window.top;
		try
		{
			if(!win.document.getElementById("PhoneCtl")){
				while(win.opener && window.opener!=win && topwindow==false){
					win = win.opener.top
					if (win.document.getElementById("PhoneCtl"))
					{topwindow = true}
				}
			}
			else{topwindow=true}
			if(topwindow==false){
				win = null
			}
		}
		catch(e)
		{
			win = null
		}
		if (!win)
		{
			var div = document.getElementById("phonectldiv")
			if (!div)
			{
				div = document.createElement("div")
				div.id = "phonectldiv";
				div.style.cssText = "position:absolute;top:1px;left:1px";
				document.body.appendChild(div);
				var phonePower = 0
				var objhtml = "";
				$.ajax({
					url:"../ocx/ctlevent.asp?__msgid=getObjectHTML&nodata=1",
					type:"POST",
					success: function(data){ objhtml = data; },
					async:false	
				});
				div.innerHTML = objhtml
			}
			var obj = document.getElementById("PhoneCtl").object;
		}
		else
	    {
	        var obj = win.document.getElementById("PhoneCtl");
		}
	
		if(!obj){
		    alert("调用组件失败,请安装录音盒设备!");
		    return;
		}
		var phone = strUrl.substr(strUrl.indexOf("phone=") + 6)		
		if(strUrl.indexOf("ord=")>0)
		{
			var ord = strUrl.split("ord=")[1].split("&")[0];
			var ordtype = strUrl.split("ordtype=")[1].split("&")[0] + "";
		}
		else
		{
			 var ord = 0;
			 var ordtype = "0";
		}
		var phonePower = 0
		$.ajax({
			url:"../inc/protectPhoneAjax.asp",
			type:"POST",
			data:{actionType:"byCustomer",pCustomerID:ord},
			success: function(data){
				if(data == "True"){
					phonePower = 1
				}else{
					phonePower = 0
				}
			},
			async:false	
		});
		
		var hiddenChar = ""
		if(phonePower == 0){
			hiddenChar = "*";
		}else{
			hiddenChar = "";	
		}

		try {
            obj.SoftCall(phone.replace(/[^\d|^-]/g,"")+hiddenChar, ord, ordtype);
        }
        catch (e) {
            alert("调用组件失败,请安装录音盒设备!");
            return;
        }

}

function progress(strUrl)
{
   var a = window.showModalDialog(""+strUrl+"", self,'dialogWidth=350px; dialogHeight=220px;status=no;scroll=no');
}

function getCall1(strUrl)
{
	var div = document.createElement("div");
	div.className="trans";
	div.oncontextmenu="return false;"
	var iframe = document.createElement("iframe")
	iframe.className='trans';
	iframe.scrolling='no';
	iframe.style.cssText = 'z-index:98;margin: 0px;padding: 0px;border: none;';
	document.getElementsByTagName("body")[0].appendChild(iframe);
	document.getElementsByTagName("body")[0].appendChild(div);  
	progress1(strUrl);
	iframe.style.display="none";
	div.style.display="none";
}

function progress1(strUrl)
{
	var dialogheight=resetDialogHeight();
	if(window.showModalDialog){
		var a = window.showModalDialog(""+strUrl+"&t=" + (new Date()).getTime(), self,'dialogWidth=350px; dialogHeight='+dialogheight+'px;status=no;scroll=no');
	}else{
		window.open(""+strUrl+"&t=" + (new Date()).getTime(),"radio",'width=' + 350 + ',height=' + dialogheight + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
	}
}
/**
 * 根据操作系统及ie不同版本,重新设置窗口高度,避免底部按钮被遮住.
 */
function resetDialogHeight(){
  var ua = navigator.userAgent;   
  if(ua.lastIndexOf("MSIE 8.0") != -1){        
    return 245; 
  }
  if(ua.lastIndexOf("MSIE 9.0") != -1){        
    return 245; 
  }
  if(ua.lastIndexOf("MSIE 10.0") != -1){        
    return 245; 
  }
  if(ua.lastIndexOf("MSIE 5.5") != -1){        
    return 220; 
  }
  if(ua.lastIndexOf("MSIE 6.0") != -1){    
    return 220; 
  }
  if(ua.lastIndexOf("MSIE 7.0") != -1){    
    return 220; 
  }
  if(ua.lastIndexOf("Firefox") != -1){    
    return 160; 
  }
  return 220;
}