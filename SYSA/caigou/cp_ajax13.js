var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,i,id) {
  window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
  var w2 = plist.getParent(window.event.srcElement,5);
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
   var w  = document.all[nameitr];

  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?isyg=1&unit=" + escape(u_name) + "&ord=" + escape(ord) + "&num1=" + escape(num1) + "&id=" + escape(id) + "&i=" + escape(i) + "&nameitr=" + escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);  
  window.uintchangepan.innerHTML = xmlHttp.responseText;
}

function callServer5(s,nameitr,ord,id) {
  var w  =s ;
   w=document.all[w]

   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
  var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_kc(w);
  };

  xmlHttp.send(null);  
}

function updatePage_kc(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
      var response = xmlHttp.responseText;
      test6.style.display = "none";
      test6.innerHTML = response;
      resetLayerPos(test6);
      test6.style.display = "";
	  xmlHttp.abort();
  }
}

function resetLayerPos(a) {
    if(!a){return}
    var img = $(a).prev(),l,t;
    var pos = img.offset();
    var doc_h = document.documentElement.clientHeight;
    var s_top = document.documentElement.scrollTop;
    if (doc_h + s_top < pos.top + $(a).height()) { t = doc_h + s_top - $(a).height() }
    else { t = pos.top }
    l = pos.left + 16 //16=img.width()+ 6(间隔);
    $(a).css({left:l+"px",top:t+"px"})
}
function callServer6(t,nameitr,ord,id) {
   var w  =t;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function callServer2(nameitr,ord,company,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var id_show = document.getElementById("id_show").value;
   var w  = "tt"+nameitr;
   w=document.all[w]
   var w2  = "t"+nameitr;
   w2=document.all[w2]
   var w3  = document.all[nameitr];
  if (id_show != "") return;
  var url = "cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company1="+escape(company)+"&nameitr="+escape(nameitr);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,w2);
  };
  xmlHttp.send(null);  
}

function updatePage2(namei,w2) {
var test7=namei
var test6=w2
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
    test7.innerHTML = response;
    setTimeout(function () {
        var tds = $("table[name='mainSup']").find("td");
        if (tds.length == 0) { $("table[name='mainSup']").css("display", "none"); }
    }, 300)
	var id_show= document.getElementById("id_show");
	id_show.value="1"
	xmlHttp.abort();
  }
}


function callServer3(nameitr,ord,company,id) {
	var u_name = document.getElementById("u_name"+nameitr).value;
	var w  = "t"+nameitr;
	w=document.all[w];
	var w2  = "tt"+nameitr;
	w2=document.all[w2];
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gs="+escape(company)+"&nameitr="+escape(nameitr);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage3(w,nameitr,w2);
	};
	xmlHttp.send(null);  
}

function updatePage3(namei,id,w2) {
	var test7=namei
	var test6=w2
	if (xmlHttp.readyState < 4) {
		test7.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test6.innerHTML="";
		test7.innerHTML=response;
		var pricejctest= document.getElementById("pricejc"+id); 
		var pricetest= document.getElementById("price"+id);
		pricetest.value=pricejctest.value;
		chtotal(id.replace("test",""),window.sysConfig.moneynumber);
		var id_show= document.getElementById("id_show");
		id_show.value=""
		xmlHttp.abort();
	}
}

//***************限制行数，新增函数 tbh 10.12.08 ********************//

function getFreeRow(){  //获取空行
	var isAddNewPage = document.getElementById("trpx0").innerText//.length <10;
	if(isAddNewPage.indexOf("无产品明细")>-1){  //添加页面
		document.getElementById("trpx0").innerHTML = "";
		return 0;
	}
	else{									//修改页面
		window.addnewPage = false;
		var ii = 0
		while(document.getElementById("trpx" + ii)){
			if(document.getElementById("trpx" + ii).innerHTML==""){return ii;}
			ii ++; 
		}
		return -1*(ii-1);
	}
}


function moveRows(row){  //删除后填补
	var id = row.id.replace("trpx","");
	id = id * 1 + 1;
	var nextRow = document.getElementById("trpx" + id);
	if(nextRow){
		row.innerHTML = nextRow.innerHTML;
		nextRow.innerHTML = "";
		moveRows(nextRow);
	}
}

function getParent(child,parentIndex){  //获取指定级别的父节点
	for( var i= 0 ;i < parentIndex ; i++){
		child = child.parentElement;
	}
	return child;
}

// ******************************************************************//


function callServer4(ord,top,unit) {
	unit = unit || '';
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd13.asp?ord="+escape(ord)+"&top="+escape(top) + "&unit="+unit+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	plist.add(url,null);
}

function checkall(obj){
	$("input[name='delchecks']").attr("checked",obj.checked);
}

