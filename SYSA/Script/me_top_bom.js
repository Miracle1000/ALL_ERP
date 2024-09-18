
// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);
// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0;
 while (elt!=null) {
  iPos += elt["offset" + which];
  elt = elt.offsetParent;
 }
 return iPos;
}
function ask() { 
document.all.date.action = "savelistadd13.asp"; 
} 

    function callServer(nameitr, ord, i, id) {
        var u_name = document.getElementById("u_name" + nameitr).value;
        var num1 = document.getElementById("num" + id).value;
        var intro1 = document.getElementById("intro_" + id).value;
        var productAttr1 = document.getElementById("ProductAttr1_" + id) ? document.getElementById("ProductAttr1_" + id).value : "";
        var productAttr2 = document.getElementById("ProductAttr2_" + id) ? document.getElementById("ProductAttr2_" + id).value : "";
        var w = document.all[nameitr];
        var w2 = "trpx" + i;
        w2 = document.all[w2];
        if ((u_name == null) || (u_name == "")) return;
        var url = "cu_add.asp?unit=" + escape(u_name) + "&ord=" + escape(ord) + "&num1=" + escape(num1) + "&intro1=" + escape(intro1) + "&productAttr1=" + escape(productAttr1) + "&productAttr2=" + escape(productAttr2) + "&id=" + escape(id) + "&i=" + escape(i) + "&nameitr=" + escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
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

    function callServer2(nameitr, ord, company, id) {
        var u_name = document.getElementById("u_name" + nameitr).value;
        var w = "tt" + nameitr;
        w = document.all[w];
        var w2 = "t" + nameitr;
        w2 = document.all[w2];
        var w3 = document.all[nameitr];
        if ((u_name == null) || (u_name == "")) return;
        var url = "cu2.asp?unit=" + escape(u_name) + "&ord=" + escape(ord) + "&id=" + escape(id) + "&company1=" + escape(company) + "&nameitr=" + escape(nameitr);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage2(w, w2);
        };
        document.getElementById("tt" + nameitr).style.display = '';
        xmlHttp.send(null);
    }

    function updatePage2(namei, w2) {
        var test7 = namei
        var test6 = w2
        if (xmlHttp.readyState < 4) {
            test7.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            test6.innerHTML = "";
            test7.innerHTML = response;
        }
    }

    function callServer3(nameitr, ord, company, id) {
        var u_name = document.getElementById("u_name" + nameitr).value;
        var w = document.all[nameitr];
        var w2 = "tt" + nameitr;
        w2 = document.all[w2];
        if ((u_name == null) || (u_name == "")) return;
        var url = "cu3.asp?unit=" + escape(u_name) + "&ord=" + escape(ord) + "&id=" + escape(id) + "&gs=" + escape(company) + "&nameitr=" + escape(nameitr);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage3(w, nameitr, w2);
        };
        xmlHttp.send(null);
    }

    function updatePage3(namei, id, w2) {
        var test7 = namei
        var test6 = w2
        if (xmlHttp.readyState < 4) {
            test7.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            test6.innerHTML = "";
            test7.innerHTML = response;
            var pricejctest = document.getElementById("pricejc" + id);
            var pricetest = document.getElementById("price" + id);
            pricetest.value = pricejctest.value;
        }
    }

    function callServer4(ord, top, unit) {
		unit = unit || '';
        if ((ord == null) || (ord == "")) return;
        var url = "../contract/num_click.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage4(ord, top, unit);
        };
        xmlHttp.send(null);
    }

    function updatePage4(ord, top, unit) {
        if (xmlHttp.readyState < 4) {
        }
        if (xmlHttp.readyState == 4) {
            var res = xmlHttp.responseText;
            var w = "trpx" + res;
            w = document.all[w]
            var url = "addlistbom.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit;
            xmlHttp.open("GET", url, false);
            xmlHttp.onreadystatechange = function () {
                updatePage5(w);
            };
            xmlHttp.send(null);
        }
    }

    function updatePage5(w) {
        var test3 = w;
        if (xmlHttp.readyState < 4) {
            test3.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            test3.innerHTML = response;
            //var tb = test3.children[0];
            //tb.rows[0].cells[4].style.display = "none";
            //tb.rows[0].cells[6].style.display = "none";
        }
    }

    function del(str, id) {
        var w = str;
        var url = "../caigou/del_cp.asp?id=" + escape(id) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            updatePage_del(w);
        };
        xmlHttp.send(null);
    }
    function updatePage_del(str) {
        document.getElementById(str).style.display = "none";
    }

    function ajaxSubmit(sort1) {
        //获取用户输入
        var B = document.forms[0].B.value;
        var C = document.forms[0].C.value;
        var top = document.forms[0].top.value;
        var url = "../caigou/search_cp.asp?cstore=1&B=" + escape(B) + "&C=" + escape(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
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
        }
    }

    function NoSubmit(ev) {
        if (ev.keyCode == 13) {
            return false;
        }
        return true;
    }

    function chtotal(id, num_dot_xs) {
        var price = document.getElementById("pricetest" + id);
        var num = document.getElementById("num" + id);
        var moneyall = document.getElementById("moneyall" + id);
        var money1 = price.value.replace(/\,/g, '') * num.value.replace(/\,/g, '');
        moneyall.value = FormatNumber(money1, num_dot_xs);
    }

    function cptj(ord, top) {
        setTimeout("callServer4('" + ord + "','" + top + "')", 1000);
        xmlHttp.abort();
    }
