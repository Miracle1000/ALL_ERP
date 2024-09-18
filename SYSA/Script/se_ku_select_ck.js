
function add(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck,rid) {
    var blnum = document.getElementById("blnum" + ckid + "_" + rid).value;//辅助数量
    var blnum1 = document.getElementById("blnum1" + ckid + "_" + rid).value;//初始库存
    var Ismode = document.getElementById("Ismode" + ckid + "_" + rid).value;//区分库存单位是否跟指定的一致
    var AssistUnit = document.getElementById("AssistUnit" + ckid + "_" + rid).value;//辅助单位
    var num1 = document.getElementById("num1" + ckid + "_" + rid).value;
    var num1old = document.getElementById("num1old" + ckid + "_" + rid).value;
  var num3 = document.getElementById("num1").value;
  var AssistNum = 0;
    //计算辅助数量
  if (document.getElementById("fznum" + ckid + "_" + rid)) {
      if (parseFloat(blnum1) > 0 && parseFloat(blnum) > 0 && num1 > 0) {
          if (Ismode == 1) {
              document.getElementById("fznum" + ckid + "_" + rid).value = FormatNumber(parseFloat(num1) * parseFloat(blnum) / parseFloat(blnum1), window.sysConfig.floatnumber);
          } else {
              document.getElementById("fznum" + ckid + "_" + rid).value = FormatNumber(parseFloat(num1) * parseFloat(blnum1) / parseFloat(blnum), window.sysConfig.floatnumber);
          }
      } else {
          document.getElementById("fznum" + ckid + "_" + rid).value = "";
      }
      AssistNum = document.getElementById("fznum" + ckid + "_" + rid).value;
  }
  var zdy1=window.ckzdy1;
  var zdy2=window.ckzdy2;
  var zdy3=window.ckzdy3;
  var zdy4=window.ckzdy4;
  var zdy5=window.ckzdy5;
  var zdy6=window.ckzdy6;

    
  if  ( Number(num1) >  Number(num1old)) return;
  var url = "cu_kuin_ck.asp?Ismode=" + Ismode + "&AssistUnit=" + AssistUnit + "&AssistNum=" + AssistNum + "&zdy1=" + escape(zdy1) + "&zdy2=" + escape(zdy2) + "&zdy3=" + escape(zdy3) + "&zdy4=" + escape(zdy4) + "&zdy5=" + escape(zdy5) + "&zdy6=" + escape(zdy6) + "&ord=" + escape(ord) + "&num1=" + escape(num1) + "&num1old=" + escape(num1old) + "&num3=" + escape(num3) + "&id=" + escape(id) + "&sort_ck=" + escape(sort_ck) + "&contractlist=" + escape(contractlist) + "&kuout=" + escape(kuout) + "&kuoutlist=" + escape(kuoutlist) + "&ckid=" + escape(ckid) + "&rid=" + escape(rid) + "&MOrderID=" + window.MOrderID + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
  var w2 = "trpx" + ckid;
  w2 = document.all[w2]
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
    updatePage(w2);
  };
  
  xmlHttp.send(null);  
}

