
function ask() {
  date.submit();
}


function callServer(nameitr)
{
	var u_name = document.getElementById("u_name"+nameitr).value;
	var w  = document.all[nameitr];
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu.asp?name=" + escape(u_name);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage(w);};
	xmlHttp.send(null);
}

function updatePage(namei)
{
	var test7=namei
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test7.innerHTML=response;
	}
}

function callServer2()
{
	var unit1 = document.getElementById("unit1").value;
	if ((unit1 == null) || (unit1 == "")) return;
	var url = "cuunit.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage2(unit1);};
	xmlHttp.send(null);
}

function updatePage2(unit1)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx0.innerHTML="";
		trpx0.innerHTML=response;
		var url1 = "cuunit3.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage3();};
		xmlHttp.send(null);
  }
}

function updatePage3()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
		xmlHttp.abort();
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
	}
}

function callServer4(ord)
{
	if ((ord == null) || (ord == "")) return;
	var url = "num_click.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage4(ord);};
	xmlHttp.send(null);
}

function updatePage4(ord)
{
	if (xmlHttp.readyState == 4)
	{
		var res = xmlHttp.responseText;
		var w  = "trpx"+res;
		w=document.all[w]
		var url = "cuunit2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){updatePage5(w,ord);};
		xmlHttp.send(null);
	}
}

function updatePage5(w,unitall)
{
	var test3=w;
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		var url1 = "cuunit4.asp?unitall=" + escape(unitall)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage6();};
		xmlHttp.send(null);
	}
}

function updatePage6()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage7();};
		xmlHttp.send(null);
  }
}

function updatePage7()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
		xmlHttp.abort();
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
	}
}

function del(str,id)
{
	var w  = document.all[str];
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_del(w);};
	xmlHttp.send(null);
}

function updatePage_del(str)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		str.innerHTML="";
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage8();};
		xmlHttp.send(null);
  }
}

function updatePage_del2(str)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		document.getElementById(str).style.display="none";
		var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage7();};
		xmlHttp.send(null);
	}
}

function updatePage8()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
		var url1 = "cuunit4.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url1, true);
		xmlHttp.onreadystatechange = function(){updatePage9();};
		xmlHttp.send(null);
	}
}

function updatePage9()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
		xmlHttp.abort();
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
	}
}

function checkAll7(str)
{
	var a=document.getElementById("Wd"+str).getElementsByTagName("input");
	var b=document.getElementById("Wt"+str);
	for(var i=0;i<a.length;i++){a[i].checked=b.checked;}
}


function CheckSelection()
{
	var rvalue=false;
	try
	{
		if(document.getElementById("rbtn2").checked)
		{
			var ulist=document.getElementsByName("W1");
			var notchecked=true;
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W2");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W3");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}

			if(notchecked)
			{
				document.getElementById("ulist1").innerText="请选择可操作范围";
				rvalue = false;
			}
			else
			{
				document.getElementById("ulist1").innerText="";
				rvalue = true;
			}
		}
		else
		{
			rvalue = true;
		}
	}
	catch(e3){}
	finally
	{return rvalue;}
}


function keydown()
{
	if(event.keyCode==13)
	{
		event.keyCode=9
	}
	else
	{
		keydowndeal(event)
	}
}

function keydown1()
{
	if(event.keyCode==13)
	{
		event.keyCode=9
		hide_suggest()
	}
}

function onKeyPress()
{
	if(event.keyCode!=46 && event.keyCode!=45 && (event.keyCode<48 || event.keyCode>57)) event.returnValue=false
}

function callServer_ts(m,name1)
{
	var u_name = document.getElementById(name1).value;
	var w2  = "test"+m;
	w2=document.all[w2]
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_ts.asp?name=" + UrlEncode(u_name) + "&ord=" + m + "&timestamp=" + new Date().getTime() + "&date7=" + Math.round(Math.random() * 100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_ts(w2,m);};
	xmlHttp.send(null);
}

function updatePage_ts(w,m)
{
	var test6=w
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test6.innerHTML=response;
		if(response.indexOf("已存在")>=0)
		{
			document.getElementById("flag"+m).value="0";
		}
		else
		{
			document.getElementById("flag"+m).value="0";
		}
	}
}

function formCheck()
{
	if(document.getElementById("flag1").value=="1"||document.getElementById("flag2").value=="1"||document.getElementById("flag3").value=="1")
	{
		return false;
	}
	else
	{
		return true;
	}
}