function ClearAll() {
    if (confirm('确认全部清空？')) {
        var ckboxs = $("input[name='delchecks']");
        var s = "";
        for (var i = ckboxs.length - 1; i >= 0; i--) {
            s = s + (s.length > 0 ? "," : "") + ckboxs[i].value;
        }
        if (s.length > 0) {
            var url = "del_cp.asp?id=" + escape(s) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100)
            xmlHttp.open("GET", url, false);
            xmlHttp.onreadystatechange = function () {
                if (xmlHttp.readyState == 4) {
                    for (var i = ckboxs.length - 1; i >= 0; i--) {
                        var currRow = plist.getCurrRow(ckboxs[i]);
                        currRow.innerHTML = "";
                        plist.moveRows(currRow);
                    }
                }
            };
            xmlHttp.send(null);
        }
    }
}

function delall(event) {
    if (confirm("确定批量删除吗？")) {
        var ckboxs = $("input[name='delchecks']:checked");
        var s = "";
        for (var i = ckboxs.length - 1; i >= 0; i--) {
            s = s + (s.length > 0 ? "," : "") + ckboxs[i].value;
        }
        if (s.length > 0) {
            var url = "del_cp.asp?timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100)
            xmlHttp.open("POST", url, false);
            xmlHttp.onreadystatechange = function () {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    for (var i = ckboxs.length - 1; i >= 0; i--) {
                        var currRow = plist.getCurrRow(ckboxs[i]);
                        currRow.innerHTML = "";
                        plist.moveRows(currRow);
                    }
                }
            };
            xmlHttp.setRequestHeader("Content-Length", s.length);
            xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;");
            xmlHttp.send("id=" + escape(s));
        }
    }
}

function del(str,id,event){
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
    plist.del(url,null,null,event);
}

function updatePage_del(row) {
	row.innerHTML = "";	//document.getElementById(str).style.display="none";
	moveRows(row);
}



function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	var url = "../contract/search_cp.asp?B=" + escape(B) + "&C=" + UrlEncode(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_cp();
	};
	xmlHttp.send(null);  
}
function updatePage_cp() {
  if (xmlHttp.readyState < 4) {
	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cp_search.innerHTML=response;
  }
}

function ajaxSubmit_gys(nameitr,ord,unit,id){
    //获取用户输入
	var w  = "tt"+nameitr;
    //var B=document.forms[1].B.value;
    //var C=document.forms[1].C.value;
	var B=document.date.B.value;
	var C=document.date.C.value;
    var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&id="+escape(id)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_gys(w);
  };
  xmlHttp.send(null);  
}
function updatePage_gys(w) {
 var test7=document.all[w]
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }
}

function NoSubmit(ev)

{

    if( ev.keyCode == 13 )

    {

        return false;

    }

    return true;

}



function chtotal(id,num_dot_xs) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,''); 
moneyall.value=FormatNumber(money1,num_dot_xs);
}
function chtotalzj(id, num_dot_xs) {
    var price = document.getElementById("pricetest" + id);
    var num = document.getElementById("num" + id);
    var moneyall = document.getElementById("moneyall" + id);
    var price1=0
    if (num.value.replace(/\,/g, '')!=0) {
        price1 = moneyall.value.replace(/\,/g, '') / num.value.replace(/\,/g, '');
    }
    price.value = FormatNumber(price1, num_dot_xs);
}

function callServer2_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   var u_name = document.getElementById("u_name"+nameitr).value;
   var gys = document.getElementById("gys_"+id).value;
   if ((u_name == null) || (u_name == "")) return;
  var url = "cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2_ls(w);
  };

  xmlHttp.send(null);  
}

function updatePage2_ls(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
      var response = xmlHttp.responseText;
      test6.style.display = "none";
      test6.innerHTML = response;
      resetLayerPos(test6);
      test6.style.display = "";
      xmlHttp.abort();
  }

}


function callServer3_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}


function callServer3_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}

//by chenwei20100909
function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}
//解决预购添加产品时更改之前选择的基本单位，其它已输入完成的文本框的值都清空的问题！ 
function SaveValue(nameitr,xsord,xIn,xId)
{	
	var company=0;
	if(document.getElementById("gys_"+xId)){
	company=document.getElementById("gys_"+xId).value
	};
	var u_name = document.getElementById("u_name"+nameitr).value;
	var w  = "t"+nameitr;
	w=document.all[w];
	var w2  = "tt"+nameitr;
	w2=document.all[w2];
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu7.asp?unit=" + escape(u_name)+"&ord="+escape(xsord)+"&id="+escape(xId)+"&gs="+escape(company)+"&nameitr="+escape(nameitr);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage7(w,nameitr,w2);
	};
	xmlHttp.send(null);  
}

function updatePage7(namei,id,w2) {
	var test7=namei
	var test6=w2
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		var ps = response.split("|");
		var p1 = ps[0];
		document.getElementById("price"+id).value = p1;
		chtotal(id.replace("test",""),window.sysConfig.moneynumber);
		if(ps.length>1){
			var p2 = ps[1];
			document.getElementById("price"+id).setAttribute("max" , p2);
		}
		xmlHttp.abort();
	}
}

