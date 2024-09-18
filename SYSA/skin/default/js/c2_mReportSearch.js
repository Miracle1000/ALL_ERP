function dorptsearch(id) {
    var obj = new Array();
    var tb = document.getElementById("rptpanel_" + id)
    if (tb) {
        var row = null;
        for (var i = 0; i < tb.rows.length; i++) {
            row = tb.rows[i];
            var cell = row.cells[0];
            var cell2 = row.cells[1];
            var utype = cell.getAttribute("uitype");
            var uname = cell.getAttribute("dbname");
            var uname2 = cell.getAttribute("dbname2");
            switch (utype) {
                case "checks":
                    var d = new Array();
                    var boxs = cell2.getElementsByTagName("input")
                    for (var ii = 0; ii < boxs.length; ii++) {
                        if (boxs[ii].checked) {
                            d[d.length] = boxs[ii].getAttribute("value");
                        }
                    }
                    obj[obj.length] = [uname, "checks", d.join(",")];
                    break;
                case "gate":
                    var w1 = new Array();
                    var w2 = new Array();
                    var w3 = new Array();
                    var boxs = cell2.getElementsByTagName("input")
                    for (var ii = 0; ii < boxs.length; ii++) {
                        if (boxs[ii].checked) {
                            switch (boxs[ii].name.toLowerCase()) {
                                case "w1":
                                    w1[w1.length] = boxs[ii].getAttribute("value"); break;
                                case "w2":
                                    w2[w2.length] = boxs[ii].getAttribute("value"); break;
                                case "w3":
                                    w3[w3.length] = boxs[ii].getAttribute("value"); break;
                                default:
                            }
                        }
                    }
                    obj[obj.length] = [uname, "gate", w1.join(",") + "|" + w2.join(",") + "|" + w3.join(",")];
                    break;
                case "areas":
                    var d = new Array();
                    var boxs = cell2.getElementsByTagName("input")
                    for (var ii = 0; ii < boxs.length; ii++) {
                        if (boxs[ii].checked) {
                            d[d.length] = boxs[ii].getAttribute("value");
                        }
                    }
                    obj[obj.length] = [uname, "areas", d.join(",")];
                    break;
                case "groups":
                    var sbox = cell.children[0];
                    var v = sbox.value;
                    for (var ii = 0; ii < sbox.length; ii++) {
                        if (sbox.options[ii].value != v) {
                            obj[obj.length] = [sbox.options[ii].value, "text", ""];
                        }
                        else {
                            obj[obj.length] = [sbox.options[ii].value, "text", cell2.children[0].value];
                        }
                    }
                    break;
                case "dates":
                    obj[obj.length] = [cell2.children[0].getAttribute("dbname"), "date", cell2.children[0].value];
                    obj[obj.length] = [cell2.children[1].getAttribute("dbname"), "date", cell2.children[1].value];
                    break;
                case "productcls":
                    var d = new Array();
                    var boxs = cell2.getElementsByTagName("input")
                    for (var ii = 0; ii < boxs.length; ii++) {
                        if (boxs[ii].checked) {
                            d[d.length] = boxs[ii].getAttribute("value");
                        }
                    }
                    obj[obj.length] = [uname, "productcls", d.join(",")];
                    break;
                case "storecls":
					if(document.getElementById("cktreeack").checked==false)
					{ 
						var s = new Array();
						var s1 = new Array();
						var boxs = cell2.getElementsByTagName("input");
						for (var j = 0; j < boxs.length ; j++)
						{
						    var bx = boxs[j];
							if(bx.checked)
							{	
								var divid = bx.id.replace("_cb","");
								var div = document.getElementById(divid);
								var a =  div.getElementsByTagName("a")[0];
								if(a){
									if (a.getAttribute("canselect")!="0")
									{
										s[s.length] = a.getAttribute("value");
									}
									else{
										s1[s1.length] = a.getAttribute("value");
									}
								}
							}
						}
						obj[obj.length] = [uname, "storecls", s1.join(",")+"|"+s.join(",")];
					}
					else
					{
						obj[obj.length] = [uname, "storecls", ""];
					}
                   
                    break;
                case "telcls":
                    var v = cell2.children[0].value.split(",");
                    obj[obj.length] = [uname, "telcls", v[0]];
                    obj[obj.length] = [uname2, "telcls", v[1]];
                    break;
                case "telcls2":
                    var d1 = new Array();
                    var d2 = new Array();
                    var boxs = cell2.getElementsByTagName("input")
                    for (var ii = 0; ii < boxs.length; ii++) {
                        if (boxs[ii].checked) {
                            if (boxs[ii].name == "E") {
                                d1[d1.length] = boxs[ii].getAttribute("value");
                            }
                            if (boxs[ii].name == "F") {
                                d2[d2.length] = boxs[ii].getAttribute("value");
                            }
                        }
                    }
                    obj[obj.length] = [uname, "telcls", d1.join(",")];
                    obj[obj.length] = [uname2, "telcls", d2.join(",")];
                    break;
                case "text":
                    obj[obj.length] = [uname, "text", cell2.children[0].value];
                    break;
            }
        }
        if (obj.length > 0) {
            var d = new Array();
            for (var i = 0; i < obj.length; i++) {
                d[d.length] = obj[i].join("\1");
            }
            //根据参数设置刷新listview
            var lvw = new Listview("advlisttable");
            lvw.beginCallBack("doSearch");
            lvw.addParam("key", document.getElementById("keyname").value);
            lvw.addParam("eSearch", d.join("\2"));
            lvw.exec();
        }
    }
}


