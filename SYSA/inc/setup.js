// Firefox 浏览器支持event 事件
function __firefox(){
	HTMLElement.prototype.__defineGetter__("runtimeStyle",__element_style);
	window.constructor.prototype.__defineGetter__("event",__window_event);
	Event.prototype.__defineGetter__("srcElement",__event_srcElement);
	Event.prototype.__defineGetter__("propertyName",function(){return "value"});
	Event.prototype.__defineGetter__("x",__event_x);
	Event.prototype.__defineGetter__("y",__event_y);
	HTMLElement.prototype.fireEvent = function(eventName){
		var evt  = document.createEvent('HTMLEvents');  
        evt.initEvent(eventName.replace("on",""),true,true);  
        this.dispatchEvent(evt);
	}
	HTMLElement.prototype.swapNode = function(node2) {
		var node1 = this;
		var parent = node1.parentNode;//父节点
		var parent2 = node2.parentNode;//目标父节点
		var t1 = node1.nextSibling;//两节点的相对位置
		var t2 = node2.nextSibling;	  
		//如果是插入到最后就用appendChild
		if(t1){parent.insertBefore(node2,t1);}
		else{parent.appendChild(node2);}
		if(t2){parent2.insertBefore(node1,t2);}
		else{parent2.appendChild(node1);}
	}
	HTMLElement.prototype.insertAdjacentElement=function(where,parsedNode){ 
		switch(where){ 
			case "beforeBegin": 
				this.parentNode.insertBefore(parsedNode,this); 
				break; 
			case "afterBegin": 
				this.insertBefore(parsedNode,this.firstChild); 
				break; 
			case "beforeEnd":
				this.appendChild(parsedNode); 
				break; 
			case "afterEnd":
				if(this.nextSibling) 
					this.parentNode.insertBefore(parsedNode,this.nextSibling); 
				else 
					this.parentNode.appendChild(parsedNode); 
				break; 
		}
	}
}
function __event_x(){return this.srcElement.getBoundingClientRect().left+document.documentElement.scrollLeft;}
function __event_y(){return this.srcElement.getBoundingClientRect().top+document.documentElement.scrollTop+10;}
function __element_style(){return this.style;}
function __window_event(){return __window_event_constructor();}
function __event_srcElement(){return this.target;}
function __window_event_constructor(){
	if(window.ActiveXObject){
		return window.event;
	}
	var _caller=__window_event_constructor.caller;
	var xc = 1;
	while(_caller!=null && xc<200){
		var _argument=_caller.arguments[0];
		if(_argument){
			var _temp=_argument.constructor;
			if(_temp.toString().indexOf("Event")!=-1){
				return _argument;
			}
			if(xc>30) {
				//获取JQuery框架event对象
				if(_argument.target && _argument.target.tagName && _argument.timeStamp && _argument.type && _argument.type.length>0) {
					return {
						srcElement: _argument.target,
						type: _argument.type,
						isQueryEvent: 1
					};
				}
			}
		}
		_caller=_caller.caller;
		xc ++;
	}
	return null;
}
if(window.addEventListener&&HTMLElement.prototype.__defineGetter__){__firefox();}

//交换2个DOM节点
function swapNode(node1,node2)
{
	var parent = node1.parentNode;//父节点
	var parent2 = node2.parentNode;//目标父节点
	var t1 = node1.nextSibling;//两节点的相对位置
	var t2 = node2.nextSibling;
	//如果是插入到最后就用appendChild
	if(t1){parent.insertBefore(node2,t1);}
	else{parent.appendChild(node2);}
	if(t2){parent2.insertBefore(node1,t2);}
	else{parent2.appendChild(node1);}
} 


//BUG.3873.binary.2014.03.10.解决窗口已经打开，再打开不激活的问题。
if(!window.onwinfunExec) {
	window.onwinfunExec = window.open;
	window.open = function(var1, var2, var3, var4) {
		// 非IE 模式不改写 window.open
		if(var1.length == 0 && var2 == "_self"){
			return false;
		};
		if(var3) {
			try{
				var var3List = var3.split(",");
				var  currwidth = 0,currresize = 0,i1 = -1, i2=-1
				for (var n = 0; n<var3List.length; n++)
				{
					var items = var3List[n].split("=");
					if(items[0].toLowerCase()=="width") { currwidth =  items[1]; i1=n;}
					if(items[0].toLowerCase()=="resizable") { currresize =  items[1]; i2=n;}
				}
				if(isNaN(currwidth)==false && currwidth*1>=800) {
					if(i2>=0) { var3List[i2] = "resizable=1"; }
					else { var3List.push("resizable=1"); }
				}
				var3 = var3List.join(",");
			}catch(ex){}
		}
		var hwnd = null;
		if(var2==undefined && var3==undefined && var4==undefined) { hwnd = window.onwinfunExec(var1);}
		else {
			if(var4==undefined) {hwnd = window.onwinfunExec(var1, var2, var3, var4);}
			else{hwnd = window.onwinfunExec(var1, var2, var3);}
		}
		if(var1!="") { try{hwnd.focus();}catch(e){} }
		return hwnd;
	}
}

