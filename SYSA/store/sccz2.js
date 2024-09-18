isIE = (document.all ? true : false);
function add(ord, i, id) {
    var unit1 = document.getElementById("unit" + i).value;
    var num1 = document.getElementById("num" + i).value;
    var moneyall = document.getElementById("moneyall" + i).value;
    var ck = document.getElementById("ck" + i).value;
    var bz = document.getElementById("bz2_" + i).value;
    var js = document.getElementById("js" + i).value;
    var intro = document.getElementById("intro" + i);
    intro = intro ? intro.value : "";
    var w2 = "trpx" + (i - 1) + "_" + id;
    w2 = document.all[w2]
    if (isNaN(num1) || (Number(num1) >= Number(num1old)) || (num1 == "") || (Number(num1) == 0)) return;
    var url = "cu_ck.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&num1old=" + escape(num1old) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&moneyall=" + escape(moneyall) + "&ck=" + escape(ck) + "&ph=" + escape(ph) + "&xlh=" + escape(xlh) + "&datesc=" + escape(datesc) + "&dateyx=" + escape(dateyx) + "&bz=" + escape(bz) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage(w2);
    };
    xmlHttp.send(null);
}

function updatePage(w2) {
    var test6 = w2
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test6.innerHTML = response;
        xmlHttp.abort();
    }
}

function ph() {
    var w = document.getElementById("alli").value;
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("ph2_" + i)) {
            document.getElementById("ph2_" + i).value = document.getElementById("phall").value;
        }
    }
    xmlHttp.abort();
}
function xlh() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("xlh2_" + i)) {
            document.getElementById("xlh2_" + i).value = document.getElementById("xlhall").value;
        }
    }
    xmlHttp.abort();
}
function datesc() {
    var ret7 = jQuery("#daysOfMonth7Pos").val();	
	jQuery("input[name^='datesc_'").each(function(){
		jQuery(this).val(ret7);
		jQuery(this).change();
	});
}
function dateyx() {
    var ret8 = jQuery("#daysOfMonth8Pos").val();
	jQuery("input[name^='dateyx_'").each(function(){
		jQuery(this).val(ret8);
		jQuery(this).change();
	});
}
function bz() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("bz2_" + i)) {
            document.getElementById("bz2_" + i).value = document.getElementById("bzall").value;
        }
    }
    xmlHttp.abort();
}
function bzz() {
    for (var i = 0; i < 1000; i++) {
        if (document.getElementById("bz" + i)) {
            document.getElementById("bz" + i).value = document.getElementById("bzall_2").value;
        }
    }
    xmlHttp.abort();
}

function ck(num_dot_xs, cw_id,event) {
	
    if (cw_id) { // id混乱，直接判断截取重写操作。
		event = (event||window.event);
		var e = event.srcElement ? event.srcElement : event.target;
        var v = e.value;
        var txt = e.text;
        if (!txt) { txt = $(e).attr("text"); }
        var boxs = document.getElementById("main_lists").getElementsByTagName("input");
        for (var i = 0; i < boxs.length; i++) {
            if (boxs[i].getAttribute("msg") == "请选择仓库") {
                boxs[i].value = v;
				boxs[i].setAttribute("text",txt);
				document.getElementById("for_" + boxs[i].id).style.cssText="height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
				document.getElementById("for_" + boxs[i].id).title = txt; 
				document.getElementById("for_" + boxs[i].id).value = txt; 
				//boxs[i].fireEvent("onchange");
				$(boxs[i]).trigger("change");
            }
        }
        return;
    }
    return;
    var w = document.getElementById("alli").value;
    for (var i = 1; i <= 1000; i++) {
        if (document.getElementById("ck" + i)) {
            document.getElementById("ck" + i).value = document.getElementById("ckall").value;
            var id = document.getElementById("id" + i).value;
            var id1 = document.getElementById("id1_" + i).value;
            var ord = document.getElementById("ord_" + i).value;
            var w2 = document.getElementById("w" + i).value;
            ckxz(ord, i, id, id1, w2, 1, num_dot_xs)
            xmlHttp.abort();
        }
    }
}

function ckk() {
	//document.writeln(document.getElementById("zbmxlist").innerHTML);
	var v = document.getElementById("ckall").value;
	var txt = document.getElementById("ckall").getAttribute("text");
    for (var i = 0; i <= 1000; i++) {
		var obj =  document.getElementById("ck" + i);
        if (obj) {
            obj.value = v;
			obj.setAttribute("text",txt);
			document.getElementById("for_" + obj.id).style.cssText = "height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
			document.getElementById("for_" + obj.id).title = txt;
            document.getElementById("for_" + obj.id).value = txt;
            try {
                var errorDom = $("#for_" + obj.id).parent().next()
                if (errorDom.text() == "请选择仓库") { errorDom.remove(); }
            } catch(err){ }

			//obj.fireEvent("onChange");
			$(obj).trigger("change");
        }
    }
    //xmlHttp.abort();
}

function ckk2() {
	var v = document.getElementById("ckall").value
	var txt = document.getElementById("ckall").text
    for (var i = 0; i <= 1000; i++) {
		var obj =  document.getElementById("ck" + i)
        if (obj) {
            obj.value = v;
			obj.setAttribute("text",txt);
			document.getElementById("for_" + obj.id).style.cssText = "height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
			document.getElementById("for_" + obj.id).title = txt;
			document.getElementById("for_" + obj.id).value = txt;
			//obj.fireEvent("onchange");
			$(obj).trigger("change");
        }
    }
}

function newbom(unit,pid,top,str,id,productAttr1,productAttr2){
	window.vs= document.getElementById("trpx_"+id).parentNode;
    del2(str,id,unit);
    callServer4_1(unit, pid, top, productAttr1, productAttr2);
}