window.__ChangeMenuArea = function(){		//--获取session中的分类的可调用范围
	var resTxt, arr_res, ulist1_load
	var ulist1_load = document.getElementById("ulist1_load");//--页面加载时，防止刷新可用范围；
	if (!ulist1_load)
	{
		var ulist1_load = document.createElement("input");
		ulist1_load.type = "hidden";
		ulist1_load.id = "ulist1_load";
		ulist1_load.value = "0";
		document.body.appendChild(ulist1_load);
	}
	if (ulist1_load.value == "0")
	{
		ulist1_load.value = "1";
		return;
	}
	var url = "../product/UserList_Ajax.asp";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var r = xmlHttp.responseText;
			if(r != ""){
				document.getElementById("rbtn1").checked = false;
				document.getElementById("rbtn2").checked = true;
				document.getElementById("tb1").children[0].innerHTML = r;
			}
			else
			{
				document.getElementById("rbtn1").checked = true;
				document.getElementById("rbtn2").checked = false;
			}
		}
	};
	xmlHttp.send(null);
}

function User_ListChooses(data) {
    document.getElementById("allcansee").value = data.allcansee;
    document.getElementById("member2").value = data.ords;
    document.getElementById("showText").value = data.showText;
}


function openurl() {
    var ords = document.getElementById("member2").value;
    window.open('User_ListChoose.asp?user_list=' + ords + '', 'newwin5', 'width=' + 800 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');

}


function checktype(type, obj) {
    window.event.cancelBubble = true
    var checkbox = document.getElementById('Role' + type);
    var j = 0;
    var Roles = "";
    var a = document.getElementsByName("Roles");
    for (var i = 0; i < a.length; i++) {
        if (a[i].checked == true) {
            if (a[i].value == 1 || a[i].value == 2)
            j++;
            Roles += a[i].value;
        }
    }
    if (j == 0) {
        if (document.getElementById('sc')) {
            $ID("sc").style.display = 'none';
        }
        if (document.getElementById('sc2')) {
            $ID("sc2").style.display = 'none';
        }
    }
    else {
        if (document.getElementById('sc')) {
            document.getElementById('sc').style.display = '';
        }
        if (document.getElementById('sc2')) {
            document.getElementById('sc2').style.display = '';
        }
    }
    if (document.getElementById('priceMode')) {
        var PriceMode = document.getElementById('priceMode');
        if (Roles.indexOf("1") >= 0 || Roles.indexOf("2") >= 0) {
            $(PriceMode).find("option").each(function () {
                if ($(this).val() == "3") {
                    $(this).remove();
                }
            });
        } else {
            $(PriceMode).empty();
            PriceMode.options.add(new Option("先进先出法", "0"));
            PriceMode.options.add(new Option("移动加权平均法", "3"));
            PriceMode.options.add(new Option("个别计价法", "1"));
            PriceMode.options.add(new Option("全月平均法", "2"));
        }
    }
}

function showHelpExplan(type) {
    DIVShowOrHidden(type, true);
}
function closediv(type) {
    DIVShowOrHidden(type, false);
}

function DIVShowOrHidden(type, isShow) {
    window.event.cancelBubble = true;
    var divId = "bill_help_expaln_text1";
    switch (type) {
        case 1: divId = "bill_help_expaln_text"; break;
        case 2: divId = "bill_help_expaln_text1"; break;
        case 3: divId = "bill_help_expaln_text3"; break;
        case 4: divId = "bill_help_expaln_text4"; break;
    }
    if (divId.length > 0) {
        document.getElementById(divId).style.display = isShow ? "block" : "none";
    }
}

function openTaxPreferenceType() {
    var ords = document.getElementById("InvoiceTitle").value;
    if (ords.length == 0 && document.getElementById("keyword").value.length > 0) {
        ords = document.getElementById("keyword").value;
    }
    window.open('../../sysn/view/AutoCompletes/ProductTaxNumPage.ashx?queryParam=' + encodeURIComponent(ords) + '', 'newwin5', 'width=' + 1400 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}

var Bill = new Object();
//鼠标点击以及回车返回数据过程
Bill.SendDataFromAutoTable = function (srcobjId, data) {
    document.getElementById("TaxClassifyMergeCoding").value = data[0].ID;
    document.getElementById("TaxPreferenceTypeMergeCoding").value = data[0].MergeCoding;
    document.getElementById("TaxPreferenceTypeName").innerHTML = data[0].GoodsName;
    document.getElementById("TaxPreferenceTypeJName").innerHTML = data[0].ClassifyShorterForm;
}

jQuery(function () {
    jQuery(':radio[name="TaxPreference"]').click(function () {
        var $o = jQuery(this);
        if ($o.val() == "1") {
            jQuery("#TaxPreferenceType0").show();
            jQuery("#TaxPreferenceType1").show();
        } else {
            jQuery("#TaxPreferenceType0").hide();
            jQuery("#TaxPreferenceType1").hide();
        }
    });
})