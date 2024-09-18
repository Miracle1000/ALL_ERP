function codec(div, tindex){
	var id = div.id;
	for (var i = 7; i >= 0 ; i-- )
	{
		if(id!="ct" + i) {
			var itemdiv = $ID("ct" + i + "_" + tindex);
			if(itemdiv)itemdiv.className = itemdiv.className.replace(" sel","");
		}
	}
	if(div.className.indexOf("sel")==-1) {
		div.className = div.className + " sel";
	}
	var codes = $ID("code" + tindex).children;
	for(var i=0; i<codes.length; i++) {
		var cs = codes[i];
		cs.style.display = (cs.id.toLowerCase() == ("code" + tindex + "_" + div.innerText.toLowerCase()) ? "block" : "none");
	}
}

function expcode(box) {
	var div = box.parentNode.parentNode;
	if (box.src.indexOf("11.gif")>0)
	{
		box.src = box.src.replace("11.gif","12.gif");
		div.className = "";
	}
	else{
		box.src = box.src.replace("12.gif","11.gif");
		div.className = "exped";
	}
}

function getNodeHtml(n, deep){
	var html = new Array();
	if(n.text) {
		html.push("<li style='margin-left:" + deep*15 +"px'>" + n.value + ":" + n.text + "</li>");
	}
	if(n.nodes && n.nodes.length>0) {
		html.push("<ul style='margin-left:" + deep*15 +"px'>");
		for(var i=0; i < n.nodes.length ; i++){
			html.push(getNodeHtml(n.nodes[i],deep+1));
		}
		html.push("</ul>");
	}
	return html.join("");
}

function showtreeSource(a) {
	var p = a.parentNode.parentNode;
	var span = p.getElementsByTagName("span")[0];
	var o = eval("(" + span.innerHTML + ")");
	var div = p.getElementsByTagName("div")[0];
	if(!div) {
		div = document.createElement("div");
		div.style.cssText = "margin:10px;display:none;border:1px dotted #ccc;padding:10px;color:#3333bb;line-height:15px";
		div.innerHTML = getNodeHtml(o,0)
		p.appendChild(div);
	}
	a.innerHTML = a.innerHTML.indexOf("查看")>0 ? a.innerHTML.replace("查看","隐藏") : a.innerHTML.replace("隐藏","查看");
	div.style.display = (div.style.display == "none" ? "":"none")
}

function getNextElem(li) {
	var ol = li.parentNode;
	for (var i = 0; i < ol.children.length ; i++ )
	{
		if(ol.children[i]==li) {
			return ol.children[i+1];
			return;
		}
	}
	return null;
}

function expjsn(box){
	var li = box.parentNode;
	var ol = getNextElem(li)
	if (box.src.indexOf("11.gif")>0)
	{
		box.src = box.src.replace("11.gif","12.gif");
		if(ol) ol.style.display = "";
	}
	else{
		box.src = box.src.replace("12.gif","11.gif");
		if(ol) ol.style.display = "none";
	}
}