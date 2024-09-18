
jQuery(function(){
	productListResize();
	jQuery(window).resize(function(){
			productListResize();
	});
});
function productListResize(){
	jQuery('#productlist').css({'width':0});
	jQuery('#productlist').css({'width':jQuery('#productlist').parent().width()-2,'height':getProductListHeight()});
}
function isSpan(dom,h) {
    if ($(dom).is("span")) {
        var children = $(dom).children();
        var childLen = children.length;
        if (!childLen) { return; }
        if (childLen == 1) { if (children.eq(0).is("noscript")) { return; } }
        for (var i = 0; i < childLen; i++) {
            var cnode=children[i];
            h = isSpan(cnode, h);
        }
    } else {
        h += $(dom).height();
    }
    return h;
}

function getProductListHeight(){
	var h = 20;
	jQuery('#productlist').children().each(function(){
		var v = $(this).html().length;
		var v2 = 0;
		if(v > 0){
		   h= isSpan(this, h)
		}
	});
	return h;
}
// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}
function ask() {
document.all.date.action = "savelistadd13.asp";
}

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