function killerrors(){return true;}/*window.onerror = killerrors;*/
/*通用跳转页面函数,仅适合采用get方式提交查询页面的列表页使用
//参数：需要更新的参数列表,传入的参数如有可能出现特殊字符（如&和=符号等）请自行进行escape或者URLENCODE转换，否则可能会出问题
//举例：
//1.翻页(更新页码)：gotourl("currpage=2");表示将基础参数字符串中的currpage=1改为currpage=2，其他参数值不变
//2.更改每页显示条数：gotourl("page_count=100");表示将基础参数字符串中的page_count=10改为page_count=100，其他参数不变
//3.查询：gotourl("a=2&b=3&c=4");分别替换对应参数的值，其他不变，基础参数中如果不存在该参数则附加进去
//4.排序：gotourl("px=4");*/
function gotourl(sReplaceValue) 
{ 
	var allurl=document.URL.split("?");
	/*当前页面URL，如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseurl="";/*基础URL,比如：http://127.0.0.1/work/telhy2.asp*/ 
	var baseparam="";/*基础参数,比如：currpage=1&a=1&b=2&c=3*/
	if (allurl.length > 0) baseurl = allurl[0].replace(/\#/g, ""); 
	var strpara=getUrl(sReplaceValue); 
	var finalurl=baseurl+(strpara.length==0?"":"?")+strpara; 
	window.location=finalurl; 
}  

function getUrl(sReplaceValue){ 
	var allurl=document.URL.split("#")[0].split("?");
	/*当前页面URL，只取#号前的部分（如果有的话），如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseparam="";/*页面参数,比如：currpage=1&a=1&b=2&c=3*/
	sReplaceValue = sReplaceValue || "";
	baseparam = allurl.length > 1 ? allurl[1] : "";
	//if (sReplaceValue.length==0 || sReplaceValue.indexOf("=")<0 ) return baseparam;
	var arrparam=baseparam.split("&");/*分割原始参数*/ 
	var arrvalue=sReplaceValue.split("&");/*分割需更新的参数*/ 
	//循环需更新的参数
	for(var i=0;i<arrvalue.length;i++) { 
		//BUG 7150 Sword 2015-2-28 客户列表切换至高级检索条件时候报错 
		if (arrvalue[i].indexOf("=")<0) continue;
		var flg=false;//参数是否已匹配上
		var vnode=arrvalue[i].split("=");
		var vkey=vnode[0],vvalue=vnode[1];
		//在基础参数中逐个匹配
		for(var j=0;j<arrparam.length;j++){ 
			var pnode=arrparam[j].split("=");
			var pkey=pnode[0];
			//找到了参数，修改参数值
			if(pkey.toLowerCase() == vkey.toLowerCase()){ 
				arrparam[j] = (vvalue == ""?"" : pkey+"=" + UrlEncode(vvalue)); 
				flg=true;
				break;
			} 
		} 

		//没找到则需要加入到参数数组中
		if(!flg){
			arrparam.push(vkey + "=" + UrlEncode(vvalue));
		}
	}

	//删除没有值的参数
	for(var i=0;i<arrparam.length;i++){
		var pnode=arrparam[i].split("=");
		if (pnode.length<2 || pnode[1].length==0){
			arrparam.splice(i--,1);
		}
	}

	return arrparam.join("&");
}

function UrlEncode(data) {
    return encodeURIComponent(data);
    //return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
	var ascCodev = "& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ · ˉ ¨ 々 ～ ‖ 」 「 『 』 ． 〖 〗 【 】 € ‰ ◆ ◎ ★ ☆ § ā á ǎ à ō ó ǒ ò ê ē é ě è ī í ǐ ì ū ú ǔ ù ǖ ǘ ǚ ǜ ü μ μ ˊ ﹫ ＿ ﹌ ﹋ ′ ˋ ― ︴ ˉ ￣ θ ε ‥ ☉ ⊕ Θ ◎ の ⊿ … ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ⌒ ￠ ℡ ㈱ ㊣ ▏ ▕ ▁ ▔  ↑  → ←  ↓  卍 ◤ ◥ ◢ ◣ 卐 ∷ № § Ψ ￥ ￡ ≡ ￢ ＊ Ю".split(" ");
	var ascCodec = "%26+%ef%b9%99+%ef%b9%9a+%ef%b9%9b+%ef%b9%9c+%ef%bc%8b+%ef%bc%8d+%c3%97+%c3%b7+%ef%b9%a2+%ef%b9%a3+%e2%89%a0+%e2%89%a4+%e2%89%a5+%e2%89%88+%e2%89%a1+%e2%89%92+%e2%88%a5+%ef%bc%8f+%c2%b1+%ef%bc%9c+%ef%bc%9e+%ef%b9%a4+%ef%b9%a5+%e2%89%a6+%ef%bc%9d+%e2%89%a7+%e2%89%8c+%e2%88%bd+%e2%89%ae+%e2%89%af+%e2%88%b6+%e2%88%b4+%e2%88%b5+%e2%88%b7+%e2%8a%99+%e2%88%91+%e2%88%8f+%e2%88%aa+%e2%88%a9+%e2%88%88+%e2%8c%92+%e2%8a%a5+%e2%88%a0+%e3%8f%91+%ef%bf%a0+%e3%8f%92+%e2%88%9f+%e2%88%9a+%e2%88%a8+%e2%88%a7+%e2%88%9e+%e2%88%9d+%e2%88%ae+%e2%88%ab+%ef%bc%85+%e2%80%b0+%e2%84%85+%c2%b0+%e2%84%83+%e2%84%89+%e2%80%b2+%e2%80%b3+%e3%80%92+%c2%a4+%e2%97%8b+%ef%bf%a1+%ef%bf%a5+%e3%8f%95+%e2%99%82+%e2%99%80+%e2%96%b3+%e2%96%bd+%e2%97%8f+%e2%97%8b+%e2%97%87+%e2%96%a1+%c2%b7+%e2%80%94+%cb%89+%c2%a8+%e3%80%85+%ef%bd%9e+%e2%80%96+%e3%80%8d+%e3%80%8c+%e3%80%8e+%e3%80%8f+%ef%bc%8e+%e3%80%96+%e3%80%97+%e3%80%90+%e3%80%91+%e2%82%ac+%e2%80%b0+%e2%97%86+%e2%97%8e+%e2%98%85+%e2%98%86+%c2%a7+%c4%81+%c3%a1+%c7%8e+%c3%a0+%c5%8d+%c3%b3+%c7%92+%c3%b2+%c3%aa+%c4%93+%c3%a9+%c4%9b+%c3%a8+%c4%ab+%c3%ad+%c7%90+%c3%ac+%c5%ab+%c3%ba+%c7%94+%c3%b9+%c7%96+%c7%98+%c7%9a+%c7%9c+%c3%bc+%ce%bc+%ce%bc+%cb%8a+%ef%b9%ab+%ef%bc%bf+%ef%b9%8c+%ef%b9%8b+%e2%80%b2+%cb%8b+%e2%80%95+%ef%b8%b4+%cb%89+%ef%bf%a3+%ce%b8+%ce%b5+%e2%80%a5+%e2%98%89+%e2%8a%95+%ce%98+%e2%97%8e+%e3%81%ae+%e2%8a%bf+%e2%80%a6+%e2%96%81+%e2%96%82+%e2%96%83+%e2%96%84+%e2%96%85+%e2%96%86+%e2%96%87+%e2%96%88+%e2%96%89+%e2%96%8a+%e2%96%8b+%e2%96%8c+%e2%96%8d+%e2%96%8e+%e2%96%8f+%e2%8c%92+%ef%bf%a0+%e2%84%a1+%e3%88%b1+%e3%8a%a3+%e2%96%8f+%e2%96%95+%e2%96%81+%e2%96%94+%e2%86%96+%e2%86%91+%e2%86%97+%e2%86%92+%e2%86%90+%e2%86%99+%e2%86%93+%e2%86%98+%e5%8d%8d+%e2%97%a4+%e2%97%a5+%e2%97%a2+%e2%97%a3+%e5%8d%90+%e2%88%b7+%e2%84%96+%c2%a7+%ce%a8+%ef%bf%a5+%ef%bf%a1+%e2%89%a1+%ef%bf%a2+%ef%bc%8a+%d0%ae".split("+");
	data = data + '';
	data = data.replace(/\s/g, "kglllskjdfsfdsdwerr");
	data = data.replace(/\+/g, "abekdalfdajlkfdajfda");
	data = escape(data);
	if(data.indexOf("%B5")>-1){
		data = data.replace("%B5","%u03BC")
	}
	data = unescape(data);
	if (!isNaN(data) || !data) { return data; }
	for (var i = 0; i < ascCodev.length; i++) {
		if(data.indexOf(ascCodev[i])>-1 && ascCodev[i].length >0){
			var re = new RegExp(ascCodev[i], "g")
			data = data.replace(re, "ajaxsrpchari" + i + "endbyjohnny");
			re = null;
		}
	}

	data = escape(data);
	
	for (var i = ascCodev.length - 1; i > -1; i--) {
		if(data.indexOf("ajaxsrpchari" + i + "endbyjohnny")>=0) {
			if (ascCodec[i].length == 0)
			{
				var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
				data = data.replace(re, " ");
				re = null;
			}else{
				var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
				data = data.replace(re, ascCodec[i]);
				re = null;
			}
		}
	}
	data = data.replace(/\*/g, "%2A"); 	//置换*		
	data = data.replace(/\-/g, "%2D"); 	//置换-
	data = data.replace(/\./g, "%2E"); 	//置换.
	data = data.replace(/\@/g, "%40"); 	//置换@
	data = data.replace(/\_/g, "%5F"); 	//置换_
	data = data.replace(/\//g, "%2F"); 	//置换/
//	data = data.replace(/A0/g, "%20"); 	//置换 
	data = data.replace(/kglllskjdfsfdsdwerr/g, "%20")
	data = data.replace(/abekdalfdajlkfdajfda/g,"%2B");
	return data;
}

function clearinput(obj,divid)
{
	if(!obj.checked)
	{
		var divobj=document.getElementById(divid);
		var chkobj=divobj.getElementsByTagName("input");
		for(var i=0;i<chkobj.length;i++) 
		{
			if(chkobj[i].type=="checkbox"&&chkobj[i].checked&&(chkobj[i].name=="W3"||chkobj[i].name=="W2"))
			{
				if(chkobj[i].name=="W2"&&chkobj[i].checked)
				{
					chkobj[i].click();
				}
				else
				{
					chkobj[i].checked=false;
				}
			}
		}
	}
}

function checkDot(sid,num_dot,int_dot)
{
	if(typeof(int_dot) == "undefined"){
		int_dot = 12;	//整数位最大长度默认为12
	}
	var txtvalueObj = typeof(sid)=="object" ? sid : document.getElementById(sid) ;
	var re = /[^\d]/g;
	var txtvalue=txtvalueObj.value;//正则获取的是数字
	if (txtvalue.indexOf('.')>=0)
	{
		var txt1,txt2,txt3;
		txt1=txtvalue.split('.');		
		txt2=txt1[0];
		if(txt2.indexOf('-')>=0){txt2="-"+txt2.replace(/\-/g,'');}
		txt3=txt1[1].replace(/\-/g,'');		
		if (txt2.length==0)
		{
			txt2="0";
		}
		else
		{
			if (txt2.length>int_dot)
			{//整数部分不能大于12位
				txt2=txt2.substr(0,int_dot);
			}			
		}
		if (txt1.length==2)
		{
			if (txt3.length>num_dot)
			{//小数部分不能大于8位
				txt3=txt3.substr(0,num_dot);
			}
		}
		txtvalueObj.value = txt2+"."+txt3; $(txtvalueObj).change();
	} 
	else
	{//整数不能超过12位
		if (txtvalue.length>int_dot)
		{
		    txtvalueObj.value = txtvalue.substr(0, int_dot); $(txtvalueObj).change();
		}
		else
		{
			if (txtvalue.indexOf('-')>=0)
			{
			    txtvalueObj.value = "-" + txtvalue.replace(/\-/g, ''); $(txtvalueObj).change();
			}
		}
	}
}

//上面那个需要控件ID，下面这个较为灵活，只求值，不和控件绑定
function formatDot(v,dot)
{
	if((v+"").length==0) return "";
	var varr=v.split('.');
	var strInt=varr[0].length>12?varr[0].substring(0,12):varr[0];
	var strDec="";
	if(varr.length==2) strDec=varr[1].length>dot?varr[1].substring(0,dot):varr[1];
	return v.indexOf('.')>=0?strInt+'.'+strDec:strInt;
}

//浮点数进行算数运算会出现10.8-0.1=10.6000000001这样的错误，用下面方法运算可以解决
//浮点数精确加法
function accAdd(arg1, arg2)
{
	var r1, r2, m, c;
	try { r1 = arg1.toString().split(".")[1].length } catch (e) { r1 = 0  }
	try { r2 = arg2.toString().split(".")[1].length } catch (e) { r2 = 0  }
	c = Math.abs(r1 - r2);
	m = Math.pow(10, Math.max(r1,  r2))
	if (c > 0)
	{
		var cm = Math.pow(10,c);
		if (r1 > r2)
		{
			arg1 =  Number(arg1.toString().replace(".", ""));
			arg2 =  Number(arg2.toString().replace(".", "")) * cm;
		}
		else
		{
			arg1 = Number(arg1.toString().replace(".", "")) *  cm;
			arg2 = Number(arg2.toString().replace(".",  ""));
		}
	}
	else
	{
		arg1 =  Number(arg1.toString().replace(".", ""));
		arg2 =  Number(arg2.toString().replace(".", ""));
	}
	return (arg1 +  arg2) / m
}

//浮点数精确减法
function accSub(arg1,arg2)
{
	var r1,r2,m,n;
	try{r1=arg1.toString().split(".")[1].length}catch(e){r1=0}
	try{r2=arg2.toString().split(".")[1].length}catch(e){r2=0}
	m=Math.pow(10,Math.max(r1,r2));
	//last modify by deeka
	//动态控制精度长度
	n=(r1>=r2)?r1:r2;
	return  ((arg1*m-arg2*m)/m).toFixed(n);
}

//浮点数精确乘法
function accMul(arg1, arg2)
{
	var m = 0, s1 = arg1.toString(), s2 = arg2.toString();
	try { m += s1.split(".")[1].length } catch (e) { }
	try { m += s2.split(".")[1].length } catch (e) { }
	return Number(s1.replace(".", "")) * Number(s2.replace(".", "")) /  Math.pow(10, m)
}

//浮点数精确除法
function accDiv(arg1, arg2)
{
	var t1 = 0, t2 = 0, r1, r2;
	try { t1 = arg1.toString().split(".")[1].length } catch (e) { }
	try { t2 = arg2.toString().split(".")[1].length } catch (e) { }
	with (Math)
	{
		r1 = Number(arg1.toString().replace(".", ""))
		r2 = Number(arg2.toString().replace(".", ""))
		return (r1 / r2) * pow(10, t2 - t1);

	}
}

function SaveItems(tid,s_item1,s_item2,s_item3,s_item4,s_item5, s_item6)
{
	var s_lock=document.getElementById("LockItems").checked;
	if(typeof(s_item6) == "undefined"){s_item6 = 0;}
	if (s_lock)
	{
		document.getElementById("LockItems").title="取消标题栏";
	}
	else
	{
		document.getElementById("LockItems").title="默认标题栏";
	}	
	var url="saveitems.asp?tid="+tid+"&s_lock="+s_lock+"&s_item1="+s_item1+"&s_item2="+s_item2+"&s_item3="+s_item3+"&s_item4="+s_item4+"&s_item5="+s_item5+"&s_item6="+s_item6+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
}

var RootOBJ=null;
setTimeout(function()
{
	if(opener)
	{
		try//有些弹出页面，当父窗口跳转到另一窗口，刷新旧的子窗口会报错 by:snihaps,time:2011-12-18
		{
			RootOBJ=opener.top.RootOBJ;
			RootOBJ.hWnds.Windows.Add(window);
			window.onfocus=function()
			{
				if(RootOBJ&&RootOBJ.hWnds)
				{
					RootOBJ.hWnds.Recycle();
					window.ActiveTime=(new Date()).getTime()
				}
			};
		}catch(e){}
	}
},1000);

function LoginDialog(r)
{
	if(window.ActiveXObject)
	{
		var rtnvalue = window.showModalDialog("../../SYSN/view/init/relogin.ashx?sver=" + window.syssoftversion + "&res=" + r + "&unique=" + window.currUser + "&sid=" + window.SessionId, window, "status:no;help:no;scroll:no;dialogWidth:600px;dialogHeight:428px");
	}
	else {
		showreloginDivWindow(r);
		return;
	}
	if (!rtnvalue) {
	    RootOBJ.hWnds.CloseWindow();
	    RootOBJ.hWnds.Windows[0].obj.detachEvent("onbeforeunload", RootOBJ.hWnds.Windows[0].obj.BeforeUnload);
	    RootOBJ.hWnds.Windows[0].obj.location = "../index2.asp";
	}
	else 
    {
        RootOBJ.hWnds.EnableWindow();
	    for (var i = 0; i < RootOBJ.hWnds.Windows.length; i++) 
        {
            var win = RootOBJ.hWnds.Windows[i];
	        if (win && win.obj && win.obj.LoginDialogOk) {
	            win.obj.LoginDialogOk();
	        }
	    }
    }
}


window.OnreloadOk = function(){
	//div模式重新登陆成功
	var div = document.getElementById("__sys_rlg_win");
	if(div) {
		div.style.display = "none"
	}
	RootOBJ.hWnds.EnableWindow();
	for (var i = 0; i < RootOBJ.hWnds.Windows.length; i++) 
	{
		var win = RootOBJ.hWnds.Windows[i];
		if (win && win.obj && win.obj.LoginDialogOk) {
			win.obj.LoginDialogOk();
		}
	}
}

function showreloginDivWindow(r) {
	try{window.focus();}catch(e){}
	var t = new Date();
	var div = document.getElementById("__sys_rlg_win");
	if(!div) {
		var div = document.createElement("div");
		div.id = "__sys_rlg_win";
		document.body.appendChild(div);
		div.style.cssText = "display:none;width:600px;height:428px;position:absolute;z-index:100000;border:1px solid #333;top:130px";
	}
	div.style.left = parseInt((document.body.offsetWidth - 600) / 2) + "px";
	div.style.display = "block";
	div.innerHTML = "<iframe frameborder=0 style='height:100%;width:100%' scrolling=no src='../relogin.ashx?sver=" + window.syssoftversion + "&dlg=" + t.getTime() + "&res=" + r + "&unique=" + window.currUser + "&sid=" + window.SessionId + "'></iframe>"
}


function DisableWindow()
{ 
	var dv=document.getElementById("wmg_disable_div");
	if(!dv)
	{
		dv=document.createElement("div");
		dv.style.cssText="display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#39457D;z-index:10000;-moz-opacity:0.3;opacity:.30;filter:alpha(opacity=30)";
		dv.id="wmg_disable_div";
		document.body.appendChild(dv);
	}
	dv.style.display="block";
}

function EnableWindow()
{
	var dv=document.getElementById("wmg_disable_div");
	if(dv){dv.style.display="none";}
}

window.disSaveButtonTick = 0
var disbuttontempfun = null;

function document_onclick() {
    if (window.disSaveButtonTick == 1) { return false; }
	if(!event) return false;
    var srcobj = window.event.srcElement || event;
	try{
		if (srcobj.tagName == "BUTTON" || (srcobj.tagName == "INPUT" && (srcobj.type.toLowerCase() == "button" || srcobj.type.toLowerCase() == "submit"))) {
			var txt = srcobj.tagName == "INPUT" ? srcobj.value : srcobj.innerHTML;
			if (txt.indexOf("保存") >= 0) {
				window.disSaveButton = srcobj;
				window.disSaveButtonTick = 1;
				window.setTimeout("window.disSaveButton.disabled=true;", 10);
				window.setTimeout("window.disSaveButton.disabled=false;window.disSaveButtonTick=0;", 4000);
				return;
			}
		}
	}catch(e){}
}


function loadSaveLock(){ //锁定编辑界面重复打开并且允许编辑的情况 谭2012.03.27
	var l = [	//l为必须判断页面的路径关键字，为特殊情况
		"money/addht2.asp",
		"money2/addht2.asp",
		"money3/addht2.asp",
		"money4/addht2.asp",
		"money/addht3.asp",
		"money2/addht3.asp",
		"money3/addht3.asp",
		"money4/addht3.asp",
        "money2/addht4.asp",
        "money3/addht4.asp",
		"money4/addht4.asp"
	]

	var mu = window.ConflictPageUrllist.split(";") //一人同时操作多张单是否提交
	var path = window.location.pathname.toLowerCase();
	var updatePage = window.location.pathname.indexOf("/add")==-1;  //多人同时操作一张单情况是否提交控制
	var needsubmit = false											//自己同时操作多张单情况是否提交
	for(var i = 0 ; i < l.length ;i++)
	{
		if(path.indexOf(l[i])>0)
		{
			updatePage  = true;
			break;
		}
	}
	for(var i = 0 ; i < mu.length ;i++)
	{
		if(path.indexOf(mu[i])>0)
		{
			needsubmit = true;
			break;
		}
	}
	if(updatePage==true) { 
		if(window.currForm.length == 0 && window.currQueryString.length == 0)
		{
			updatePage= false;
		}
	}

	if(updatePage==true) {
		var hs = false
		var buttons = document.getElementsByTagName("input"); 
		for(var i = 0; i<buttons.length ; i++)
		{
			if(buttons[i].value.indexOf("保存")>=0 || (buttons[i].getAttribute("editcontrol") && buttons[i].getAttribute("editcontrol").indexOf("保存")>=0) ) {
				hs = true;
				break;
			}
		}
		updatePage = hs;
	}
	
	if(needsubmit==true) 
	{
		window.onunloadbctlalert = false
		window.onbeforeunload = function (){
			if(window.onunloadbctlalert==false){
				unRegConflictPage(); //撤销冲突页独占登记 
				try{
					if(BeforeUnload)  //在checkonline.js中存在unload事件的调用。防止冲掉
					{
						BeforeUnload();
					}
				}catch(e){}
				window.onunloadbctlalert = true;
			}
		}
	}


	//updatePage表示是否为修改或审批页面
	
	if(updatePage==true || needsubmit==true)  //需要多人同时操作检测，或者需要同账号操作多页面检测
	{
		 window.billcontrolStatus =  (updatePage==true ? 10 : 0) + (needsubmit==true ? 1 : 0)
		 window.BillcontrolTimer = window.setInterval(BillcontrolStatusHandle,10000);  //5秒钟提交一次，在服务器上实时注册正在编辑状态
		 BillcontrolStatusHandle();
	}
}

function  unRegConflictPage()
{
	//撤销冲突页独占登记
	var ax = getxmlhttp();
	var senddata = "__msgId=unRegConflictPage"
	if(!x_http) { x_http = new getxmlhttp(); }
	x_http.open("Post", window.sysCurrPath + "inc/billControl.asp", false);
	x_http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	if(window.ActiveXObject) { x_http.setRequestHeader("Content-Length", senddata.length + ""); }
	x_http.send(senddata);
}

function BillcontrolStatusResult(t){
    if (t.replace(/\s+/g, "").length > 0) {
		var buttons = document.getElementsByTagName("input"); 
		for(var i = 0; i<buttons.length ; i++)
		{
			if(buttons[i].value.indexOf("保存")>=0 || (buttons[i].getAttribute("editcontrol") && buttons[i].getAttribute("editcontrol").indexOf("保存")>=0)){
				buttons[i].disabled = true;
				buttons[i].style.cssText = "background:#aaaaaa url();color:white;";
			}
		}
		var div = document.getElementById("showThreathControl");
		if(!div) {
			div = document.createElement("div");
			div.id = "showThreathControl";
			div.innerHTML = "提示：【" + t + "】已经锁定并正在操作本单据。<br><input type=button class='page' onclick='document.getElementById(\"showThreathControl\").style.display=\"none\"' value='确定'>" 
			document.body.appendChild(div);
			div.style.cssText = "position:absolute;left:40%;top:30%;width:300px;height:80px;background-color:#fffff0;border:1px solid #aabbcc;padding-top:15px;text-align:center;line-height:30px;color:red;"
		}
		window.clearInterval(window.BillcontrolTimer);
	}
}
function getxmlhttp() { //创建http对象
    var mxmlhttp = new XMLHttpRequest()
    return mxmlhttp;
}


function GetIE10SafeXmlHttp() {
	//获取IE10模式下也安全的xmlhttp对象，防止onreadystatechange事件错乱
	var obj = new Object();
	obj.onreadystatechange = null;
	obj.responseText = "";
	obj.responseBody = null;
	obj.readyState = 0;
	obj.status = 200;
	obj.xhttp = getxmlhttp();
	obj.myonchange = function () {
		try  {
			obj.readyState = obj.xhttp.readyState;
			obj.status = obj.xhttp.status;
		}catch (e){
			obj.readyState = 0;
			obj.status = 0;
		}
		try {
			if(obj.readyState ==4) {
				obj.responseText = obj.xhttp.responseText;
				if(	obj.responseText.indexOf("请重新登录")>0  && 	obj.responseText.indexOf("href")>0 && obj.responseText.indexOf("../index2.asp'")>0){
					obj.responseText = "";
				}
				obj.responseBody  = obj.xhttp.responseBody;
				try{
					if(obj.responseText.indexOf("content=\"zbintel.error.message\"") > 0) {
						document.write(obj.responseText);
						return;
					}
				}catch(e){}
			}
		}
		catch (e) {
			obj.responseText = "";
			obj.responseBody  = null;
		}
		if(obj.onreadystatechange) {
			obj.onreadystatechange();
		}
		ajaxreadystatechanged(obj);
	}
	obj.open = function(p1,p2,p3) {
		obj.onreadystatechange = null;
		try {obj.xhttp.abort();}
		catch (e){}
		obj.xhttp = null;
		obj.xhttp = getxmlhttp();
		if(typeof(p3) != 'undefined') {
			obj.xhttp.open(p1, p2, p3);
		}
		else{
			obj.xhttp.open(p1, p2);
		}
	}
	obj.abort = function() { try{obj.xhttp.abort();}catch(e){} }
	obj.setRequestHeader = function(n, v) { try{obj.xhttp.setRequestHeader(n,v);}catch(e){} }
	obj.send = function(data) {
		obj.xhttp.onreadystatechange = obj.myonchange;
		try{ obj.xhttp.setRequestHeader("A_S_T_ISAJAX","1"); } catch(xe){}
		try{
			if(typeof(data) != 'undefined') {obj.xhttp.send(data);}
			else{obj.xhttp.send();}
		}catch(e){}
	}
	return obj;
}

var xmlHttp = GetIE10SafeXmlHttp(); 

var x_http = null;
var currTitleText = "";
function getcurrTitle() //获取当前页的标题
{
	if(currTitleText.length==0){
		if(!document.body) {return "";}
		var tds = document.body.getElementsByTagName("td");
		for (var i = 0; i < tds.length ; i++)
		{
			if(tds[i].className=="place") {
				currTitleText = tds[i].innerText || tds[i].textContent;
				break
			}
		}
	}
	return currTitleText;
}
function BillcontrolStatusHandle() {
    //sameUrl具有同样业务功能的地址
    var sameURL = [
        ["money2/addht4.asp", "money2/addht2.asp"]
    ];
    var path = window.location.pathname.toLowerCase();
    for (var i = 0; i < sameURL.length; i++) {
        path = path.replace(sameURL[i][0], sameURL[i][1]);
    }
	var senddata = "__msgId=setThreathControl&currtitle=" + escape(getcurrTitle()).replace(/\+/g,"%2B") + "&controlStatus=" + window.billcontrolStatus + "&formdata=" + escape(window.currForm).replace(/\+/g,"%2B") + "&queryData=" + UrlEncode(window.currQueryString).replace(/\+/g,"%2B");
	senddata = senddata  + "&url=" + path.replace(/\//g,"_").replace(/\./g,"_");
	if(!x_http) { x_http = new getxmlhttp(); }
	x_http.open("Post", window.sysCurrPath + "inc/billControl.asp", true);
	x_http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	if(window.ActiveXObject){ x_http.setRequestHeader("Content-Length", senddata.length + ""); }
	x_http.onreadystatechange  = function(){
		if (x_http.readyState == 4) {
			var t = "";
			try{ t = x_http.responseText; }catch(e){}
			x_http.abort();	
			BillcontrolStatusResult(t);
		}
	}
	x_http.send(senddata);
}

//根据ID刷新页面某个元素, id=元素的id，需唯一
function RreshElement(id,callBack) 
{
    var xhttp = new getxmlhttp();
    var t = new Date();
    var url = window.location.href;
    if (url.indexOf("?") >= 0) { url = url + "&fm_t=" + t.getTime(); }
    else { url = url + "?fm_t=" + t.getTime(); }
    var ifrm = document.getElementById("sys_rfs_iframe");
    if (!ifrm) {
        ifrm = document.createElement("div");
        ifrm.id = "sys_rfs_iframe";
        ifrm.style.cssText = "position:absolute;top:1px;height:1px;left:-100px;width:1px;overflow:hidden"
        document.body.appendChild(ifrm);
        
    }
	//Task 2240 Sword 2014-11-06 周报问题
	var frms = window.currForm.split("&");
	for (var i = 0; i < frms.length ; i ++ )
	{
		frms[i] = "<input type='hidden' name='" + frms[i].split("=")[0] + "' value=\"" + frms[i].split("=")[1] + "\">";
	}
    ifrm.innerHTML = "<iframe src='about:blank' name='assddasddc' onload=\"RreshElemetLoad(this,'" + id + "'"+(callBack?','+callBack.toString().replace(/\'/g,"\'"):'')+")\" style='width:100px;height:100px'></iframe><form target='assddasddc' action='" + url + "' method='post'>" + frms.join("") + "</form>"
    ifrm.children[1].submit();
}

function RreshElemetLoad(box,id,callBack) {
    try { if (box.contentWindow.location.href.toLowerCase() == "about:blank") {return;} }
    catch (e) {}
    try {
        if (id.indexOf(",") < 0) {
            document.getElementById(id).innerHTML = box.contentWindow.document.getElementById(id).innerHTML;
			if(callBack) callBack.call(this,arguments);
        }
        else {
            id = id.split(",")
            for (var i = 0; i < id.length; i++) {
                if (document.getElementById(id[i])) {
                    document.getElementById(id[i]).innerHTML = box.contentWindow.document.getElementById(id[i]).innerHTML;
                }
                else {
                    //alert("页面元素【" + id[i] + "】访问失败.")
					//不需要给客户提示此调试信息
                }
            }
			if(callBack) callBack.call(this,arguments);
        }
    }
    catch(e){
        //alert("页面元素【" + id + "】访问失败。")
		//不需要给客户提示此调试信息
    }
}

function __pageonload()
{
	var iboxs = document.getElementsByName("I1");
	if(iboxs.length==0)
	{
		var box = document.createElement("input");
		box.type = "hidden";
		box.name = "I1";
		if(document.body)
		{
			document.body.appendChild(box);
		}
	}
}

document.onreadystatechange = function() {
	if(document.readyState=="complete") {
		window._c_sys_onload();
		handleUserDivBug();
	}	
}
function handleUserDivBug() {
	var div = document.getElementById("User");
	if(div && div.tagName=="DIV" && div.style.position=="absolute" && div.style.width == "100%") {
		div.style.width = "auto";
	}
}

window._c_sys_onload = function() {
	try {
		var url = window.location.href.toLowerCase();
		var pagename = (url.indexOf("pay/")>0) ? "cpage" : "currpage";
		var mbit = window.sysConfig.moneynumber;
		var nbit = window.sysConfig.floatnumber;
		var dbit = window.sysConfig.discountDotNum;
		var boxs = document.getElementsByTagName("input");
		var iev = document.attachEvent ? 1 : 0;
		for (var i = 0 ; i < boxs.length; i++) {
			var box = boxs[i];
			var pc = iev==1 ? box.onpropertychange : (box.getAttribute("onpropertychange")?eval("(function(){" +  box.getAttribute("onpropertychange") + "})"):null) ;
			if(box.readOnly==false && box.type=="text" && !box.getAttribute("setuphacked")) {
					var hs = 0, dtype=box.getAttribute("dataType");
					var html = box.outerHTML;
					var defv = box.defaultValue;
					var boxname = box.name.toLowerCase();
					if(boxname==pagename){
						if(!iev){ box.setAttribute("onpropertychange",null); }
						var ename = iev?"propertychange":"input";
						$(box).unbind(ename).bind(ename, 
							function() { 
								var obj = window.event.srcElement;
								formatData(obj,'int',0, 8); 
								if(obj.name.toLowerCase() == pagename) {
									if( obj.value!="" && obj.value*1==0) {obj.value = 1}
								}
							}
						);
						box.onkeyup = function() {}
						box.onkeydown = function() {
							var obj = window.event.srcElement;
							if(window.event.keyCode==13) {
								window.event.cancelBubble = true;
								window.event.returnValue = false;
								if(gotourl && obj.value.length > 0 ) { gotourl("currpage="+obj.value); }
							}
						}
						hs=1; 
					}
					if(hs ==0 && (dtype=="Date" || html.indexOf("toggleDatePicker")>0 || html.indexOf("datedlg.")>0) ) { //日期格式通通只读
						box.readOnly = true; hs=2; 
					}
					if(hs==0 && (pc||(box&&box.onkeyup)||(box&&box.onmouseup))) 
					{
						var id = box.id.toLowerCase();
						var nm = box.name.toLowerCase();
						var mi = box.getAttribute("min");
						if( dtype==null  && (id.indexOf("num")>0 || nm.indexOf("num")>0) ) { box.setAttribute("dataType","number");box.setAttribute("cannull",1);box.setAttribute("msg","请输入正确的数据");hs=3;}
						if( dtype==null  && (id.indexOf("price")>0 || nm.indexOf("price")>0) ) { box.setAttribute("dataType","number");box.setAttribute("cannull",1);box.setAttribute("msg","请输入正确的数据");hs=4;}
						if( dtype==null  && (id.indexOf("money")>0 || nm.indexOf("money")>0) ) { box.setAttribute("dataType","number");box.setAttribute("cannull",1);box.setAttribute("msg","请输入正确的数据");hs=5;}
						if( (dtype==null || dtype=="Limit" || dtype=="LimitB" || dtype=="Range") && hs==0 && html.indexOf("checkDot(")>0) { 
							if(dtype==null || dtype=="Limit" || dtype=="LimitB") {
								box.setAttribute("dataType","number");
								box.setAttribute("cannull",((mi && mi>0) ?0:1));
								box.maxlength = box.getAttribute("max");
								box.removeAttribute("min"); box.removeAttribute("max");
								box.setAttribute("msg","请输入正确的数据");
							}
							hs=6;
						}
						if( (dtype==null || dtype=="Limit" || dtype=="LimitB" || dtype=="Range") && hs==0 && html.indexOf("value=value.replace(/[^\\d\\.]/g,'')")>0) {
							if(dtype==null || dtype=="Limit" || dtype=="LimitB"){
								box.setAttribute("dataType","number");
								box.setAttribute("cannull",((mi && mi>0) ?0:1));
								box.maxlength = box.getAttribute("max");
								box.removeAttribute("min"); box.removeAttribute("max");
								box.setAttribute("msg","请输入正确的数据");
							}
							hs=7;
						}
						//if(hs>0) {if(!box.getAttribute("max")) {box.setAttribute("max","9999999999.9999");}}
					}
					if(hs>0) { 
						box.setAttribute("rmktxt","setup.js钩子" + hs); box.setAttribute("setuphacked",1); 
						if(box.value == "" && box.value!=defv) { box.value = defv; } //防止部分情况异常的问题
					}
					
				
			}
		}
	}
	catch(e){}
}

function ajaxreadystatechanged(obj) {
	if(obj.readyState==4) {
		if(obj.responseText.indexOf("<input")>0) {
			window._c_sys_onload();
		}
	}
	if(window.onajaxreadystatechanged){
		window.onajaxreadystatechanged(obj);
	}
}


//跟进页面的元素记录创建明细表mxpx的内容。
function BindMxpxData(frm,elemId)
{
	var sboxs= (elemId ?  document.getElementById(elemId) : frm).getElementsByTagName("select");
	var o = new Array();
	var p = new Array();
	for(var i = 0 ; i < sboxs.length; i ++)
	{
		if(sboxs[i].name.indexOf("unit")==0)
		{
			o[o.length] = sboxs[i].name.replace("unit_","")
			var v = sboxs[i].getAttribute("onchange").toString().split("\",\"")[1];
			p[p.length] =!isNaN(v) ? v : 0;
		}
	}
	var ibox = document.getElementById("mxpx_lists")
	if(!ibox)
	{
		ibox = document.createElement("input");
		ibox.id = "mxpx_lists"
		ibox.name = "mxpx_list"
		ibox.type = "hidden"
		frm.appendChild(ibox);
	}
	var pbox = document.getElementById("mxpx_proudcts")
	if(!pbox)
	{
		pbox = document.createElement("input");
		pbox.id = "mxpx_proudcts"
		pbox.name = "mxpx_proudct"
		pbox.type = "hidden"
		frm.appendChild(pbox);
	}
	ibox.value = o.join(",");
	pbox.value = p.join(",");
}

//供应商选择翻页
function reloadgysPage()
{
	var t = new Date();
	var smt = t.getTime().toString().replace(".","");
	var hs = false;
	var hs2 = false;
	var box = document.getElementById("gys_currIndex");
	var url = box.getAttribute("rdata").split("&");
	for (var i = 0; i < url.length ; i++ )
	{
		var item = url[i].split("=")
		if(item[0]=="currindex")
		{
			url[i] = "currindex=" + box.value;
			hs = true;
		}
		if(item[0]=="pagesize")
		{
			url[i] = "pagesize=" + document.getElementById("gys_pagesize").value;
			hs2 = true;
		}
		if(item=="timestamp")
		{
			url[i] = "timestamp=" + smt;
		}
	}
	if (hs==false)
	{
		url[url.length] = "currindex=" + box.value;
	}
	if (hs2==false)
	{
		url[url.length] = "pagesize=" + document.getElementById("gys_pagesize").value;
	}
	url = url.join("&")
	var url = "../caigou/cu2.asp?" + url;
	xmlHttp.open("GET", url, false);
	xmlHttp.send();
	document.getElementById("gys_listtb").parentNode.innerHTML = xmlHttp.responseText;
	xmlHttp.abort();
}
function gys_preIndex()
{
	var box = document.getElementById("gys_currIndex");
	var v = box.value - 1;
	if(v<0){ return; }
	document.getElementById("gys_currIndex").value = v;
	reloadgysPage();
}
function gys_nextIndex()
{
	var box = document.getElementById("gys_currIndex");
	var v = box.value*1 + 1;
	if(v>box.options.length) {v = box.options.length;} 
	document.getElementById("gys_currIndex").value = v;
	reloadgysPage();
}
//格式化内容
function formatData(obj, type, notf, maxl)
{
	if(typeof(notf) == "undefined"){ notf = 1; } //默认不可以为负数
	if(typeof(maxl) == "undefined"){ maxl = 500;}
	var ov = obj.getAttribute("oldvalue");
	var v = obj.value;
	var nup = 0;
	var fnum = "a";
    try { if (window.event.propertyName != "value") { return; } } catch (ex) { }
    if (obj.getAttribute("fving") == 1) { return; }
    if (!type) { type=obj.getAttribute("dataformat") }
	if(!type) {type = obj.getAttribute("datatype");}
	if(!ov) {ov = obj.defaultValue;}
	if(v.length>maxl*1) {v=v.substr(0,maxl);nup=1;}
	v = v.replace(" ", "");
	switch (type)
	{
		case "float":
			v = v.replace(" ","z");  //使空格不为数字
			if(isNaN(v)){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}else{
				if(nup==1) { obj.setAttribute("fving",1); obj.value = v; obj.setAttribute("fving",0) }	
			}
			break;
		case "CommPrice":
			fnum = window.sysConfig.CommPriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "SalesPrice":
			fnum = window.sysConfig.SalesPriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "StorePrice":
			fnum = window.sysConfig.StorePriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "FinancePrice":
			fnum = window.sysConfig.FinancePriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "money":
			fnum = window.sysConfig.moneynumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number":
			fnum = window.sysConfig.floatnumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number2":
			fnum = 2;
			v = v.replace(" ","z");  //使空格不为数字
			break;
	    case "number4":
	        fnum = 4;
	        v = v.replace(" ", "z");  //使空格不为数字
	        break;
		case "discount":
			fnum = window.sysConfig.discountDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "int":
			if(isNaN(v) || v.indexOf(".") >= 0){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}else{
				if(nup==1) { obj.setAttribute("fving",1); obj.value = v; obj.setAttribute("fving",0) }	
			}
			break;
		default:
	}
	if (notf == 1 && v < 0 ){
		v = v.replace("\-","");
		obj.value = v;
	}
	if(!isNaN(fnum))
	{
		var cv = v;
		var f = isNaN(v) || v.length==0;
		if (f == false || (notf==0 && v=="-")) {
		    var s = v.toString().split(".");
		    if (s.length == 2) {
		        if (s[1].length > fnum) {
		            s[1] = s[1].substr(0, fnum);
		        }
		        v = s[0] + "." + s[1]
		    }
		}
		else {
		    if (v.replace(/\s/g, "").length == 0) {
		        //在属性更改事件中判断是否为空有问题，改为在按键弹起事件中判断
		        //v = "0";
		        //window.setTimeout(function (){obj.select();},100);
		        if (!obj.onkeyup) {
		            obj.onkeyup = function () {
		                if (obj.value.length == 0) {
		                    obj.setAttribute("fving", 1);
		                    obj.value = 0
		                    obj.select();
		                    obj.setAttribute("fving", 0)
		                }
		            }
		        }
		    }
		    else {
		        v = ov;
		    }
		}
		if(cv!=v) {
			obj.setAttribute("fving",1);
			obj.value = v;
			obj.setAttribute("fving",0)
		}
	}
	obj.setAttribute("oldvalue", obj.value);
}

document.GetElement = function(IdorName) {
	var obj = document.getElementsByName(IdorName);
	return obj.length > 0 ? obj[0] : document.getElementById(IdorName);
}

//BUG.2601.Binary.2013.10.10 增加公共js函数，弹出不带网址的窗口
window.OpenNoUrl = function(url, name, attr) {
	//通过代理的方式，屏蔽url
	var urls = window.location.href.split("/");
	urls[urls.length-1] = url;
	window.currOpenNoUrl= urls.join("/");
	window.open(window.sysCurrPath + "inc/datawin.asp", name, attr);
}

window.setTimeout(function(){
	if(window.isGatherListPage!=1){
		__pageonload();loadSaveLock();
		var oclick= document.onclick;
		document.onclick = function(){
			if(oclick){oclick();};
			document_onclick();
		}
	}
},1000);

//BUG.2698.baiyong.2013.10.18 增加判断函数，翻页数过大则取1。
function isint(str) 
{ 
	var result=str.match(/^(-|\+)?\d+$/); 
	if(result==null) return str=1; 
	if (str<2147483647)
	{
	  return str;
	}else{
	  return 1;
	}
}

//按指定的位数格式化小数，不足时补0
function formatNumDot(Num,dot_num){
	var fNum2 = 1;
	var Num2 = "";
	var str0 = "";
	var m = 0;
	for(m=0;m<dot_num;m++){
		fNum2 = fNum2 * 10
	}
	Num2 = Math.round(Num * fNum2)/fNum2;
	if(dot_num>0){
		Num2 = Num2.toString();
		if(Num2.indexOf(".")==-1){
			for(m=1; m<=dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + "." + str0;
		}else{
			var arr_num2 = Num2.split(".");
			var dot2 = arr_num2[1];
			for(m=dot2.length; m<dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + str0;
		}
	}
	return Num2;
}


//通用导出方法，obj参数是一个json对象，属性如下：
/*
	from : 'url' | 'form' 参数来源类型,url代表自动从url中提取参数，form则需要使用另一个属性“formid”，使用该form中的参数提交,默认是url
	formid : 如果前面使用的是form 则此属性指定form元素的id
	params : 此属性用于指定附加的参数，以“key=value&key2=value2”格式，参数需要转码，目前底层采用get方式提交，需考虑参数长度问题
	page : 导出页面的路径
*/
window.exportExcel = function(obj){
	obj = obj || {from : 'url'} ;
	obj.from = obj.from || 'url';
	obj.postParams = obj.postParams || [];
	var debug = obj.debug || false;

	var $frm=jQuery("#listview_dIframe");
	if($frm.size()==0){
		var $div = jQuery("<div style='width:460px;position:fixed;_position:absolute;left:28%;top:150px;z-index:10000;'/>")
			.attr('id','lvw_xls_proc_bar')
			.appendTo(document.body);
		$frm = jQuery("<form style='background-color:lightblue;text-align:center;line-height:30px;position:absolute;left:"+(debug?0:-100)+"px;top:"+(debug?0:-100)+"px;width:"+(debug?300:1)+"px;height:"+(debug?400:1)+"px;display:inline' target='lvwexcelfrm'>"+
						"<span style='cursor:hand' onclick='jQuery(this).parent().css({left:-1000,top:-1000})'>关闭调试窗口</span>" +
						"<iframe style='height:"+(debug?370:1)+"px;width:"+(debug?300:1)+"px' frameborder=1 id='lvwexcel_frm' name='lvwexcelfrm'></iframe></form>")
			.attr('id','listview_dIframe')
			.attr('name','listview_dr')
			.attr('method','post')
			.appendTo(document.body);
		for(var i=0; i<obj.postParams.length; i++) {
			jQuery("<input type='hidden' name='" + obj.postParams[i].n + "' value=\"" + obj.postParams[i].v + "\">").appendTo($frm);
		}
	}else{
		$frm.children(':hidden').remove();
		for(var i=0; i<obj.postParams.length; i++) {
			jQuery("<input type='hidden' name='" + obj.postParams[i].n + "' value=\"" + obj.postParams[i].v + "\">").appendTo($frm);
		}
		var $div = jQuery("#lvw_xls_proc_bar")
		if($div.css("display")=="block"){return;}
		if(obj.debug){
			$frm.css({left:0,top:0});
		}
		$div.show();
	}
	if (obj.page != undefined && obj.page.indexOf('AspProxyExportSign') < 0) {
		$div.empty().html(""
			+ "<TABLE class=sys_dbgtab8 cellSpacing=0 cellPadding=0  style='width:460px;' align='center'>"
			+ "<TBODY>"
			+ "<TR><TD style='HEIGHT: 20px' class=sys_dbtl></TD><TD class=sys_dbtc></TD><TD class=sys_dbtr></TD></TR>"
			+ "<TR>"
			+ "<TD class=sys_dbcl style='padding-top:22px;padding-bottom:22px;'></TD>"
			+ "<TD style='border:0px solid #c0ccdd;background-color:white;padding:2px 12px;color:#2f496e;background-color:#fff;' valign='top' id='lxls_by'>"
			+ "<div id='lxls_by_progress'>"
			+ "	<span id='lxls_status'>正在生成Excel文档,<span id='lvw_xls_p_bar_st'>请稍候<span id='lxls_t'></span>...</span></span>"
			+ "	<div style='margin-top:3px;margin-bottom:5px;border:1px solid #c0ccdd;height:8px;font-size:8px;background-color:white;margin-bottom:3px'>"
			+ "		<div id='lxls_pv' style='height:8px;font-size:8px;width:0%;margin-top:0px'></div>"
			+ "	</div>"
			+ "</div>"
			+ "</TD>"
			+ "<TD class=sys_dbcr></TD>"
			+ "</TR>"
			+ "<TR><TD class=sys_dbbl></TD><TD class=sys_dbbc></TD><TD class=sys_dbbr></TD></TR>"
			+ "</TBODY>"
			+ "</TABLE>"
		);
	}

	var oriPage;
	switch (obj.from.toLowerCase()){
		case 'form' :
			if (!obj.formid){alert('请指定表单id');return;}
			$frm = jQuery('#'+obj.formid);
			oriPage = $frm.attr('action');
			$frm.attr('target','lvwexcelfrm').attr('action',obj.page);
			break;
		case 'form_with_page_action' :
			$frm.attr('action',obj.page);
			break;
		case 'url' :
		default :
			var allurl=document.URL.split("?");
			var baseparam="";
			if (allurl.length > 1) {
				baseparam = allurl[1].replace(/\#/g, ""); 
				obj.page += (obj.page.indexOf('?')>0?'&':'?') + baseparam
			}
			$frm.attr('action',obj.page)
	}
	$frm.submit();
	if (obj.from.toLowerCase()=='form'){
		$frm.attr('target','').attr('action',oriPage);
	}
}

//控制进度条的公共对象
window.exportProcBar = {
	boxInitFlag : false,
	initFileLinkBox : function (){
		var $box = parent.jQuery('#lxls_by');
		var $div = parent.jQuery('#lxls_by_flist');
		if ($div.size()==0){
			$div = parent.jQuery("<div id='lxls_by_flist' style='background-color:#fff;padding-top:5px;line-height:22px;padding-bottom:0px'>"+
										"<b style='color:green;display:inline-block;margin-bottom:6px;'>生成Excel文档成功。</b>"+
										"<br>"+
										"<span style=''>文件下载链接：</span>"+
										"<div style='text-align:center'>"+
											"<a onclick=\"jQuery('#lvw_xls_proc_bar').hide()\" class='closeBtn' href='javascript:void(0)'>关闭对话框</a>"+
										"</div>"+
									"</div>");
			$box.append($div);
		}else{
			$div.find('.lxls_by_flink').remove();
		}
		this.boxInitFlag = true;
	},
	addFileLink: function (obj) {
		if (!this.boxInitFlag){
			this.initFileLinkBox();
		}
		var $file = parent.jQuery((obj.fileCnt>1?"<br/>":"")+'<a class="lxls_by_flink" style="Text-Decoration:underline;" href="../out/downfile.asp?fileSpec=' + obj.fileUrl + '">'+obj.fileName+'</a>').insertBefore(parent.jQuery('#lxls_by_flist div:last'));
	},
	showExcelProgress : function (v,total,current){
		parent.jQuery('#lxls_pv').css('width',v+'%');
		parent.jQuery('#lxls_t').html(v+'%'+'('+current+'/'+total+')');
		if (v=="100"){
			parent.jQuery('#lxls_status').html('导出成功！导出记录'+total+'条','请点击链接下载导出文件');
		}
	}
}

/*
用于限制输入框中只能输入数字
当允许输入小数点时，若存在多个小数点导致内容不为数字，将从后往前逐个去掉小数点，直至值为数字
用法：onpropertychange="InputNumberLimit(this,false);"
参数1：输入框对象，参数2：是否允许输入小数点
*/
var __isObjecLocked;
function InputNumberLimit(inputObj,allowDot){
	if (inputObj.value.length==0) return;
	if (__isObjecLocked) return;

	__isObjecLocked = true;
	var regExpression = allowDot?/[^\d^\.]*/:/[^\d]*/;
	if(regExpression.test(inputObj.value) || isNaN(inputObj.value)){
		var finalValue = inputObj.value.replace(/[^\d^\.]*/g,'');
		while (allowDot && isNaN(finalValue)){
			/*小数点格式不正确处理*/
			var pos = finalValue.lastIndexOf('.');
			finalValue = finalValue.substring(0,pos) + finalValue.substring(pos+1);
		}
		inputObj.value = finalValue;
	}
	__isObjecLocked = false;
}

/*
函数作用：
在列表页绑定取消提醒的按钮时间，支持批量取消功能
参数opt对象支持属性说明：
cancelBtn 取消按钮的jquery选择器，不设置则为".cancelBtn"
ridAttrName 代表rid的属性的名称，不设置则为"rid"
cancelCallback 当执行了取消提醒之后的回调函数 默认时刷新当前页，即 function(){window.location.reload();}
batchCancelBtn 批量取消按钮的jquery选择器，不设置则为"#batchCancel"
batchCancelCallback = 当执行了批量取消提醒之后的回调函数 默认时刷新当前页，即 function(){window.location.reload();}
chk 批量取消时，复选框的选择器，默认为".reminderIds"
cfgId 必选，提醒配置id
调用示例：
jQuery(function(){
	BindCancelEvents({cfgId:1});//全使用默认值，需要页面元素对相关控件的属性定义和默认值一致
});
*/
function BindCancelEvents(opt){
	function sendCancelRequest(rids,cfgId,subId,callBack){
		var target = this;
		jQuery.ajax({
			url:'../inc/ReminderCall.asp?act=cancel',
			data:{rid:rids,cfgId:cfgId,subId:subId},
			cache:false,
			success:function(h){
				if (callBack){
					callBack.apply(target,arguments);
				}else{
					window.location.reload();
				}
			},
			error:function(rep){
				var $div = jQuery('<div style="position:absolute;left:0px;top:0px;width:50%;height:50%;z-index:9999"></div>');
				$div.html(rep.responseText).appendTo(document.body);
			}
		});
	}

	var opts = opt || {};
	var cancelBtn = opts.cancelBtn || ".cancelBtn",
		ridAttrName = opts.ridAttrName || "rid",
		cancelCallback = opts.cancelCallback || function(){window.location.reload();},
		batchCancelBtn = opts.batchCancelBtn || "#batchCancel",
		batchCancelCallback = opts.batchCancelCallback || function(){window.location.reload();},
		subId = opts.subId || 0,
		cfgId = opts.cfgId,
		chk = opts.chk || ".reminderIds";
	if (!cfgId){
		alert('缺少参数，必须传入提醒配置ID');
		return;
	}

	jQuery(cancelBtn).click(function(){
		if (!confirm('确定要取消该提醒吗？')) return ;

		var rid = jQuery(this).attr(ridAttrName);
		if (!rid){
			alert('请选择要取消的提醒！');
			return false;
		}
		sendCancelRequest.apply(this,[rid,cfgId,subId,cancelCallback]);
	});

	jQuery(batchCancelBtn).click(function(){
		if (!confirm('确定要取消该提醒吗？')) return ;
		var rids = "";
		jQuery(':checked'+chk).each(function(){
			var rid = jQuery(this).attr(ridAttrName);
			rids += (rids.length>0?",":"") + rid;
		});
		if(rids.length==0){
			alert('请选择要取消的提醒！');
			return false;
		}
		sendCancelRequest.apply(this,[rids,cfgId,subId,batchCancelCallback]);
	});
}

window.StoreInfoHelper = {
	vPath : '../' ,
	showInfo : function(unit,ord, attr1,attr2){
		var $div  = jQuery("#showStoreInfo");
		if ($div.size()==0){
			$div = jQuery('<div id="showStoreInfo" style="position:absolute;margin-left:0;z-index:1000"></div>');
			$div.appendTo(document.body);
		}
		if (attr1 == undefined) attr1 = 0
		if (attr2 == undefined) attr2 = 0
		var obj = event.srcElement;
		var pos = $(obj).position();

		$div.css({ left: pos.left + 20, top: pos.top + 5 });
		$div.mouseenter(function () {$(this).hide()})
		if (unit == '' || isNaN(unit) || ord == '' || isNaN(ord)) return;
		jQuery.ajax({
		        url: this.vPath + "contract/cu_kccx.asp?unit=" + unit + "&ord=" + ord + "&attr1id=" + attr1 + "&attr2id=" +attr2,
		        cache: false,
		        success: function (html) {
				$div.get(0).innerHTML = html;
				$div.show();
		}
		});
	},
	hideInfo : function(){
		jQuery("#showStoreInfo").hide();
	}
};
window.maxSboxWidth = function(box, w){
	if(!box) {return;}
	var sbox = box.getElementsByTagName("select");
	for (var i = 0 ; i<sbox.length ; i++)
	{var box = sbox[i];if(box.offsetWidth>w||box.getAttribute("fixwidth")=="1") {box.style.width = w + "px"}}
}

// 修复chrome切换高级检索 第二次不显示内容问题
setTimeout(function(){
	$(function(){
		$("a[onclick] u font.red").click(function(){
			$("span#ht1").show();
		});
	});

},1000);

// 解决onpropertychange兼容性问题
document.oninput = function(e) {
	var code = e.target.getAttribute("onpropertychange");
	eval("(function(){" + code + "})").call(e.target);
}

function __onkeypress(box, id, env) 
{
    var m = box.getAttribute("max") || 99999999;
    if (window.event.keyCode == 13 || env == 1) 
    {
        if (isNaN(box.value)) {
            return false;
        }
        if (box.value * 1 < 1) {
            box.value = 1;
        }
        if (box.value * 1 > m) {
            box.value = m;
        }
        return false;
    } 
    else {
		setTimeout(function(){
			if (box.value * 1 < 1) {            
				box.value = 1;			
			}
			if (box.value * 1 > m) {
				box.value = m;
			}
		},10);
        var char_code = window.event.charCode ? window.event.charCode : window.event.keyCode;
        if ((char_code!=8&&char_code < 48) || char_code > 57) {
            return false;
        }
    }
}

// 解决firefox 不兼容 onkeyup 问题
document.onkeypress = function(e){
	if(!e){return;}
	var node = e.target || e.srcElement;
	if(node.getAttribute("name") && node.getAttribute("name").toLocaleLowerCase() === "currpage"){
		return __onkeypress(node)
	};
}

// 解决 firefox 不支持 innerText 问题
function isIE(){ //ie? 判断是不是ie
if (window.navigator.userAgent.indexOf("MSIE")>=1)
	return true;
else
	return false;
}
if(!isIE()){
  HTMLElement.prototype.__defineGetter__ ( "innerText", function (){
		var anyString = "";
		var childS = this.childNodes;
		for(var i = 0; i < childS.length; i++)
		{
		  if(childS[i].nodeType==1) {
			anyString += childS[i].tagName=="BR" ? '\n' : childS[i].innerText; 
		  }else if(childS[i].nodeType==3){
			anyString += childS[i].nodeValue;
		  }
		}
		return anyString;
    } 
  );

  HTMLElement.prototype.__defineSetter__ ( "innerText", function (sText){
		this.textContent = sText;
    } 
  );
} 

window.MyOpenProxHwndX = 0;
window.MyOpenProxHwnd = window.setInterval(function () {
	window.MyOpenProxHwndX ++;
	if(window.MyOpenProxHwndX>10) { window.clearInterval(window.MyOpenProxHwnd); window.MyOpenProxHwnd = 0; return;}
	if (window.Myopen || window.Myopen_px) {  //如果存在，则改写该方法
		window.Myopen = function(div) {
			if(!div.tagName) { div=document.getElementById(div) }
			div.style.display = (div.style.display==""?"none":"");
			if(div.style.display=="") {
				var srcobj = window.event.srcElement;
				var rc = srcobj.getBoundingClientRect();
				var l = (rc.left + srcobj.offsetWidth / 2);
				var userlayer = $("#User").width();
				var link = $(srcobj).height();
				div.className = "resetPopupBg";// 信湖专用类名，用来重置弹窗的背景色
				div.style.cssText = "z-index:10001;box-shadow:1px 1px 7px #8888aa;position:absolute;left:" + (l - userlayer / 2) + "px;top:" + (rc.top + link+10) + "px;height:auto;padding:3px 0px 2px 0px;background-color:#fff;"
				if(window.ActiveXObject) {
					div.style.filter = "progid:DXImageTransform.Microsoft.Shadow(color=#a0acbc,direction=135,strength=4)";
					div.style.borderLeft = "1px solid #c0ccdd";
					div.style.borderTop = "1px solid #c0ccdd";
				}
				var tb = div.children[0];
				if(tb && tb.tagName=="TABLE") {
					if(tb.rows.length==1) {
						var cell = tb.rows[0].cells[0];
						cell.vAlign = "top";
						cell.height = "";
						cell.style.height = "auto";
						tb.height = "";
						tb.style.height = "auto";
					}
				}
				if(div.innerHTML.indexOf("【↓】")>0) {
					div.style.padding = "0px";
					div.style.border = "0px";
					div.style.backgroundColor = "";
				}
			}
		}
		window.clearInterval(window.MyOpenProxHwnd); window.MyOpenProxHwnd = 0;
		window.Myopen_px = window.Myopen;
		setTimeout(function () { window.Myopen_px = window.Myopen; }, 200);  //防止莫名失效的问题
		setTimeout(function () { window.Myopen_px = window.Myopen; }, 500);  //防止莫名失效的问题
		setTimeout(function () { window.Myopen_px = window.Myopen; }, 800);  //防止莫名失效的问题
		setTimeout(function () { window.Myopen_px = window.Myopen; }, 1200);  //防止莫名失效的问题
	}
},100);
// 改变checkbox和radio的高度
(function () {

    window.console = window.console || (function () {
        var c = {};
        c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile = c.clear = c.exception = c.trace = c.assert = function () { };
        return c;
    })();//解决ie9以下 conso未定义

  var ins=document.getElementsByTagName("input");
  for(var i=0;i<ins.length;i++){
	  console.log(1)
	  var curT=ins[i].type;
      if(curT=="checkbox"||curT=="radio"){
	        ins[i].style.height="13px;"
		}
   }
})();


var $$ = function (id) { return document.getElementById(id); }
window.gateTreeSearchmsv = function(box,  evt){
	var x = evt.offsetX;
	var p = x > 140 ? "pointer" : "";
	if (box.style.cursor != p) { box.style.cursor = p; }
}

window.gateTreeSearchKeyPress = function (box, evt, presstype) { //0=down  1=up
	if (presstype == 0) {
		switch (evt.keyCode) {
			case 13: window.GateTreeListSelect('click', box); break;
			case 38: window.GateTreeListSelect(-1); return false;
			case 40: window.GateTreeListSelect(1); return false;
		}
	}
	if (presstype == 1) {
		switch (evt.keyCode) {
			case 38: return;
			case 40: return;
		}
		var keytext = box.value;
		var sid = box.getAttribute("SID") || 5;
		if (window.gateTreeTimeoutHwnd && window.gateTreeTimeoutHwnd > 0) {
			window.clearTimeout(window.gateTreeTimeoutHwnd);
		}
		window.gateTreeTimeoutHwnd = setTimeout(function () {
			window.lastgatetreePostUrl = window.sysCurrPath + "../SYSN/view/init/?__sys_msgid=sdk_sys_AutoCompleteHelperURLPage&SID=" + sid + "&"
					+ "dbname=W3&__msgid=KeylistModel&__isgb2312request=1&disShowWorkname=1&__ajaxsign=1&__keyvalue=" + encodeURIComponent(keytext);
			jQuery.ajax({
				url: window.lastgatetreePostUrl,
				cache: false,
				success: function (result) {
					var lvw = result;
					window.showGateTreeKeyList(box, lvw);
				},
				error: function (rep) {
					window.showGateTreeKeyList(box, null);
				}
			});
		}, 500);
	}
}

window.gateTSKPPagesize = function (pageindex) {
	var box = $$("gatestreeselbox");
	jQuery.ajax({
		url: window.lastgatetreePostUrl,
		cache: false,
		data: {"__pagesize":  pageindex},
		success: function (result) {
			var lvw = result;
			window.showGateTreeKeyList(box,  lvw);
		},
		error: function (rep) {
			window.showGateTreeKeyList(box, null);
		}
	});
}

window.GateTreeListSelect = function (fvtype, box) {
	var div = $$("__GateTreeKeyList");
	if (!div) { return; }
	var tb = div.children[0];
	var currseli = tb.getAttribute("currSelectRowIndex");
	if (fvtype == 'click') {
		if (isNaN(currseli) == false) {
			box.blur();
			tb.rows[currseli * 1].click();
			return;
		}
	}
	if (!currseli) { currseli = 0; }
	currseli = currseli * 1 + fvtype;
	if (currseli > tb.rows.length - 1) { currseli = 1;}
	if (currseli < 1) { currseli = tb.rows.length - 1; }
	for (var i = 1; i < tb.rows.length; i++) {
		var tr = tb.rows[i];
		for (var ii = 0; ii < tr.cells.length; ii++) {
			tr.cells[ii].style.backgroundColor = currseli == i ? "#c0c0ec" : "transparent";
		}
	}
	tb.setAttribute("currSelectRowIndex", currseli);
}

window.showGateTreeKeyList = function (box, lvw) {
	var div = $$("__GateTreeKeyList");
	if (lvw == null || lvw.rows.length == 0) { if (div) { jQuery(div).remove(); } return; }
	if (!div) {
		div = document.createElement("div");
		div.id = "__GateTreeKeyList";
		document.body.appendChild(div);
	}
	var html = [];
	var obj = box.getBoundingClientRect();
	var w = 360;
	var l = (document.body.offsetWidth < (obj.left + w)) ? ((obj.left + box.offsetWidth) - w) : obj.left;
	div.style.cssText = "position:absolute; left:" + l + "px; top:" + (obj.top + box.offsetHeight) + "px;width:" + w + "px;border:1px solid #aaa;"
		+ "background-color:#f2f2fa;";
	html.push("<table style='width:"+ (w-10) + "px;margin:5px;' cellspacing=1 bgcolor='#C0CCDD'><tr>");
	for (var i = 0; i < lvw.headers.length; i++) {
		var h = lvw.headers[i];
		h.cssdisplay = (h.display == "none" || h.display == "hidden") ? "display:none" : "";
		html.push("<th style='" + h.cssdisplay + "'>" + h.title + "</th>");
	}
	html.push("</tr>");
	for (var i = 0; i < lvw.rows.length; i++) {
		html.push("<tr  onclick='window.GetGateTreeKeyList(this)' onmouseout=\"this.style.backgroundColor=''\" onmouseover=\"this.style.backgroundColor='efefef'\">");
		for (var ri = 0; ri < lvw.headers.length ;  ri++) {
			var h = lvw.headers[ri];
			var v = lvw.rows[i][ri];
			if (v == undefined || v==null) { v = "";}
			html.push("<td style='" + h.cssdisplay + "'>" + v + "</td>");
		}
		html.push("</tr>")
	}
	html.push("</table>");
	if (lvw.page.pagecount > 1) {
		var preindex = lvw.page.pageindex - 1;
		var nextindex = lvw.page.pageindex +1;
		if (preindex < 1) { preindex = 1; }
		if (nextindex > lvw.page.pagecount) { nextindex = lvw.page.pagecount; }
		html.push(" <div style='text-align:right;padding:3px 5px 8px 0px'> ");
		html.push(" <a href='javascript:void(0)' onclick='window.gateTSKPPagesize(1)'>首页</a>")
		html.push(" <a href='javascript:void(0)'  onclick='window.gateTSKPPagesize(" + preindex + ")'>上页</a> ")
		html.push("  第" + lvw.page.pageindex + "/" + lvw.page.pagecount + "页");
		html.push(" <a href='javascript:void(0)' onclick='window.gateTSKPPagesize(" + nextindex + ")'>下页</a>")
		html.push(" <a href='javascript:void(0)'  onclick='window.gateTSKPPagesize(" + lvw.page.pagecount + ")'>尾页</a> ")
		html.push("</div>");
	}
	div.innerHTML = html.join("");
	jQuery(document)
		.unbind("mousedown", window.gateTreePopCloseEvent)
		.bind("mousedown", window.gateTreePopCloseEvent);
}

window.GetGateTreeKeyList = function (tr) {
	window.CGateTreeResult();
	window.OnFieldAutoCompleteCallBack({
		text: tr.cells[1].innerHTML,
		value: tr.cells[0].innerHTML,
		tag: {datas:[0,1]}
	});
	setTimeout(function () {
		var div = $$("__GateTreeKeyList");
		if (div) { jQuery(div).remove(); }
		//$$("gatestreeselbox").focus();  加获取焦点又会触发一次请求
	}, 10);
}

window.gateTreePopCloseEvent = function (e) {
	var div = $$("__GateTreeKeyList");
	if (!div) { return; }
	var box = e.target;
	if(box==div) {return; }
	while (box != null) {
		box = box.parentNode;
		if (box == div) { return; };
	}
	jQuery(div).remove();
}

window.gateTreeSearchClick = function (box, evt) {
	var x = evt.offsetX;
	if (x > 140) {
		var l = parseInt(((window.screen.availWidth || window.screen.width) - 600) / 2) + "px";
		var ismulti = box.getAttribute("ismulti") || 0;
		var sid = box.getAttribute("SID") || 5;
		var canselectOrgSid = box.getAttribute("CanSelectOrgsid") || 0;
		/*  SID含义如下： 
			dlg_档案列表_正常 = 0,
			dlg_产品分类选择 = 1,
			dlg_仓库选择 = 2,
			dlg_档案列表_正常_带选项 = 3,
			dlg_账号列表_检索 = 4,
			dlg_账号列表_指派 = 5,
			dlg_账号列表_统计 = 6,
			dlg_账号列表_共享 = 7,
			dlg_账号列表_所有 = 8,
		*/
		window.open(window.sysCurrPath + "../SYSN/view/init/home.ashx?ismulti=" + ismulti + "&__sys_msgid=sdk_sys_AutoCompleteHelperURLPage&SID=" + sid + "&"
			+ "dbname=W3&__displayuitype=urlpage&__title=人员选择&__ac_srcobjid=W3"
			+ "&__canselectorgs=" + canselectOrgSid, "asasasxsdsd", "width=600px; height=500px; left=" + l + "px; top=150px");
		window.CGateTreeResult();
	}
}

window.CGateTreeResult = function () {
	window.OnFieldAutoCompleteCallBack = function (result) {
		var txt = result.text;
		var val = result.value;
		var jnode = result.tag;
		var box = $$("gatestreeselbox");
		box.value = txt;
		box.title = txt;
		var CHG_OPEN = box.getAttribute("CHG_OPEN");
		if (CHG_OPEN == 1) {
			gotourl('cateid=' + val);
			return;
		}
		var pbox = box.parentNode;
		if (result.tag.datas[1] == 1) {
		    ($(pbox).find("#w3")[0]||$(pbox).find("#W3")[0]).value = val;
            ($(pbox).find("#w2")[0]||$(pbox).find("#W2")[0]).value = "0";
            ($(pbox).find("#w1")[0]||$(pbox).find("#W1")[0]).value = "0";
			if (typeof (chgOthers) != "undefined") { chgOthers(3); }
		} else {
			if (val == 0) { val = ""; }
			($(pbox).find("#w3")[0] || $(pbox).find("#W3")[0]).value = "";
			($(pbox).find("#w2")[0] || $(pbox).find("#W2")[0]).value = "";
			($(pbox).find("#w1")[0] || $(pbox).find("#W1")[0]).value = val;
			if (typeof (chgOthers) != "undefined") { chgOthers(1); }
		}
	}
}
//TextArea文本框高度自适应；
window.TextAreaListViewAutoHeight = function (editbox,cellheight) {
    var cellheight = cellheight.replace("px","")
    var _that = $(editbox);
    var val = _that.val().split("\n")
    var linecount = val.length;
    var linemaxsize = 0;
    var newHeight = linecount * 15 + 18; //15每行的高度；18上下留的空白
    if (newHeight < cellheight) { newHeight = cellheight; }
    var newHeight = (editbox.scrollHeight < cellheight ? cellheight : editbox.scrollHeight);
    if (Math.abs(newHeight - cellheight) < 6) { newHeight = cellheight; }
    _that.css({ "height": newHeight });
}

function showHelpExplan(type) {
    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "block";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "block"; }
}
function closediv(type) {
    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "none";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "none"; }

}

window.AutoHandleToNet = function(billtype, fromid, actionname ,ext) {
    var xhttp=new XMLHttpRequest(); 
    xhttp.open('GET', window.sysCurrPath + '../SYSN/view/AspVirBill/AutoHandlerASPBill.ashx?billtype=' + billtype + "&fromid=" + fromid + "&actionname=" + actionname + (ext ? ext : ""), false);
    xhttp.send();
}

window.ShowHelpExplanSPAN = function (ele, e) {
    e = e || window.event;
    var div = document.getElementById("bill_help_expaln");
    if (!div) {
        div = document.createElement("div");
        div.id = "bill_help_expaln";
        div.style.position = "absolute";
        div.innerHTML = "<div class='bill_help_expaln_top' " + (getIEVer() == "5" ? "style='position:absolute;right:0px;top:0px;'" : "") + "><a title='关闭' href='javascript:;' onclick='document.getElementById(\"bill_help_expaln\").style.display=\"none\";' class='bill_help_expaln_close'>×</a></div>" +
            "<div id='bill_help_expaln_text' class='bill_help_expaln_text'>" + (ele.getAttribute('text') || "") + "</div>";
        document.body.appendChild(div)
    } else {
        document.getElementById("bill_help_expaln_text").innerHTML = ele.getAttribute('text') || ""
    }
    var wid = document.documentElement.clientWidth || document.body.clientWidth;
    var scroll = document.body.scrollTop;
    div.style.maxWidth = wid * 0.4 + "px";
    var wHei = document.documentElement.clientHeight || document.body.clientHeight;
    var os = $(ele)[0].getBoundingClientRect();
    var hei = $(div).height() > 500 ? 60 : $(div).height();
    var myw = $(div).width() > 1200 ? 760 : $(div).width();
    var otop = os.top + 20;
    if (otop + hei > wHei) { otop = wHei - hei - 10 }
    if (getIEVer() == "5") {
        div.style.Width = wid * 0.4 + "px";
        div.style.position = "absolute";
        otop = $(ele).offset().top + 20;
    }
    var oLeft = os.left + 20;
    if ((myw * 1 + oLeft * 1) > (wid - 20)) {
        oLeft = oLeft - myw;
    }
    div.style.top = otop + "px";
    div.style.left = oLeft + "px";
    div.style.display = "block";
};

window.SerializeArraySign = Array.toString();
window.SerializeDateSign = Date.toString();
/**
 * @description 对象序列化
 * @method window.GetJSON
 * @constructor 
 * @param obj {Object} 需要序列化的信息集合
 * @param deepn {Number|String} 长度 可为空
 * @return {string} 序列化后的对象字符串
 */
window.Serialize = function (obj, deepn, deepi) {
	if (obj == null) return "null";
	if (obj == undefined) return;
	if (deepi == undefined) {
		deepi = 0;
		if (deepn == undefined) {
			deepn = "";
		}
	}
	if (deepi > 50) { throw ('GetJSON存在死递归,递归链: ' + deepn.replace(/\,/g, "->") + "..."); }
	switch (typeof (obj)) {  //typeof速度快
		case "string":
			if (obj.indexOf("\"") > -1 || obj.indexOf("\\") > -1) {
				return "\"" + obj.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"") + "\"";
			} else {
				return "\"" + obj + "\"";
			}
		case "number":
			var absv = Math.abs(obj);
			if (absv === 0 || (absv > 0.00001 && absv < 1000000000)) {
				return obj.toString();
			} else {
				var numv = obj.toString();
				if (numv === "" || numv.indexOf("e") > -1 || numv.indexOf("N") > -1 || numv.indexOf("u") > -1) {
					numv = "\"" + numv + "\"";
				}
				return numv;
			}
		case "boolean":
			return obj.toString();
		case "function":
			return;
		case "object":
			var oc = obj.constructor.toString();
			if (oc == window.SerializeArraySign) {
				var str = [];
				for (var i = 0; i < obj.length; i++) {
					str[i] = window.Serialize(obj[i], (deepn + ",[]" + i), deepi + 1);
				}
				return "[" + str.join(",") + "]";
			}
			if (oc == window.SerializeDateSign) {
				return "\"" + obj.toString() + "\"";
			}
			//object
			var str = [];
			for (var o in obj) {
				var ol = o.length;
				if (ol > 8 && ol < 11) {
					if (["lvwobject", "parentNode"].indexOf(o) > -1) { continue; }; //存在引用死锁的对象名称[lvwobject/parentNode,树节点属性]
				}
				var v = window.Serialize(obj[o], (deepn + "," + o), deepi + 1);
				str.push("\"" + o + "\":" + v);
			}
			return "{" + str.join(",") + "}";
	}
};
window.GetJSONReplaceHwnd = function (n, v) {
	var l = n.length;
	if (v === undefined) { return null; }
	if (l == 9 && n == "lvwobject") { return null; }
	if (l == 10 && n == "parentNode") { return null; }
	return v;
}
window.GetJSON = (window.JSON && window.JSON.stringify) ? function (obj) { return window.JSON.stringify(obj, window.GetJSONReplaceHwnd); } : window.Serialize;

window.ReplaceUrl = function(url, paramName,  newcode){
	newcode = newcode || "";
	paramName = (paramName || "").toLowerCase();
	if(url.indexOf("?")==-1) return url + (newcode.length==0?"":("?" + newcode));
	var ups = url.split("?");
	if(ups.length>=1) { 
		ps = ups[1].split("&");
		if(paramName.length>0){
			for (var i = 0; i<ps.length; i++) {
				if( ps[i].toLowerCase().indexOf(paramName)==0) { 
					ps.splice(i,1);
					break; 
				}
			}
		};
		if(newcode.length>0) { ps.push(newcode); }
		ups[1] =  ps.join("&");
	}
    return ups[1]?ups.join("?"):ups[0];
}
String.prototype.Right = function (charcount) {
	return this.substr(this.length - charcount, charcount);
};
window.GetLongAttrUrl = function (url, longattrs) {
	var pobj = [];
	if (typeof (longattrs) == "function") {
		var obj = longattrs();
		for (var n in obj) { pobj.push({ "n": n, "v": obj[n] }); }
		longattrs = null;
	}
	if (longattrs) {  //长参数处理
		var urls = url.split("?");
		var params = (urls[1] || "").split("&");
		var longattrs = longattrs.replace(";", ",").split(",");
		if (params.length > 0) {
			for (var i = 0; i < params.length; i++) {
				for (var ii = 0; ii < longattrs.length; ii++) {
					if (params[i].toLowerCase().indexOf(longattrs[ii].toLowerCase() + "=") == 0) {
						var v = params[i].substr(longattrs[ii].length + 1);
						var n = params[i].substr(0, longattrs[ii].length);
						if (v.length > 0) {
							pobj.push({ n: longattrs[ii], v: decodeURIComponent(v.replace(/\+/g, " ")) });
							url = window.ReplaceUrl(url, n, "");
						}
					}
				}
			}
		}
	}

	if (pobj.length > 0) {
		jQuery.ajax({
			type:'POST',
			url: '../../SYSN/view/comm/CacheManager.ashx?__sys_msgid=sdk_sys_RegLongUrlParams',
			cache: false,
			async:false,
			data: {
				"Sign": (window.location.href.split("?")[0] + name).Right(50),
				"Data": window.GetJSON(pobj)
			},
			success: function (result) {
				url = window.ReplaceUrl(url, "", "__sys_LongUrlParamsID=" + result);
			},
			error: function (rep) {}
		});
	}
	return url;
}