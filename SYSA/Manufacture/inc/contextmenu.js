////////////////bihua_520  2010-1-16 实现office风格菜单///////////////////////
window.GetTopVirPath = function(){
	return (top.virpath? top.virpath:(top.sysCurrPath?top.sysCurrPath :"../../"));
}
function contextmenuitem(){
	var obj = new Object()
	obj.text = "默认菜单项";
	obj.imageurl  = "";
	obj.checked  = false;
	obj.disabled = false
	obj.tag = "";
	obj.imagealign = "right";
	obj.childmenu = null;
	obj.sort = 0;  //自动排序
	return obj;
}
function contextmenu(itemclickback){
	var obj = new Object()
	//obj.oPopup = window.createPopup();
	obj.id = "";
	obj.items = new Array()
	obj.width = 0
	obj.additem = function(text,imageurl,tag){
		obj.items[obj.items.length] = new contextmenuitem();
		var itm = obj.items[obj.items.length-1];
		itm.text = text;
		itm.imageurl = imageurl;
		itm.tag = tag;
	}
	
	obj.add = function(){
		obj.items[obj.items.length] = new contextmenuitem();
		return obj.items[obj.items.length-1];
	}

	obj.addsplit = function(){
		obj.items[obj.items.length] = new contextmenuitem();
		obj.items[obj.items.length-1].tag="menu_split_item"
		return obj.items[obj.items.length-1];
	}

	obj.hide = function(){
		var div = top.document.getElementById("Manu_Cont_Manu");
		if(!div) {return;}
		top.document.body.removeChild(div);
	}

	obj.showChildMenu = function(item){
		var si =  item.id.replace("item_0_","")*1;
		var mMenu = obj.items[si].childmenu;
		if(obj.currShowChildMenu==mMenu){
			return ;
		}
		if(typeof(mMenu)!=typeof(this)){
			mMenu = mMenu(item);
		}
		mMenu.show(item, 1);
		obj.currShowChildMenu = mMenu
	}
	
	obj.show = function(bindobj, deep){
		var index = 1;
		deep = deep | 0;
		for(var i = 0 ; i< obj.items.length ; i ++){  //先赋默认序列号
			if(obj.items[i].sort==0){
				obj.items[i].sort = index;
				index ++;
			}
		}
		
		for (var i = 0; i < obj.items.length ; i ++)  //根据sort冒泡一下顺序
		{
			var hs = false
			for (var ii = 0; ii<  obj.items.length-1; ii ++)
			{
				if(obj.items[ii].sort > obj.items[ii+1].sort){
					var c =  obj.items[ii];
					obj.items[ii]   = obj.items[ii+1] ;
					obj.items[ii+1] = c; 
					hs = true
				}
			}
			if(hs==false){break;}
		}
		//obj.oPopup = obj.CreateDiv(bindobj);
		var childmHTML = ""
		var htm = "";
		splits=0
		var topvirpath =  window.GetTopVirPath();
		if(top.location.href.toLowerCase().indexOf("sysn/")>0) {
			topvirpath = topvirpath + "sysa/";
		}
		for (i=0;i<obj.items.length ;i++ )
		{
			if (obj.items[i].tag=="menu_split_item")
			{
				htm = htm + "\n" +  "<div style='margin:3px 1px 2px 24px;border-top:1px groove;height:1px;overflow:hidden;display:block;width:auto;cursor:default'></div>"
				splits++;
			}
			else{
				var imghtml = (obj.items[i].imageurl + "").length>0 ? "<img ondragstart='return false'  src='"+ obj.items[i].imageurl  +"' onerror='this.style.display=\"none\"'>" : "";
				if(obj.items[i].childmenu){
					htm = htm + "\n" +  
					 "		<div id='item_" + deep + "_" + i + "' isContentMenuItem=1 style='padding:1px' tag='" + obj.items[i].tag + "'><table style='table-layout:auto;height:23px;width:auto' oncontextmenu='return false'> \n" + 
					 "		<tr> \n" +
					 "			<td style='width:18px;text-align:" + obj.items[i].imagealign.replace("../../",topvirpath)  + ";'>\n" +
					 imghtml + "<\/td> \n" +
					 "			<td style='padding-left:8px;padding-top:2px;white-space:nowrap;color:#000' valign=middle>" + 
					 "			" + obj.items[i].text  +"</td> \n" +
					 "			<td style='width:18px;background:transparent url(" +  topvirpath + "images/smico/menu_arr.gif) no-repeat right center'></td><td style='width:5px;overflow:hidden'></td>\n" +
					 "		<\/tr>\n" + 
					 "		<\/table></div>"
				}
				else{
					htm = htm + "\n" +  
					 "		<div id='item_" + deep + "_" + i + "' isContentMenuItem=1 style='padding:1px' tag='" + obj.items[i].tag + "'><table style='table-layout:auto;height:23px;width:auto' oncontextmenu='return false'> \n" + 
					 "		<tr> \n" +
					 "			<td style='width:18px;text-align:" + obj.items[i].imagealign.replace("../../",topvirpath)  + ";'>\n" +
					 imghtml + "<\/td> \n" +
					 "			<td style='padding-left:8px;padding-top:2px;white-space:nowrap;color:#000' valign=middle>" + childmHTML + obj.items[i].text  +"</td> \n" +
					 "		<\/tr>\n" + 
					 "		<\/table></div>"
				}
				
			}
		}

		top.topManuContextMenuFun = itemclickback;
		top.CurrContextMenuDatas = obj.items;
		var div = top.document.getElementById("Manu_Cont_Manu");
		if(!div) {
			div = top.document.createElement("div");
			div.id = "Manu_Cont_Manu";
			div.style.cssText = "position:fixed;_position:absolute;width:100%;height:100%;top:0px;left:0px;z-index:10000000;" + (window.ActiveXObject?"background-color:transparent":"background-color:transparent");
			top.document.body.appendChild(div);
			$(div).bind("mousedown", function(){ top.document.body.removeChild(div); });
		}
		
		var oPopupBody = top.document.getElementById("Manu_Cont_Manu_body_" + deep);
		if(!oPopupBody) {
			oPopupBody =top.document.createElement("div");
			oPopupBody.id = "Manu_Cont_Manu_body_" + deep;
			oPopupBody.style.cssText = "background:white  url(" + topvirpath + "images/smico/contextmenubg2.jpg) repeat-y;position:absolute;z-index:" + (1+deep*1) + ";border:1px solid #aaa;padding:1px;width:auto;filter:progid:DXImageTransform.Microsoft.Shadow(Strength=3,Direction=135,Color=#bbbbcc);box-shadow:3px 3px 3px rgba(180,180,200,0.7);"
			div.appendChild(oPopupBody);
		}
		oPopupBody.style.display = "block";
		div.style.display = "block";

		var oPopupBody = top.document.getElementById("Manu_Cont_Manu_body_" + deep);
		$(oPopupBody).bind("mousedown", function(event){event.stopPropagation();});

		oPopupBody.innerHTML = htm;

		for(i=0;i<obj.items.length ;i++ ){
			if(obj.items[i].tag=="menu_split_item"){

			}
			else{
				var itm = $(div).find("#item_" + deep + "_" + i)[0];
				sy = itm.style
				sy.borderCollapse = "collapse" 
				sy.cursor = "default"
				sy.font="normal 12px 宋体";
				itm.onmouseover = function(){
					if(obj.childMenuParent && obj.childMenuParent!=this){
						var  cdiv = obj.childMenuParent;
						cdiv.style.backgroundColor = "transparent";
						cdiv.children[0].style.backgroundColor = "transparent";
					}
					obj.childMenuParent = null;// 当前显示子级菜单的菜单项
					this.style.backgroundColor = "#445594";
					this.children[0].style.backgroundColor = "#ccdfef";
					
					if(obj.currShowChildMenu){
						var div = top.document.getElementById("Manu_Cont_Manu_body_1");
						var rootdiv = top.document.getElementById("Manu_Cont_Manu");
						rootdiv.removeChild(div);
						obj.currShowChildMenu = null;
						obj.childMenuParent = null;
					}

					if(this.innerHTML.indexOf("menu_arr.gif")>0){
						obj.childMenuParent = this;
						obj.showChildMenu(this);
					}
				}
				itm.onmouseout = function(){
					if(obj.childMenuParent && obj.childMenuParent==this){return}
					this.style.backgroundColor = "transparent";
					this.children[0].style.backgroundColor = "transparent";
				}
				itm.onclick= function(){
					if(top.topManuContextMenuFun){
						top.topManuContextMenuFun(this.getElementsByTagName("td")[1].innerText,this.getAttribute("tag"));
					}
					obj.hide();
				}
				itm.disabled = obj.items[i].disabled
			}
		}
		if( obj.width<70){ obj.width=70}

		var s_x , s_y , s_w , s_h , s_obj
		var pos = null;
		if(bindobj){
			var p = bindobj.getBoundingClientRect();
			var childmenupop = bindobj.getAttribute("isContentMenuItem")=="1";
			pos = {x: (p.left + (childmenupop?(bindobj.offsetWidth-4):0)),  y:  (p.top + (childmenupop?4:bindobj.offsetHeight)) };
		}
		else{
			pos = {x: window.event.clientX, y:window.event.clientY};
		}
		var win = (bindobj?(bindobj.ownerDocument.parentWindow?bindobj.ownerDocument.parentWindow:bindobj.ownerDocument.defaultView):window);
		pos = window.getTopPageXY(win, pos.x, pos.y);
		var tbs = oPopupBody.getElementsByTagName("table");
		if(oPopupBody.offsetWidth>0){
			var w = oPopupBody.offsetWidth;
			w = w > 200 ? 200 : w;
			if(w<120) {w =120;}
			oPopupBody.style.width = (w + 15)+ "px";
			for (var i = 0; i < tbs.length; i++ )
			{
				tbs[i].style.width = (w+13) + "px";
				tbs[i].parentNode.style.width = (w+13) + "px";
				tbs[i].style.tableLayout = "fixed";
			}
		}
		pos = window.autoMovePageXY(pos, w, oPopupBody.offsetHeight, top);
		oPopupBody.style.left = pos.x + "px";
		oPopupBody.style.top = pos.y + "px";
	}	
	return obj;
}


function contextmenu_ut(tr){
	tr.style.backgroundColor = "transparent"

}
function contextmenu_mv(tr){
	tr.style.backgroundColor = "#afbfe0"

}