function del2(str, id,unit) {
    var w = str;
    var url = "del_cpcz.asp?id=" + escape(id) + "&unit="+unit+"&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100)
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
		if (xmlHttp.readyState==4) 
		{
			updatePage_del2(w, id);
		}
    };
    xmlHttp.send(null);
}

function updatePage_del2(str, id) {
    var v = document.getElementById("trpx_" + id);
    v.innerHTML = "";
    var w = "cktrpx" + id
    if (document.getElementById(w)) {
        document.getElementById(w).innerHTML = "";
		UpdatePrice();
    }
}

function del(str, id, id1) {
    window.delobj = document.getElementById(str); //明细
    var w = str;
    var url = "../caigou/del_cp.asp?iszz=1&id=" + escape(id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100)
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
		if (xmlHttp.readyState==4) 
		{
		    var money1 = 0;
		    if (document.getElementById("moneyall" + id)) {
		        money1 = document.getElementById("moneyall" + id).value.replace(/\,/g, '');//明细总价
		    }
			//var moneyall = document.getElementById("moneyall2_" + id1).value.replace(/\,/g, '');
//			var price = document.getElementById("pricetest2_" + id1).value.replace(/\,/g, '');
//			var num = document.getElementById("num2_" + id1).value.replace(/\,/g, '');
		    var price0 = document.getElementById("pricetest" + id).value.replace(/\,/g, '');
			var num0 = document.getElementById("num" + id).value.replace(/\,/g, '');
//
//			document.getElementById("pricetest2_" + id1).value = (moneyall - (price0 * num0)) / num;
//			document.getElementById("moneyall2_" + id1).value = moneyall - (price0 * num0);
//			if(parseInt(document.getElementById("moneyall2_" + id1).value)<0){
//				document.getElementById("moneyall2tips_"+id1).innerHTML="<font color='red'>父件价格不正确</font>";
//				alert("请重新输入父件和子件的价格!");
		    //			}
		    //合计数量总价
		    if (document.getElementById("sumnums" + id1)) {
		        var sumnum1 = document.getElementById("sumnums" + id1).innerHTML.replace(/\,/g, '');
		        var summoney1 = document.getElementById("summoney" + id1).innerHTML.replace(/\,/g, '');
		        document.getElementById("sumnums" + id1).innerHTML = FormatNumber((sumnum1 - num0), window.sysConfig.floatnumber);
		        document.getElementById("summoney" + id1).innerHTML = FormatNumber(((summoney1 - (money1))), window.sysConfig.moneynumber);
		        if (FormatNumber((sumnum1 - num0), window.sysConfig.floatnumber) == 0 && (FormatNumber(summoney1 - (price0 * num0), window.sysConfig.moneynumber)) == 0) {
		            $("#sumspan" + id1).remove();
		        }
		    }
			updatePage_del(w, id, id1);
		}
    };
    xmlHttp.send(null);
}
function updatePage_del(str, id, id1) {
    if (window.delobj) {
        window.delobj.innerHTML = "";
		UpdatePrice();
    }
}

function ajaxSubmit(sort1) {
    //获取用户输入
    var B = document.forms[0].B.value;
    var C = document.forms[0].C.value;
    var top = document.forms[0].top.value;
    var url = "search_cp.asp?jybom=1&B=" + escape(B) + "&C=" + escape(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_cp();
    };
    xmlHttp.send(null);
}
function updatePage_cp() {
    if (xmlHttp.readyState < 4) {
        cp_search.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        cp_search.innerHTML = response;
        xmlHttp.abort();
    }
}

function ajaxSubmit_gys(nameitr, ord, unit) {
    //获取用户输入
    var w = "tt" + nameitr;
    var B = document.forms[1].B.value;
    var C = document.forms[1].C.value;
    var url = "cu2.asp?unit=" + escape(unit) + "&ord=" + escape(ord) + "&nameitr=" + escape(nameitr) + "&B=" + escape(B) + "&C=" + escape(C) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_gys(w);
    };
    xmlHttp.send(null);
}
function updatePage_gys(w) {
    var test7 = document.all[w]
    if (xmlHttp.readyState < 4) {
        test7.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test7.innerHTML = response;
        xmlHttp.abort();
    }
}

function NoSubmit(ev) {
    if (ev.keyCode == 13) {
        return false;
    }
    return true;
    xmlHttp.abort();
}

