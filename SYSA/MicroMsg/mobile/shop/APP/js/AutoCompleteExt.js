//依赖JQuery框架
(function (){
//历史记录列表处理事件
window._g_e_slmover = function(li,t, id) {
	if(t==3) {
		var shlist = window.localStorage["_gl_shlist"];
		if(shlist) {
			shlist = eval("(" + shlist + ")");
			for (var i = 0; i< shlist.length; i++)
			{
				if(shlist[i][0]==id) {
					shlist.splice(i,1);
					window.localStorage["_gl_shlist"] = JSON.stringify(shlist);
					showsearchListDiv($("#"+id)[0],"werwerasasdfsdasd","itemclick");
					break;
				}
			}
		}
		return;
	}
	if(t==2) { $("#" + id)[0].value=(li.innerHTML); 
	if(window.onsearchBoxSelected) {window.onsearchBoxSelected(id, li.innerHTML);}
	return; }
	li.style.backgroundColor =(t==0?"transparent":"#e2e2f4");
}

//创建历史记录列表
function showsearchListDiv(obj, keyv, frmkey) {
	var pos = $(obj).offset();
	var id =  "sl_" + obj.id;
	var lincss = "padding:4px 6px;font-size:12px;border-top:1px dashed #e2e2f2;cursor:default;list-style-type:none;display:block;width:100%;overflow:hidden;text-overflow:ellipsis;white-space: nowrap;"
	var div = document.getElementById(id);
	if(!div) {
		div = document.createElement("div");
		div.id = id;
		document.body.appendChild(div);
	}
	var list = new Array();
	var shlist = window.localStorage["_gl_shlist"];
	if(shlist) {shlist=eval("(" +shlist+ ")");}
	for (var i=0; i< shlist.length ; i ++ )
	{
		if(shlist[i][0]==obj.id) { 
			for (var ii=shlist[i].length-1; ii >=1  ; ii--)
			{
				if((keyv==""||shlist[i][ii].indexOf(keyv)>=0) && shlist[i][ii]) {
					list.push("<li onclick='_g_e_slmover(this,2,\"" + obj.id + "\")' onmouseover='_g_e_slmover(this,1)'  onmouseout='_g_e_slmover(this,0)'  style='" + lincss + (list.length==0?"border-top-width:0px":"") + "'>" + shlist[i][ii] + "</i>");
				}
			}
			break; 
		}
	}
	if(list.length==0) { document.body.removeChild(div); } 
	else {
		div.style.cssText = "width:98%;text-align:left;z-index:10000;border:1px solid #e2e2f2;background-color:#fff;display:block;position:absolute;top:" + (pos.top + obj.offsetHeight+12) + "px;overflow:hidden;left:1%;";
		div.innerHTML = list.join("") + "<li style='" + lincss + "' onclick='_g_e_slmover(this,3,\"" + obj.id + "\")'>"
		+ "<a href='javascript:void(0)' style='width:50%;border-radius:5px;background:#f4f4f4;font-size:11px;color:#999;padding:2px;border:1px solid #ccc;margin:10px auto;display:block;text-align:center'>"
		+ "清除所有历史记录...</a></li>";
	}
}
//历史记录事件源对象事件处理
function InputEvt(ev) {
	var obj = ev.target;
	var tye = ev.type;
	switch(tye) {
		case "focus": obj.select();showsearchListDiv(obj,"",tye);   break;
		case "blur":  setTimeout(function(){showsearchListDiv(obj,this.value,tye);},100);  break;
		case "keydown": showsearchListDiv(obj, obj.value,tye); break;
		case "keyup":  showsearchListDiv(obj, (ev.keyCode==13?"sadasff4535354xc":obj.value), tye); break;
		case "change": showsearchListDiv(obj, obj.value,tye); break;
		case "input": showsearchListDiv(obj, obj.value,tye); break;
	}
}
//历史记录事件源对象事件绑定
function BindEvents(obj) {
	if(obj && obj.getAttribute("bindslevent") != 1){
		obj.setAttribute("bindslevent",1);
		obj.addEventListener("blur", InputEvt);
		obj.addEventListener("keyup", InputEvt);
		obj.addEventListener("keydown", InputEvt);
		obj.addEventListener("focus", InputEvt);
		obj.addEventListener("change", InputEvt);
		obj.addEventListener("input", InputEvt);
	}
}

var shlist = window.localStorage["_gl_shlist"];
if(shlist) {
	shlist = eval("(" + shlist + ")");
	for (var i = 0; i< shlist.length; i++)
	{
		BindEvents(document.getElementById(shlist[i][0]));
		//alert(document.getElementById(shlist[i][0]))
	}
}
//外部调用函数
window.bindSearchHistory = function(id) {
	var obj = $("#"+id)[0];
	if(!obj || !obj.value) {return;}
	var shlist = window.localStorage["_gl_shlist"];
	if(shlist) {shlist=eval("(" +shlist+ ")");}
	var x = 0;
	if(!shlist) { 
		shlist = new Array();
		shlist[0] = new Array();
		shlist[0][0] = id;
	}
	else {
		x = -1;
		for (var i=0; i< shlist.length ; i ++ ) { if(shlist[i][0]==id) { x = i; break; } }
		if(x==-1) { x = shlist.length; shlist[x] = new Array();shlist[x][0] = id;}
	}
	for (var i=1; i<shlist[x].length; i++) { if(shlist[x][i]==obj.value) { shlist[x].splice(i,1); break; } } //记录内容去重
	if(shlist[x].length<11) { //只记录前10条
		shlist[x].push(obj.value);
	}else {
		for (var i = 2; i < shlist[x].length ; i++ ) { shlist[x][i-1] = shlist[x][i]; }
		shlist[x][shlist[x].length-1] = obj.value;
	}
	window.localStorage["_gl_shlist"] = JSON.stringify(shlist);
	BindEvents(obj);
}
})()

window.onsearchBoxSelected = function(id, text){
	try{$("#search").click();}catch(e){};
}