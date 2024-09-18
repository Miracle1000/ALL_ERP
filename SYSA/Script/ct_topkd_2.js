var	adsIF = document.createElement("input");
adsIF.type="hidden";adsIF.id="adsIF";
document.body.appendChild(adsIF);
window.adClose = function()
{
	document.getElementById("div_ckidstate").style.display = "none"
}

function selectCK(imgobj,batflg)
{
	var div = document.getElementById("div_ckidstate")
	if(!div){
		div = document.createElement("div")
		div.id = "div_ckidstate";
		div.style.cssText = "border:1px solid #000;width:200px;height:490px;position:absolute;display:none;background-color:white"
		document.body.appendChild(div)
	}
	div.style.left = event.x-200+document.body.scrollLeft;
	div.style.top = event.y+document.body.scrollTop;
	var mid=imgobj.mid;
	var mod=imgobj.ord;

	if(batflg==true)
	{
		div.innerHTML = "<iframe src='../store/StoreDlg.asp' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	else
	{
		var pid=mod;
		var uid=document.getElementById('u_nametest'+mid).value;
		div.innerHTML = "<iframe src='../store/StoreDlg.asp?pid=" + pid  + "&unit=" +  uid +"' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	div.style.display = "block";
	window.currStore =
	{
		text : "" , value : "" , change : function()
		{
			var url="../store/CommonReturn.asp?act=getStoreSort&ckid="+window.currStore.value+"&stamp="+Math.round(Math.random()*100);
			xmlHttp.open("Get",url,false);
			xmlHttp.send(null);
			var cktext =xmlHttp.responseText+'-'+window.currStore.text;
			var ckvalue = window.currStore.value;
			imgobj.parentElement.parentElement.parentElement.parentElement.parentElement.getElementsByTagName("label")[0].innerHTML=cktext;
			imgobj.parentElement.parentElement.parentElement.parentElement.parentElement.getElementsByTagName("input")[0].value=ckvalue;
			showBG(0);
		}
	}
	div.style.zIndex = 10001;
	showBG(1);
	return false
}

function showBG(flg)
{
	var bg=document.getElementById("bgdiv");
	bgdiv.style.height=document.body.scrollHeight;
	bgdiv.style.display=flg?"block":"none";
}

function BatchInput(obj,flg)
{
	var tgname=obj.tagName;
	var l=obj.name.length;
	var objname=obj.name.substring(0,l-1);
	var objs=document.getElementById("details").getElementsByTagName(tgname);
	for(var i=0;i<objs.length;i++)
	{
		if(objs[i]==obj) continue;
		if(objs[i].name.indexOf(objname)==0)
		{
			if(objname.indexOf("num_")>=0){
				objs[i].value=FormatNumber(obj.value,window.sysConfig.floatnumber);
			}else if(objname.indexOf('discount')==0){
				objs[i].value=FormatNumber(obj.value,window.sysConfig.discountDotNum);
			}else if(objname.indexOf("price")>=0||obj.name.indexOf("money")>=0||obj.name.indexOf('discount')>=0){
				objs[i].value=FormatNumber(obj.value,window.sysConfig.moneynumber);
			}else{
				objs[i].value=obj.value;
			}

			var $obj = jQuery(objs[i]);
			if(objs[i].tagName=='SELECT' && $obj.find('option[value="'+obj.value+'"]').size()==0){
				$obj.val(0);
			}
			
			if(!window.ActiveXObject && objs[i].tagName=='INPUT') {
				if(objs[i]!=obj) {
					var code = $obj.attr('onpropertychange');
					if(code) { eval("(function(){" + code + "})").call(objs[i]); }
				}
			}
			if(objs[i].tagName=='SELECT' && $obj.attr('onchange')){
				$obj.trigger('onchange');
			}
			
		}
		//if (objs[i].name.indexOf("invoiceType")==0)
		//{
		//	$obj.trigger('onchange');
		//}
	}

	if(flg)
	{
		var lbobj=obj.parentElement.parentElement.parentElement.parentElement.getElementsByTagName("label")[0];
		var l=lbobj.id.length;
		var objname=lbobj.id.substring(0,l-1);
		var objs=document.getElementById("details").getElementsByTagName("label");
		for(var i=0;i<objs.length;i++)
		{
			if(objs[i]==lbobj) continue;
			if(objs[i].id.indexOf(objname)==0)
			{
				objs[i].innerHTML=lbobj.innerHTML;
			}
		}
	}
}

function submitFrom(s)
{
	var fobj=document.getElementById("demo");
	var sboxs=document.getElementById("details").getElementsByTagName("select");
	var o = new Array();
	for(var i = 0 ; i < sboxs.length; i ++)
	{
		if(sboxs[i].name.indexOf("unit")==0)
		{
			o[o.length] = sboxs[i].name.replace("unit_","")
		}
	}
	document.getElementById("mxpxlists").value = o.join(",")
	if(!(Validator.Validate(fobj,2))){
		productListResize();
		return;
	}
	if(!checkhtForm()) return;
	if(!checkValue()) return;
	showBG(1);		
	document.getElementById("stdiv").style.display="block";
	window.setTimeout(function()
	{
		var url="save4.asp?ord="+window.billHTrd+"&sort3="+s+"&stam="+Math.round(Math.random()*100);
		var postdata=LinkUrlParamByForm(fobj);
		xmlHttp.open("POST", url, false);
		xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		xmlHttp.send(postdata);
		var result=xmlHttp.responseText;
		xmlHttp.abort();
		if(result.indexOf("~errmsg~")==0)
		{
			alert(result.replace("~errmsg~:",""));
			document.getElementById("stdiv").style.display="none";
			showBG(0);
		}
		else if(result.indexOf("<scrip"+"t>")==0)
		{
			alert(result.split("<noscript></noscript>")[1]);
			document.getElementById("stdiv").style.display="none";
			showBG(0);
		}
		else if(result.indexOf("~execscript~")==0)
		{
			eval(result.replace("~execscript~:",""));
		}
		else
		{
			alert(result);
			document.getElementById("stdiv").style.display="none";
			showBG(0);
		}
	},50);
}

//遍历FORM（或者任意容器），根据fn函数决定是否将其值组合成URL字符串，用于AJAX提交
//如果没有传入fn，则只要有name属性并且值不为空的，都会加入参数列表
//fn函数名可自定义，参数为控件对象，比如某个input
function LinkUrlParamByForm(frmobj,fn)
{
	if(!frmobj) return "";
	var formpara="";
	//查找INPUT，保存其值
	var obj=frmobj.getElementsByTagName("input");
	for(var i=0;i<obj.length;i++)
	{
		if(fn)
		{
			if(fn(obj[i]))
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
		else if(obj[i].name&&obj[i].value!="")
		{
			if(obj[i].type=="radio")
			{
				if(obj[i].checked) formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
			else
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
	}
	//查找Select,保存其值
	var obj=frmobj.getElementsByTagName("select");
	for(var i=0;i<obj.length;i++)
	{
		if(fn)
		{
			if(fn(obj[i]))
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
		else if(obj[i].name&&obj[i].value!="")
		{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
		}
	}
		//查找textarea,保存其值 //无法保存备注
	var obj=frmobj.getElementsByTagName("textarea");
	for(var i=0;i<obj.length;i++)
	{
		if(fn)
		{
			if(fn(obj[i]))
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
		else if(obj[i].name&&obj[i].value!="")
		{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
		}
	}
	return formpara;
}
//替换特殊符号2014.9.15 xieyanhui
function URLencode(sStr)
{
	return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F').replace(/\·/g,'%16');
}

function checkhtForm(){
	var telOrd = document.date.company.value;
	var sumMoney = document.getElementById("moneyall").value;
	var bizhong = 14;
	var date3 = document.date.ret3.value;
	if(telOrd!=""){
		telOrd = Number(telOrd);
		sumMoney = Number(sumMoney)
		if(telOrd>0 && sumMoney>=0 && bizhong!="" && date3!=""){
			var url2 = "../event/tel_credit.asp?ty=2&company="+telOrd+"&sumMoney="+sumMoney+"&bz="+bizhong+"&date3="+date3+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);				
			var XMlHttp2 =  GetIE10SafeXmlHttp();
			XMlHttp2.open("GET", url2, false);
			XMlHttp2.send(null);
			if (XMlHttp2.readyState == 4) {
				var restr = XMlHttp2.responseText;				
				if(restr=="0"){
					return true;
				}else if(restr=="1"){
					document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
					alert("高于信用额度无法保存");
					return false;
				}else if(restr=="2"){
					document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
					alert("高于信用额度无法保存");
					return false;
				}
				XMlHttp2.abort();
			}	
			
		}
	}
}