function chtotal(id, id1, num_dot_xs,unit,ord,i) {
    var price = document.getElementById("pricetest" + id);
    var num = document.getElementById("num" + id);
    numb = (num.getAttribute("zdnumvalue") || num.getAttribute("zdnumvalue")==0) ? num.getAttribute("zdnumvalue") : num.value ;  //zdnumvalue是已指定的数量，随机出库的时候为空
	numb = numb.replace(",", "");
    pric = price.value;
    pric = pric.replace(",", "");
    if (isNaN(numb)) {
        num.value = 0;
        numb = 0;
    }
    if (isNaN(pric)) {
        price.value = 0.00;
        pric = 0;
    }
    var moneyall = document.getElementById("moneyall" + id);
    money_old = Number(moneyall.value.replace(/\,/g,""));
    var money1 = Number(pric) * Number(numb);
    moneyall.value = FormatNumber(money1, num_dot_xs);
    var moneyalls = 0;
    var sumnums = 0;
    for (var i = 0, e; i < document.getElementById("cktrpx" + id1).childNodes.length; i++) {
        e = document.getElementById("cktrpx" + id1).childNodes[i]
        if (e.tagName == 'SPAN') {
            try {
                var tr = e.childNodes[0].rows[0];
                for (var iii = 0; iii < tr.cells.length; iii++) {
                    if (tr.cells[iii].childNodes.length > 0) {
                        var DIV = tr.cells[iii].childNodes[0];
                        if (DIV && DIV.tagName == 'DIV') {
                            var INPUT = DIV.childNodes[0];
                            if (INPUT.tagName == 'INPUT') {
                                if (INPUT.name.toLowerCase().indexOf('moneyall') > -1) {
                                    cmoney = 0;
                                    cmoney = INPUT.value;
                                    if (!isNaN(cmoney)) {
                                        moneyalls = parseFloat(moneyalls) + parseFloat(cmoney);
                                    }
                                }
                                if (INPUT.name.toLowerCase().indexOf('num1_') > -1) {
                                    sumnum = 0;
                                    sumnum = INPUT.value;
                                    if (!isNaN(sumnum) && sumnum != "") {
                                        sumnums = parseFloat(sumnums) + parseFloat(sumnum);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (e) { }
        }
    }
    $("#summoney" + id1).text(FormatNumber(moneyalls, num_dot_xs))
    if (!isNaN(sumnum)) {
        $("#sumnums" + id1).text(FormatNumber(sumnums, window.sysConfig.floatnumber))
    } else { $("#sumnums" + id1).text(FormatNumber(0, window.sysConfig.floatnumber)) }
  //  var thismoneyall = document.getElementById("moneyall2_" + id1);
   // var num2 = document.getElementById("num2_" + id1).value;
  //  var moneyall2 = document.getElementById("moneythisall_" + id1);
  //  money3 = FormatNumber(Number(moneyall2.value), num_dot_xs);
   // money3 = Number(money3) - Number(money_old);   //新和=旧和-原值+新值
   // money3 = Number(money3) + Number(money1);
	//合计金额 baiyong
   // moneyall2.value = FormatNumber(money3, num_dot_xs);
    //price2.value = FormatNumber(money3 / num2, num_dot_xs);
    UnitCustomFun(0, ord, "num", id, i);
    xmlHttp.abort();
}

//子件输入算单价
function chtotal4(id, id1, num_dot_xs, unit, ord, i) {   
    var num = document.getElementById("num" + id);
    var moneyall = document.getElementById("moneyall" + id);
    numb = (num.getAttribute("zdnumvalue") || num.getAttribute("zdnumvalue") == 0) ? num.getAttribute("zdnumvalue") : num.value;  //zdnumvalue是已指定的数量，随机出库的时候为空
    numb = numb.replace(",", "");
    if (isNaN(numb)) {
        num.value = 1;
    }
    if (isNaN(moneyall.value)) {
        moneyall.value = 0.00;
    }

    var price = document.getElementById("pricetest" + id);
    var Dj = Number(moneyall.value)/Number(numb);
    price.value = FormatNumber(Dj, window.sysConfig.StorePriceDotNum);
    var moneyalls = 0;
    var sumnums = 0;
    for (var i = 0, e; i < document.getElementById("cktrpx" + id1).childNodes.length; i++) {
        e = document.getElementById("cktrpx" + id1).childNodes[i]
        if (e.tagName == 'SPAN') {
            try {
                var tr = e.childNodes[0].rows[0];
                for (var iii = 0; iii < tr.cells.length; iii++) {
                    if (tr.cells[iii].childNodes.length > 0) {
                        var DIV = tr.cells[iii].childNodes[0];
                        if (DIV && DIV.tagName == 'DIV') {
                            var INPUT = DIV.childNodes[0];
                            if (INPUT.tagName == 'INPUT') {
                                if (INPUT.name.toLowerCase().indexOf('moneyall') > -1) {
                                    cmoney = 0;
                                    cmoney = INPUT.value;
                                    if (!isNaN(cmoney) && cmoney != "") {
                                        moneyalls = parseFloat(moneyalls) + parseFloat(cmoney);
                                    }
                                }
                                if (INPUT.name.toLowerCase().indexOf('num1_') > -1) {
                                    sumnum = 0;
                                    sumnum = INPUT.value;
                                    if (!isNaN(sumnum) && sumnum != "") {
                                        sumnums = parseFloat(sumnums) + parseFloat(sumnum);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (e) { }
        }
    }
    $("#summoney" + id1).text(FormatNumber(moneyalls, num_dot_xs))
    if (!isNaN(sumnum)) {
        $("#sumnums" + id1).text(FormatNumber(sumnums, window.sysConfig.floatnumber))
    } else { $("#sumnums" + id1).text(FormatNumber(0, window.sysConfig.floatnumber)) }
}

//计算合计
function chtotalAll(id, id1, num_dot_xs, unit, ord, i) {

    var sumnums = 0;
    $("#zbmxlist [id^='num']").each(function () {
        var num = $(this);
        numb = (num.attr("zdnumvalue") || num.attr("zdnumvalue") == 0) ? num.attr("zdnumvalue") : num.val();  //zdnumvalue是已指定的数量，随机出库的时候为空
        numb = numb.replace(",", "");
        if (isNaN(numb)) {
            numb = 0;
        }
        sumnums += parseFloat(numb)
    })
    var moneyalls = 0;
    $("#zbmxlist [id^='money']").each(function () {
        var moneyall = $(this).val();
        if (isNaN(moneyall)) {
            moneyall = 0.00;
        }
        moneyalls += parseFloat(moneyall)
    })

    $("#summoney").text(FormatNumber(moneyalls, window.sysConfig.moneynumber))
    $("#sumnums").text(FormatNumber(sumnums, window.sysConfig.floatnumber))
}


function chtotal2(id, num_dot_xs) {
    var price = document.getElementById("pricetest2_" + id);
    var num = document.getElementById("num2_" + id);
    //-------------------------------------------------------------防止输入非数字出现错误数据
    numb = num.value;
    numb = numb.replace(",", "");
    pric = price.value;
    pric = pric.replace(",", "");
    if (isNaN(numb)) {
        num.value = 1;
    }
    if (isNaN(pric)) {
        price.value = 0.00;
    }
    //\\--------------------------------------------------------------
    var moneyall = document.getElementById("moneyall2_" + id);
    var money1 = Number(pric.replace(/\,/g, '')) * Number(numb.replace(/\,/g, ''));
    moneyall.value = FormatNumber(money1, num_dot_xs);
    xmlHttp.abort();
}
function chtotal3(ord, top, id, i, num_dot_xs,unit) {
    var price = document.getElementById("pricetest2_" + id);
    var num = document.getElementById("num2_" + id);
    numb = num.value;
    numb = numb.replace(",", "");
    var productAttr1 = document.getElementById("ProductAttr1_" + i);
    var productAttr2 = document.getElementById("ProductAttr2_" + i);
    var productAttr1Id = 0;
    var productAttr2Id = 0;
    if (productAttr1) { productAttr1Id = productAttr1.value; }
    if (productAttr2) { productAttr2Id = productAttr2.value; }
    pric=price.value;//bug 刚加载时 这样可以，修改了子件以后 就有问题了
    //pric = document.getElementById("pricetest2_" + id).getAttribute("old_val")
    pric = pric.replace(",", "");
    if (isNaN(numb)) {
        num.value = 1;
    }
    if (isNaN(pric)) {
        price.value = 0.00;
    }
    var price1 = pric.replace(/\,/g, '');
    price1 = FormatNumber(price1, window.sysConfig.StorePriceDotNum);
    var moneyall = document.getElementById("moneyall2_" + id);
    var money1 = Number(price1) * Number(numb.replace(/\,/g, ''));
    var num1 = Number(numb.replace(/\,/g, ''));
    //price.value = FormatNumber(pric, window.sysConfig.StorePriceDotNum);
    moneyall.value = FormatNumber(money1, window.sysConfig.moneynumber);
    price.value = FormatNumber(FormatNumber(money1, window.sysConfig.moneynumber) / Number(numb.replace(/\,/g, '')), window.sysConfig.StorePriceDotNum);
    correct(ord, top, id, num1, unit, productAttr1Id, productAttr2Id);
    xmlHttp.abort();
}

function correct(ord, top, id, num1, unit, productAttr1Id, productAttr2Id) {
    if ((ord == null) || (ord == "")) return;
    var url = "addlistadd_cz3.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit + "&id=" + escape(id) + "&num1=" + escape(num1) + "&ProductAttr1=" + escape(productAttr1Id) + "&ProductAttr2=" + escape(productAttr2Id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        correctupdate(ord, top, id);
    };
    xmlHttp.send(null);
}

function correctupdate(ord, top, id) {
	try{
		var w = "cktrpx" + id
		w = document.all[w]
		if (xmlHttp.readyState < 4) {
			w.innerHTML = "loading...";
		}
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			w.innerHTML = response;
			//BuildEvent();
			xmlHttp.abort();
		}
	}catch(e){alert(e);}
}

function callServer4(ord, top,unit) {
	unit = unit || '';
    if ((ord == null) || (ord == "")) return;
    var url = "../contract/num_click.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage4(ord, top,unit);
    };
    xmlHttp.send(null);
}
function callServer4_1(unit, ord, top, productAttr1, productAttr2) {
    if ((ord == null) || (ord == "")) return;
    var url = "../contract/num_click.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit="+unit+"&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage4_1(unit, ord, top, productAttr1, productAttr2);
    };
    xmlHttp.send(null);
}
function getParent(child, parentIndex) {  //获取指定层次级别的父对象
    for (var i = 0; i < parentIndex; i++) {
        child = child.parentElement;
    }
    return child;
}

function gettrpxfree() {
    for (var i = 0; i < 1000; i++) {
        if (document.getElementById("trpx" + i)) {
            var im = document.getElementById("trpx" + i);
            if (trim(im.innerText).length < 3) {
                return im;
            }
        }
    }
}

function updatePage4(ord, top,unit) {
    if (xmlHttp.readyState < 4) { }
    if (xmlHttp.readyState == 4) {
        var res = xmlHttp.responseText;
        var w = "trpx" + res;
        w = gettrpxfree()
        if (!w) {
            alert("已经达到系统规定的明细最大行，详情请联系管理员")
            return;
        }
        var url = "addlistadd_cz4.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit="+unit+ "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage5(w, ord, top, res, unit);
        };
        xmlHttp.send(null);
    }
}
function updatePage4_1(unit, ord, top, productAttr1, productAttr2) {
    if (xmlHttp.readyState < 4) { }
    if (xmlHttp.readyState == 4) {
        var res = xmlHttp.responseText;
        var w = window.vs;  //"trpx_" + id;
        //w = gettrpxfree()
        if (!w) {
            alert("已经达到系统规定的明细最大行，详情请联系管理员")
            return;
        }
        var url = "addlistadd_cz.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit + "&productAttr1=" + productAttr1 + "&productAttr2=" + productAttr2 +"&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage5_1(w, ord, top, res, unit, productAttr1, productAttr2);
        };
        xmlHttp.send(null);
    }
}

function updatePage5(w, ord, top, res, unit) {
    try {
        var nomc = document.getElementById("nomc");
        if (nomc) nomc.style.display = "none";
        var test3 = w;
        if (xmlHttp.readyState < 4) {
            test3.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
			try
			{
			var em = w.cloneNode(true);
			w.outerHTML = "";
			var bem = document.getElementById("beforelastRow");
			bem.parentNode.insertBefore(em,bem);
			var response = xmlHttp.responseText ;
			em.innerHTML = response;
				}
			catch (e)
			{
				alert(e.message)
			}
            var url = "addlistadd_cz2.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit+ "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
            xmlHttp.open("GET", url, false);
            xmlHttp.onreadystatechange = function () {
                updatePage6(em, res);
            };
            xmlHttp.send(null);
        }
    } catch (e) { }
}

function updatePage5_1(w, ord, top, res, unit, productAttr1, productAttr2) {
    try {
        var nomc = document.getElementById("nomc");
        if (nomc) nomc.style.display = "none";
        var test3 = w;
        if (xmlHttp.readyState < 4) {
            test3.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            test3.innerHTML = response;
            var url = "addlistadd_cz2.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit + "&productAttr1=" + productAttr1 + "&productAttr2=" + productAttr2 +"&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
            xmlHttp.open("GET", url, false);
            xmlHttp.onreadystatechange = function () {
                updatePage6(w, res);
            };
            xmlHttp.send(null);
        }
    } catch (e) { }
}


function getzjtrpxfree() {
    for (var i = 0; i < 1000; i++) {
        if (document.getElementById("zjtrpx" + i)) {
            var im = document.getElementById("zjtrpx" + i);
            if (trim(im.innerText).length < 10) {
                return im;
            }
        }
    }
}

function updatePage6(w, res) {
    var test6 = w;
    var w = "zjtrpx" + res;
    w = getzjtrpxfree()
    if (!w) {
        alert("已经达到系统规定的明细最大行，详情请联系管理员")
        return;
    }
    if (xmlHttp.readyState < 4) { }
    if (xmlHttp.readyState == 4) {
        //$("#tpx9").remove()
        var response = xmlHttp.responseText;
		w.innerHTML = response;
        //click_pl();
		//BuildEvent();
        //chtotalAll();
        xmlHttp.abort();
    }
}

function ajaxSubmit(sort1) {
    //获取用户输入
    var B = document.forms[0].B.value;
    var C = document.forms[0].C.value;
    var top = document.forms[0].top.value;
    var url = "../contract/search_cp.asp?jybom=1&B=" + escape(B) + "&C=" + escape(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_cp();
    };
    xmlHttp.send(null);
}
function updatePage_cp() {
    if (xmlHttp.readyState < 4) {
        cp_search.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        cp_search.innerHTML = response;
        xmlHttp.abort();
    }
}

function click_pl() {
    var url = "click_pl.asp?timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updateclick_pl();
    };
    xmlHttp.send(null);
}

function updateclick_pl() {
    if (xmlHttp.readyState < 4) {
        all_num.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        all_num.innerHTML = response;
        xmlHttp.abort();
    }
}

function check_kh(ord, unit, unit2, ckjb, ck, id, num1, kcid) {
	//拆分后触发该函数
    var url = "../store/ku_unit_cf.asp?ord=" + escape(ord) + "&unit=" + escape(unit) + "&unit2=" + escape(unit2) + "&ckjb=" + escape(ckjb) + "&ck=" + escape(ck) + "&id=" + escape(id) + "&num1=" + escape(num1) + "&kcid=" + escape(kcid) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage2(id);
    };  
    xmlHttp.send(null);
}
function updatePage2(w) {
    var test7 = $("#ck2xz_" + w)
    if (xmlHttp.readyState < 4) {
        //test7.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        if (response.indexOf("error:") > 0) {
            alert(response.split("<noscript></noscript>")[1].split("error:")[1]);
            return;
        }
        test7.html(response);
        //xmlHttp.abort();
		UpdatePrice(true);
    }
}

function check_ckxz(i) {
    var ck = document.getElementById("ck2_" + i).value;
    if (ck != "") return true;
    alert("请先选择仓库！")
}

function check_ckxz2(i) {
    var ck = document.getElementById("ck" + i).value;
    if (ck != "") return true;
    alert("请先选择仓库！")
}

function check_sp() {
    var ck = document.getElementsByName("complete");
    for (var i = 0; i < ck.length; i++) {
        if (ck[i].checked)
            return true;
    }
    alert("没有选中！");
    return false;
}


function ckxz5(ord, i, id, w, sort1) {
    var unit1 = document.getElementById("unit2_" + i).value;
    var num1 = document.getElementById("num2_" + id).value;
    var price1 = document.getElementById("pricetest2_" + id).value;
    var money1 = document.getElementById("moneyall2_" + id).value;
	var ck = document.getElementById("ck2_" + i).value;
    //var ph = document.getElementById("ph2_" + i).value;
    //var xlh = document.getElementById("xlh2_" + i).value;
    //var datesc = document.getElementById("daysdatesc" + i + "Pos").value;
    //var dateyx = document.getElementById("daysdateyx" + i + "Pos").value;
    var bz = document.getElementById("bz" + i).value;
    var js = document.getElementById("js2_" + i).value;
    var intro ="";// document.getElementById("intro2_" + i).value;
    var productAttr1 = document.getElementById("ProductAttr1_" + i) ? document.getElementById("ProductAttr1_" + i).value:"";
    var productAttr2 = document.getElementById("ProductAttr2_" + i) ? document.getElementById("ProductAttr2_" + i).value:"";

    var w2 = w;
    w2 = document.all[w2]
    var url = "cu_ck2_cz3.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&price1=" + escape(price1) + "&money1=" + escape(money1) + "&sort1=" + escape(sort1) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&ck=" + escape(ck) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&ProductAttr1=" + productAttr1 + "&ProductAttr2=" + productAttr2+ "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_ckxz2(w2);
    };
    xmlHttp.send(null);
}

function ckxz(ord, i, id, id1, w, sort1, num_dot_xs) {
    var unit1 = document.getElementById("unit" + i).value;
    var num1 = document.getElementById("num" + id).value;
    var price1 = document.getElementById("pricetest" + id).value;
    var money1 = document.getElementById("moneyall" + id).value;
    var ck = document.getElementById("ck" + i).value;
    var bz = document.getElementById("bz2_" + i).value;
    var js = document.getElementById("js" + i).value;
    var intro = document.getElementById("intro" + i);
    intro = intro ? intro.value : "";
    var w2 = w;
    w2 = document.all[w2]
    var url = "cu_ck2_zz.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&price1=" + escape(price1) + "&money1=" + escape(money1) + "&sort1=" + escape(sort1) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&id1=" + escape(id1) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&ck=" + escape(ck) + "&bz=" + escape(bz) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_ckxz(w2, id, id1, num_dot_xs, money1);
    };
    xmlHttp.send(null);
}

function ckxz6(ord, i, id, w, sort1) {
    var unit1 = document.getElementById("u_nametest" + id).value;
    var num1 = document.getElementById("num" + id).value;
    var price1 = document.getElementById("pricetest" + id).value;
    var money1 = document.getElementById("moneyall" + id).value;
	var ck = document.getElementById("ck" + i).value;
    //var ph = document.getElementById("ph2_" + i).value;
    //var xlh = document.getElementById("xlh2_" + i).value;
    //var datesc = document.getElementById("daysdatesc" + i + "Pos").value;
    //var dateyx = document.getElementById("daysdateyx" + i + "Pos").value;
    var bz = "";//document.getElementById("bz" + i).value;
    var js = "";//document.getElementById("js2_" + i).value;
    var intro = "";//document.getElementById("intro2_" + i).value;
    var w2 = w;

    w2 = document.all[w2]
	var url = "addlistadd_kd2.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&price1=" + escape(price1) + "&money1=" + escape(money1) + "&sort1=" + escape(sort1) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&ck=" + escape(ck) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
//    var url = "addlistadd_kd2.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&price1=" + escape(price1) + "&money1=" + escape(money1) + "&sort1=" + escape(sort1) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&ck=" + escape(ck) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        addlistadd_kd_ckxz6(w2);
    };
    xmlHttp.send(null);
}


function addlistadd_kd_ckxz6(w2) {
    var test6 = w2
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test6.innerHTML = response;
        var mall = document.getElementById("details").document.getElementsByTagName("input");
        var moneyall = 0;
        for (var i = 0; i < mall.length; i++) {
            if ((mall[i].name.indexOf("moneyall_") != -1) && (mall[i].name != "moneyall_0")) {
                moneyall = moneyall + parseFloat(mall[i].value.replace(/\,\g/, ""));
            }
        }
        document.getElementById("money_zs").value = moneyall;
        document.getElementById("money_hk").value = 0;
        xmlHttp.abort();
    }
}

function updatePage_ckxz(w2, id, id1, num_dot_xs, money_old) {
    var test6 = w2
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test6.innerHTML = response;
        var money1 = document.getElementById("moneyall" + id);
        var price2 = document.getElementById("pricetest2_" + id1);
        var num2 = document.getElementById("num2_" + id1).value;
        var moneyall2 = document.getElementById("moneyall2_" + id1);
        Mon2 = moneyall2.value;
        Mon2 = Mon2.replace(",", "");
        money3 = Number(Mon2);
        money_old = money_old.replace(",", "");
        money3 = Number(money3) - Number(money_old);
        Mon1 = money1.value;
        Mon1 = Mon1.replace(",", "");
        money3 = Number(money3) + Number(Mon1)
        moneyall2.value = FormatNumber(money3, num_dot_xs);
        price2.value = FormatNumber(money3 / num2, window.sysConfig.StorePriceDotNum);
        xmlHttp.abort();
    }
}

