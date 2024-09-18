var j=-1;
var temp_str;
var $$ID = function (node) {
	return document.getElementById(node);
}
var $$=function(node){
	return document.getElementsByTagName(node);
}
function ajax_keyword(){
	var xmlhttp;
	try{xmlhttp=new XMLHttpRequest();}
	catch(e){xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}
	xmlhttp.open("post", "ajax_result.asp", true);
	xmlhttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xmlhttp.onreadystatechange=function(){
		if (xmlhttp.readyState==4){
			if (xmlhttp.status==200){
				var data=xmlhttp.responseText;
				$$ID("suggest").innerHTML =data.replace("cskt.css", "");
				j=-1;
			}
		}
	}
	xmlhttp.send("keyword="+escape($("keyword").value));
}
function keyupdeal(e){
	var keyc;
	if(window.event){
		keyc=e.keyCode;
	}else if(e.which){
		keyc=e.which;
	}
	if(keyc!=40 && keyc!=38){
		ajax_keyword();
		temp_str=$("keyword").value;
	}
}

function keyUpChangeSize(obj,e){
	var keyc;
	if(window.event){
		keyc=e.keyCode;
	}else if(e.which){
		keyc=e.which;
	}
	if (keyc==13){
	    document.getElementById("keyword").value = document.getElementById("keyword").value.replace(/[\r\n]/g, "");
	    document.getElementById("type1").value = document.getElementById("type1").value.replace(/[\r\n]/g, "");
		document.getElementById("pym").focus();
		document.getElementById("pym").select();
	}
	//else {  //增大文本框的的空间，处理有问题需要完善
	//	var oH = obj.style.height.replace("px","");
	//	if (oH<obj.scrollHeight){
	//		obj.style.height=obj.scrollHeight+5 + "px";
	//	}
	//}
}
function type1ChangeSize(obj, e) {
    var keyc;
    if (window.event) {
        keyc = e.keyCode;
    } else if (e.which) {
        keyc = e.which;
    }
    if (keyc == 13) {
        document.getElementById("type1").value = document.getElementById("type1").value.replace(/[\r\n]/g, "");
    }
}
// 阻止多行文本框换行
function textareaHandle(e) {
    var idStr = e.currentTarget.id;
    document.getElementById(idStr).value = document.getElementById(idStr).value.replace(/[\r\n]/g, "");
}

function set_style(num){
	for(var i=0;i<$$("li").length;i++){
		var li_node=$$("li")[i];
		li_node.className="";
	}
	if(j>=0 && j<$$("li").length){
		var i_node=$$("li")[j];
		$$("li")[j].className="select";
		}
}
function mo(nodevalue){
	j=nodevalue;
	set_style(j);
}
function form_submit(){
	if(j>=0 && j<$$("li").length){
		//BUG: 1485 产品修改保存按钮显示是产品名称 xieyanhui2014.3.24
		//$$("input")[0].value=$$("li")[j].childNodes[0].nodeValue;
	    $$ID("keyword").value = $$("li")[j].childNodes[0].nodeValue;
		}
	//document.search.submit();
}       
 
function hide_suggest(){
	var nodes=document.body.childNodes
	for(var i=0;i<nodes.length;i++){
	    if (nodes[i] != $$ID("keyword")) {
	        $$ID("suggest").innerHTML = "";
		}
	}
}
			
function keydowndeal(e){
	var keyc;
	if(window.event){
		keyc=e.keyCode;
	}else if(e.which){
		keyc=e.which;
	}
	if(keyc==40 || keyc==38){
	if(keyc==40){
		if(j<$$("li").length){
			j++;
			if(j>=$$("li").length){
				j=-1;
			}
		}
		if(j>=$$("li").length){
				j=-1;
			}
	}
	if(keyc==38){
		if(j>=0){
			j--;
			if(j<=-1){
				j=$$("li").length;
			}
		}
		else{
			j=$$("li").length-1;
		}
	}
	set_style(j);
	if(j>=0 && j<$$("li").length){
	    $$ID("keyword").value = $$("li")[j].childNodes[0].nodeValue;
		}
	else{
	    $$ID("keyword").value = temp_str;
		}
	}
}

//==========================================第二个表单的函数
function form_submit1(){
	if(j>=0 && j<$$("li").length){
		$$("input")[1].value=$$("li")[j].childNodes[0].nodeValue;
		}
	
}
function ajax_keyword1(){
	var xmlhttp;
	try{
		xmlhttp=new XMLHttpRequest();
		}
	catch(e){
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
	xmlhttp.onreadystatechange=function(){
	if (xmlhttp.readyState==4){
		if (xmlhttp.status==200){
			var data=xmlhttp.responseText;
			$$ID("suggest").innerHTML=data;
			j=-1;
			}
		}
	}
	xmlhttp.open("post", "ajax_result.asp", true);
	xmlhttp.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xmlhttp.send("keyword1=" + escape($$ID("keyword1").value));
}
		
function keyupdeal1(e){
	var keyc;
	if(window.event){
		keyc=e.keyCode;
		}
	else if(e.which){
		keyc=e.which;
		}
	if(keyc!=40 && keyc!=38){
		ajax_keyword1();
		temp_str = $$ID("keyword1").value;
	}
}
//Download by http://www.codefans.net
function keydowndeal1(e){
	var keyc;
	if(window.event){
		keyc=e.keyCode;
		}
	else if(e.which){
		keyc=e.which;
		}
	if(keyc==40 || keyc==38){
	if(keyc==40){
		if(j<$$("li").length){
			j++;
			if(j>=$$("li").length){
				j=-1;
			}
		}
		if(j>=$$("li").length){
				j=-1;
			}
	}
	if(keyc==38){
		if(j>=0){
			j--;
			if(j<=-1){
				j=$$("li").length;
			}
		}
		else{
			j=$$("li").length-1;
		}
	}
	set_style(j);
	if(j>=0 && j<$$("li").length){
	    $$ID("keyword1").value = $$("li")[j].childNodes[0].nodeValue;
		}
	else{
	    $$ID("keyword1").value =temp_str;
		}
	}
}