function update(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck, rid)
{
    var Ismode = document.getElementById("Ismode" + ckid + "_" + rid).value;//区分库存单位是否跟指定的一致
    var fzunit = document.getElementById("fzunit" + ckid + "_" + rid).value;//是否开启辅助单位
    var fznumold = document.getElementById("fznumold" + ckid + "_" + rid).value;
    var AssistUnit = document.getElementById("AssistUnit" + ckid + "_" + rid).value;//辅助单位
    var num1 = document.getElementById("num1" + ckid + "_" + rid).value;
    var num1old = document.getElementById("num1old" + ckid + "_" + rid).value;
    var num3 = document.getElementById("num1").value;
    var AssistNum = document.getElementById("fznum" + ckid + "_" + rid).value;
    var zdy1 = window.ckzdy1;
    var zdy2 = window.ckzdy2;
    var zdy3 = window.ckzdy3;
    var zdy4 = window.ckzdy4;
    var zdy5 = window.ckzdy5;
    var zdy6 = window.ckzdy6;
    if (Number(AssistNum) > Number(fznumold)) {
        alert("大于库存数量！")
        add(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck , rid)
        return ;
    }
    if (fzunit == 1 && AssistNum == 0 && num1>0)
    {

        alert("辅助数量不能为0！")
        add(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck,rid)
        return;
    }
    if (fzunit == 1 && (Number(AssistNum) != Number(fznumold) && Number(num1)== Number(num1old))) {

        alert("与剩余辅助数量不匹配！")
        document.getElementById("fznum" + ckid + "_" + rid).value = document.getElementById("fznum" + ckid + "_" + rid).defaultValue;
        document.getElementById("num1" + ckid + "_" + rid).value = document.getElementById("num1" + ckid + "_" + rid).defaultValue;
        add(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck,rid)
        return;
    }
    if (fzunit == 1 && (Number(AssistNum) == Number(fznumold) && Number(num1) != Number(num1old))) {

        alert("与剩余辅助数量不匹配！")
        document.getElementById("fznum" + ckid + "_" + rid).value = document.getElementById("fznum" + ckid + "_" + rid).defaultValue;
        document.getElementById("num1" + ckid + "_" + rid).value = document.getElementById("num1" + ckid + "_" + rid).defaultValue;
        add(ord, id, contractlist, kuout, kuoutlist, ckid, sort_ck,rid)
        return;
    }
    
    if (Number(num1) > Number(num1old)) return;
    var url = "cu_kuin_ck.asp?Ismode=" + Ismode + "&AssistUnit=" + AssistUnit + "&AssistNum=" + AssistNum + "&zdy1=" + escape(zdy1) + "&zdy2=" + escape(zdy2) + "&zdy3=" + escape(zdy3) + "&zdy4=" + escape(zdy4) + "&zdy5=" + escape(zdy5) + "&zdy6=" + escape(zdy6) + "&ord=" + escape(ord) + "&num1=" + escape(num1) + "&num1old=" + escape(num1old) + "&num3=" + escape(num3) + "&id=" + escape(id) + "&sort_ck=" + escape(sort_ck) + "&contractlist=" + escape(contractlist) + "&kuout=" + escape(kuout) + "&kuoutlist=" + escape(kuoutlist) + "&ckid=" + escape(ckid) + "&MOrderID=" + window.MOrderID + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);

    var w2 = "trpx" + ckid;
    w2 = document.all[w2]
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage(w2);
    };

    xmlHttp.send(null);
}


function updatePage(w2) {
    var test6=w2
    if (xmlHttp.readyState < 4) {
        trpx.innerHTML="loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        trpx.innerHTML=response;
        xmlHttp.abort();
    }
}

function ck() { 
	var w = document.getElementById("alli").value;
	for(var i=1; i<=w; i++){
	document.getElementById("ck"+i).value = document.getElementById("ckall").value;
	var id = document.getElementById("id"+i).value;
	var ord = document.getElementById("ord_"+i).value;
	ckxz(ord,i,id)
	}
}

function del(str,id){
	
	var w  = str;
	
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del(str) {
document.getElementById(str).style.display="none";

}



function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
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

function ajaxSubmit_gys(nameitr,ord,unit){
    //获取用户输入
	var w  = "tt"+nameitr;
    var B=document.forms[1].B.value;
    var C=document.forms[1].C.value;
    var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function chtotal(id) 
{ 
	var price= document.getElementById("pricetest"+id); 
	var num= document.getElementById("num"+id); 
	var moneyall= document.getElementById("moneyall"+id);
	var money1=price.value * num.value 
	moneyall.value=FormatNumber(money1,2)
}


function check_ck(ord,id,contractlist,kuout,kuoutlist,i,sort_ck,rid)
{
    var num1 = document.getElementById("num1" + i + "_" + rid).value;
    var num1old = document.getElementById("num1old" + i + "_" + rid).value;
	var num3 = document.getElementById("num3").value;
	var numsum=0;
	var allNum1=document.getElementsByName("num1_"+window.requestID);
	for(var j=0;j<allNum1.length;j++)
	{
		if(allNum1[j].id.toString().indexOf("num1old")<0)
		{
 			numsum=accAdd(numsum,(isNaN(allNum1[j].value)||allNum1[j].value=="")?0:parseFloat(allNum1[j].value));
			//numsum+=(isNaN(allNum1[j].value)||allNum1[j].value=="")?0:parseFloat(allNum1[j].value);
		}
	}
   var numall= document.getElementById("num1").value;

	if ( isNaN(num1) || (num1 == "") )
	{
		alert("只能输入数字！")
		document.getElementById("num1" + i + "_" + rid).value = document.getElementById("num1" + i + "_" + rid).defaultValue
		add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck,rid)
		return true;
	}

  if (Number(num1) > Number(num1old))
  {
      alert("大于库存量！")
      document.getElementById("num1" + i + "_" + rid).value = document.getElementById("num1" + i + "_" + rid).defaultValue
		add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck,rid)
		return true;
  }
  if (Number(numsum) > Number(numall))
  {
	  alert("大于应指定总数"+numall+"!")
	  document.getElementById("num1" + i + "_" + rid).value = document.getElementById("num1" + i + "_" + rid).defaultValue;
	  add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck,rid)
	  return true;
  }
  document.getElementById("num1" + i + "_" + rid).value = Number(num1)
	return true;
}