function ckxz2(ord, i, id, w, sort1) {
    var unit1 = document.getElementById("unit2_" + i).value;
    var num1 = document.getElementById("num2_" + id).value;
    var price1 = document.getElementById("pricetest2_" + id).value;
    var money1 = document.getElementById("moneyall2_" + id).value;
    var ph = document.getElementById("ph2_" + i).value;
    var xlh = document.getElementById("xlh2_" + i).value;
    var datesc = document.getElementById("daysdatesc" + i + "Pos").value;
    var dateyx = document.getElementById("daysdateyx" + i + "Pos").value;
    var bz = document.getElementById("bz" + i).value;
    var js = document.getElementById("js2_" + i).value;
    var intro = document.getElementById("intro2_" + i).value;
    var w2 = w;
    w2 = document.all[w2]
    var url = "cu_ck2_cz2.asp?ord=" + escape(ord) + "&num1=" + escape(num1) + "&price1=" + escape(price1) + "&money1=" + escape(money1) + "&sort1=" + escape(sort1) + "&intro1=" + escape(intro) + "&id=" + escape(id) + "&i=" + escape(i) + "&unit=" + escape(unit1) + "&ph=" + escape(ph) + "&xlh=" + escape(xlh) + "&datesc=" + escape(datesc) + "&dateyx=" + escape(dateyx) + "&bz=" + escape(bz) + "&js=" + escape(js) + "&intro=" + escape(intro) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_ckxz2(w2);
    };
    xmlHttp.send(null);
}