/*-------------------------------*/
/*首页报表检索 仓库选择js*/
function checkAll2(str) {
    var a = document.getElementById("u" + str).getElementsByTagName("input");
    var b = document.getElementById("e" + str);
    for (var i = 0; i < a.length; i++) {
        a[i].checked = b.checked;
    }
}

function fixChk2(str) {
    var a = document.getElementById("u1").getElementsByTagName("input");
    var b = document.getElementById("e1");
    for (var i = 0; i < a.length; i++) {
        if (a[i].checked == false) {
            b.checked = false;
            return;
        }
    }
    b.checked = true;
}

function shDiv(divid, pdivid) {
    document.getElementById(pdivid).className = document.getElementById(pdivid).className == "menu3" ? "menu4" : "menu3"
    document.getElementById(divid).style.display = document.getElementById(divid).style.display == 'none' ? 'block' : 'none';
}

function selectCKS(obj) {
    var ckobj = document.getElementById("ck1");
    RemoveAll(ckobj);
    var cksvalue = obj.value;
    for (var i = 0; i < ListCK.length; i++) {
        if (ListCK[i][2] == cksvalue) OptionAdd(ckobj, ListCK[i][1], ListCK[i][0]);
    }
    if (obj.value == "") OptionAdd(ckobj, "选择仓库", "");
}

function RemoveAll(obj) { while (obj.options[0]) { obj.options.remove(0); } }
function OptionAdd(obj, skey, svalue) { obj.options.add(new Option(skey, svalue)); }

function checkMe(obj) {
    var ckdiv = document.getElementById("scks");
    var dvpid = "ckid_" + obj.value;
    var dvobj = ckdiv.getElementsByTagName("DIV");
    for (var i = 0; i < dvobj.length; i++) {
        if (dvobj[i].pid == dvpid) {
            var tgobj = dvobj[i].getElementsByTagName("INPUT");
            for (var j = 0; j < tgobj.length; j++) {
                tgobj[j].checked = obj.checked;
            }
            break;
        }
    }
    event.cancelBubble = true;
    return false;
}

function checkALL(obj) {
    var dvobj = document.getElementById("scks");
    var chkobj = dvobj.getElementsByTagName("INPUT");
    for (var i = 0; i < chkobj.length; i++) {
        chkobj[i].checked = obj.checked;
    }
}

//显示人员的部门小组信息
function showGateInfo(gateid, nm) {
    var y = window.event.clientY;
    y = y + document.documentElement.scrollTop;
    var dv = app.createWindow("id_gtsch_dlg", nm, "", window.event.clientX + 10, y - 24, "360", "180", 2, 0, "");
    ajax.regEvent("getGateInfo","main.asp");
    ajax.addParam("ord", gateid);
    dv.innerHTML = ajax.send();
}
//获取报表的id号，从而去做无刷新
function getcurrCardItemId(obj) {
    var r;
    var i = 0;
    while (obj.parentNode) {
        i++;
        obj = obj.parentNode;
        if (obj.className == "listview") {
            r = obj.id;
            break;
        }
    }
    //var r = obj.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.id;
    return r.replace("lvw_", "");
}
//显示供应商与产品价格信息
function showSupplierList(ProductId) {
    var y = window.event.clientY;
    var x = window.event.clientX;
    x = x + document.documentElement.scrollLeft;
    y = y + document.documentElement.scrollTop;
    var dv = app.createWindow("id_supplierlist_dlg", "供应商产品价格详情", "", x - 545, y - 15, "540", "290", 2, 0, "");
    ajax.regEvent("GetSupplierPriceList", "main.asp?sord=" + ProductId);
    ajax.addParam("pid", ProductId);
    ajax.send(function (r) {
        dv.innerHTML = r;
    });
}
//鼠标移动弹出框离开
function out(){
 app.closeWindow("id_gtsch_dlg")
}

function __on_tvw_checkBoxClick(box)
{
	if(box.checked==false) 
	{
		document.getElementById("cktreeack").checked = false;
	}
}