//flg表示是否在检索到结果后指定数量自动增加
var xlhLast="";
function PageSearch(obj, flg) {
    if (event.keyCode != 13) return;
    var stxt=obj.value;
    var xlhfind=false;
    var tbobj = document.getElementById("content");
    var Url = $("form").attr("action");
    var httpUrl = Url.split("?")[0] + "?ord" + Url.split("&ord")[1].split("&Searchkey")[0];
    if (flg) {
        $("form").attr("action", httpUrl + "&isMode=1&Searchkey=" + UrlEncode(stxt));
    }
    else {
        $("form").attr("action", httpUrl + "&Searchkey=" + UrlEncode(stxt));
    }
    $("form").submit();
}
function PageSearch1(stxt){
    var tbobj = document.getElementById("content");
    var xlhfind = false;
	for(var i=2;i<tbobj.rows.length;i++){
		//3序列号，6现有数量，7指定数量
		if(stxt.length>0){
			if($(tbobj.rows[i]).attr("tag").toLowerCase().indexOf(stxt.toLowerCase())>=0){
				tbobj.rows[i].style.display="";
					var nowNum=parseFloat($(tbobj.rows[i]).find("input[name='num1_"+window.requestID+"']").eq(0).val());
					var cobj=$(tbobj.rows[i]).find("input[name='num1_"+window.requestID+"']").eq(1)[0];
					var curNum=parseFloat(cobj.value);
					if(nowNum>curNum){
						if(!xlhfind){
							cobj.value=nowNum;//定制的用这句，通用版用上面那句
							cobj.onchange();
							xlhfind=true;
						}
					}
			}
			else{
				tbobj.rows[i].style.display="none";
			}

		}
		else{
			tbobj.rows[i].style.display="";
		}
	}
	//obj.value="";

}

//格式化内容
function formatData(obj, type)
{
	var ov = obj.getAttribute("oldvalue");
	var v = obj.value;
	var fnum = "a";
	if(window.event.propertyName!="value") {return;}
	if(obj.getAttribute("fving")==1) {return;}
	if(!type) {type = obj.getAttribute("datatype");}
	if(!ov && ov!=="") {ov = obj.defaultValue;}
	switch(type)
	{
		case "float":
			v = v.replace(" ","z");  //使空格不为数字
			if(isNaN(v)){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}
			break;
		case "money":
			fnum = window.sysConfig.moneynumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number":
			fnum = window.sysConfig.floatnumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "int":
			if(isNaN(v) || v.indexOf(".") >= 0){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}
			break;
		default:
	}
	if(!isNaN(fnum))
	{
		var cv = v;
		var f = isNaN(v)
		if( f == false )
		{
			var s = v.toString().split(".");
			if(s.length==2){
				if(s[1].length > fnum){
					s[1] = s[1].substr(0,fnum);
				}
				v = s[0] + "." + s[1]
			}
		}
		else{
			if(v.replace(/\s/g,"").length==0) {
				v = "0";
				window.setTimeout(function (){obj.select();},100);
			}
			else{
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