function updatePage_ckxz2(w2) {
    var test6 = w2
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test6.innerHTML = response;
        xmlHttp.abort();
    }
}

function zdkc(id,isdelzz) {
    var w2 = "zdkc" + id;
    w2 = document.all[w2]
    var url = "../store/cu_kuin2.asp?id=" + escape(id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);

    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_zdkc(w2,isdelzz);
    };
    xmlHttp.send(null);
}

function zdkckd(id,isdelzz) {
    var w2 = "zdkc" + id;
    w2 = document.all[w2]
    var url = "../store/cu_kuin2.asp?id=" + escape(id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);

    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_zdkc_kd(w2,isdelzz);
    };
    xmlHttp.send(null);
}

function updatePage_zdkc_kd(w2,isdelzz) {
    var test6 = w2
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
		if(response.indexOf('0.0</b>')!=-1)response='';
		test6.innerHTML = response;
		if(isdelzz!=true)  //如果不是删除指定库存调用，则给数量输入框加已指定数量属性
		{
			var numid = test6.id.replace("zdkc","num")
			document.getElementsByName(numid)[0].setAttribute("zdnumvalue",test6.innerText.replace("已指定：","").replace(/,/g,""))
		}
		UpdatePrice();
    }
}

function updatePage_zdkc(w2,isdelzz) {
    var test6 = w2;
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
		if(response.indexOf('0.0</b>')!=-1)response='';
		test6.innerHTML = response;
		if(isdelzz!=true)  //如果不是删除指定库存调用，则给数量输入框加已指定数量属性
		{
			var numid = test6.id.replace("zdkc","num1_")
			document.getElementsByName(numid)[0].setAttribute("zdnumvalue",test6.innerText.replace("已指定：","").replace(/,/g,""))
		}
		UpdatePrice();
    }
}

function del_zd(id) {
    var url = "../store/del_zd.asp?id=" + escape(id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
    };
    xmlHttp.send(null);
    document.getElementsByName("num1_" + id)[0].removeAttribute("zdnumvalue");
    $("#zdkc" + id).find("b").html("");
	//zdkc(id,true)
}

function ask() {
    document.all.date.action = "savelistadd13.asp";
}
/*--------------------------以下是修改单价策略代码--------------------------------*/

//绑定事件
function BuildEvent()
{
	var div = document.getElementById("main_lists");
	var sbox = div.getElementsByTagName("select");
	try{
	document.getElementById("ckall_2").onchange = function(event) {
		ck(2,true,event);
		UpdatePrice();
	}
	}catch(e){}
	for(var i = 0; i < sbox.length; i++)
	{
		var s = sbox[i];
		if(s.name.indexOf("unit")==0)
		{ 
			var row = s.parentNode.parentNode;
			//单位
			var currid = s.name.replace("unit_","");
			var oldevent = s.onchange;
			s.onchange = function(){ 
				if(oldevent) { oldevent(); };
				UpdatePrice();
			} 
			//仓库
			s = document.getElementsByName("ck_" + currid)[0]
			//alert(document.getElementsByName("ck_" + currid)[0].innerHTML);
			s.onchange = UpdatePrice;
			//单价

			if(s.value.length==0){
				s = GetPriceElement(row)
				if (isNaN(s.value))
				{
					s.value=0
				}
			}
			else{
				s = GetPriceElement(row)
			}
			//指定方式
			//s = document.getElementsByName("way1_" + currid)[0]
			//if(s.value==1) { s.onmouseup = UpdatePrice; } 
			//创建存放数据的容器
			var ndatabox = document.getElementsByName("numdata1_" + currid);
			if(ndatabox.length==0)
			{
				ndatabox = document.createElement("span");
				ndatabox.innerHTML = "<input name='numdata1_" + currid + "' type='hidden' value='' onclick='alert(this.outerHTML)'>"
				row.cells[0].appendChild(ndatabox);
			}
		}
	}
	
	var tb = div.getElementsByTagName("table")
	for(i = 0 ; i < tb.length ; i++)
	{
		if(tb[i].rows[0].cells.length>5){tb[i].style.tableLayout = "fixed";}
	}

	div.onkeyup = function()
	{
		if(window.event.srcElement.name.indexOf("num1_")==0) {
			UpdatePrice();
		}
	}
}

//获取price字段
function GetPriceElement(row)
{
	var boxs = row.getElementsByTagName("input")
	for (var i = 0; i < boxs.length ; i ++ )
	{
		if(boxs[i].name.indexOf("price1")==0) {
						//alert("'"+boxs[i].name+"/"+boxs[i].value+"'");
			return boxs[i];
		}
	}
	return null;
}

function UpdatePrice(updatKuInfo) {  //updatKuInfo表示是否需要更新库存
	var updatKuInfo = true
    var sendData = ""; //需要提交的数据   mpxmID, 单位, 数量, 仓库ID, 指定模式    指定数据从mpxm中查询
    var div = document.getElementById("main_lists");
	try{//意外情况，删除报错
	var sbox = div.getElementsByTagName("select");
	}catch(e){return false;}
	for(var i = 0; i < sbox.length; i++)
	{
		var s = sbox[i];
		if(s.id.indexOf("unit")==0)
		{
			var row = s.parentNode.parentNode.parentNode;
			var currid = s.name.replace("unit_","");
			var num = document.getElementsByName("num1_" + currid)[0].value;
			var way1;
			if(document.getElementsByName("way1_" + currid)[0]){
				if(document.getElementsByName("way1_" + currid)[0].checked){
					way1=0;
				}else{
					way1=1;
				}
			}else{
				way1=0;
			}
			if(document.getElementsByName("ck_" + currid)[0].value!="" && num!="" && num!=0)
			{
				sendData = sendData + "" + currid + "##" + document.getElementsByName("unit_" + currid)[0].value + "##" + num + "##" + document.getElementsByName("ck_" + currid)[0].value + "##" + way1 + "||";
			}
		}
	}
	if(sendData.length>0)
	{
		var t = new Date();
		sendData = "__msgId=handleMakePrice&top=" + window.billorderid + "&updatKuInfo=" + (updatKuInfo ? "1" : "0" ) + "&data=" + sendData + "&t=" + t.getTime();
		xmlHttp.open("post", "get_zz_priceinfo.asp", true);
		xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xmlHttp.setRequestHeader("Content-Length", sendData.length + "");
        xmlHttp.onreadystatechange = function()
		{
			if (xmlHttp.readyState == 4) {
				BuildPriceData(xmlHttp.responseText);
				xmlHttp.abort();
			}
		}
        xmlHttp.send(sendData);
	} 
}

function BuildPriceData(data)
{
	try{
		var rows = data.split("\2");
		for (var i = 0 ; i < 1 ; i ++ )
		{
			if(rows[i].length > 0) 
			{
				var item = rows[i].split("\1");
				var currid = item[0];
				//alert(document.getElementsById("trpx_"+currid).innerHTML);
				var s = document.getElementsByName("unit_" + currid)[0];
				var row = s.parentNode.parentNode.parentNode;
				var numbox = document.getElementsByName("num1_" + currid)[0];
				//var trueNum=parseInt(item[3].split(":")[1].replace("|"));
				//trueNum=item[1]-trueNum;
				//if(trueNum!=0){
				//numbox.value=trueNum;
				//numbox.onblur();}
				//GetPriceElement(row).value = item[2]; //单价
				numbox.setAttribute("max",item[1])
				//numbox.setAttribute("msg","库存不足，当前可用库存为" + item[1]);
				var pricebox=document.getElementsByName("price1_" + currid)[0];
				pricebox.value = item[2].replace(/,/g, "");
				try{
				    document.getElementsByName("moneyall_" + currid)[0].value = FormatNumber(numbox.value * pricebox.value, window.sysConfig.moneynumber);
				    pricebox.value = FormatNumber(FormatNumber(numbox.value * pricebox.value, window.sysConfig.StorePriceDotNum) / numbox.value, window.sysConfig.StorePriceDotNum);
				}catch(e){}
				document.getElementsByName("numdata1_" + currid)[0].value = item[3]
				if(item.length==5){
					var ckbox = document.getElementsByName("ck_" + currid)[0];
					ckbox.parentNode.parentNode.parentNode.parentNode.parentNode.nextSibling.innerHTML = item[4]
					//ckbox.parentNode.parentNode.nextSibling.innerHTML = item[4]
				}
				s = document.getElementsByName("way1_" + currid)[1];
			}
		}
		if(data.length> 10 && data.indexOf("\2")==-1)
		{
			//alert(data);
		}
	}
	catch(e)
	{
		//alert(data)
	}
}

function getcurrck(currid){
	return document.getElementsByName("ck_" + currid)[0].value;
}
function getcurrunit(currid){
	return document.getElementsByName("unit_" + currid)[0].value;
}
function getcurrnum1(currid){
	return document.getElementsByName("num1_" + currid)[0].value;
}

function checkFormSubmit(){
    var ret = true;
    jQuery("input[name^='xlh_']").each(function(){
        var id = jQuery(this).attr("name").replace("xlh_","");        
        var xlh = jQuery.trim(jQuery(this).val());
        var num1 = Number(jQuery("#num"+id).val());
        var xlhMin = jQuery(this).attr("min")
        if(xlh!=""){
            var arr_xlh = xlh.split("\1");
            var inx = jQuery("#inx_"+id).html();
            if(xlhMin == "1"){
                if(num1 != arr_xlh.length){                    
                    ret = false;
                    alert("子件清单中第"+ inx +"行的序列号个数["+ arr_xlh.length +"]与数量["+ num1 +"]不一致，请重新录入");
                    return;
                }
            }else{
                if(num1 < arr_xlh.length){
                    ret = false;
                    alert("子件清单中第"+ inx +"行的序列号个数["+ arr_xlh.length +"]大于数量["+ num1 +"]，请重新录入");
                    return;
                }
            }
        }
    });
    return ret;
}


//简易拆装，子件选择仓库后，消除请选择仓库提示
function xiaoChuTiShi(src) {
    var spanTiShi = src.parentNode.childNodes[2];
    if (spanTiShi) spanTiShi.style.display = "none";
}

//拆分页面跳转
function Kuinfoopenurltocf(productid, moreunit, Ismode, unit, id, ck, ck2,numid) {
    var num1 = document.getElementById("num2_" + id).value;
    var attr1 = 0;
    var attr2 = 0;
    if (document.getElementsByName("ProductAttr1_" + id).length > 0) {
        attr1 = document.getElementsByName("ProductAttr1_" + id)[0].value;
        attr2 = document.getElementsByName("ProductAttr2_" + id)[0].value;
    }
    window.open('../../sysn/view/store/kuout/KuAppointSplit.ashx?productid=' + productid + '&unit=' + unit + '&ck=' + ck + '&ck2=' + ck2 + '&attr1=' + attr1 + '&attr2=' + attr2 + '&numid=' + numid + '&moreunit=' + moreunit + '&Ismode=3&id=' + id + '&cfnum1=' + num1 + '', 'newwin23', 'width=' + 800 + ',height=' + 400 + ',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');

}

//拆分页面跳转
function openurltocf(productid, unit, ck, attr1, attr2, moreunit, Ismode, id, i) {
    var num1 = document.getElementById("num2_" + id).value;
    if (document.getElementsByName("ProductAttr1_" + id).length > 0) {
        attr1 = document.getElementsByName("ProductAttr1_" + id)[0].value;
        attr2 = document.getElementsByName("ProductAttr2_" + id)[0].value;
    }
    window.open('../../sysn/view/store/kuout/KuAppointSplit.ashx?productid=' + productid + '&unit=' + unit + '&ck=' + ck + '&attr1=' + attr1 + '&attr2=' + attr2 + '&moreunit=' + moreunit + '&Ismode=3&id=' + id + '&cfnum1=' + num1 + '', 'newwin23', 'width=' + 800 + ',height=' + 400 + ',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');

}