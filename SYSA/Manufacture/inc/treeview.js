function treeview(){
	var base = new Object()
	base.callbackurl = "";
	base.itemmouseout = function(item){ //失去鼠标时样式
		item.className = "tvw_itemtext"
	}

	base.itemmouseover = function(item){ //获取鼠标时样式
		item.className = "tvw_selitemtext"
	}
	
	base.getRoot = function(item){ //获取根节点
		while(item.className!="treeview" && item.parentElement)
		{item = item.parentElement;}
		return item;
	}

	base.select = function(item){  //鼠标选中节点
		if(window.event && window.event.button>1) {return false;} 
		var root = base.getRoot(item);
		if(root.selectNode){
			var pNode = root.selectNode;
			pNode.className = "tvw_item";
		}
		else{ //检测初始化选中的情况
			var items = root.getElementsByTagName("LI")
			for (var i=0;i<items.length ;i++ )
			{
				if(items[i].className.indexOf("tvw_selitem")>0){
					items[i].className = "tvw_item"
				}
			}
		}
		item.className = "tvw_item tvw_selitem";
		root.selectNode = item;
	} 
	
	base.expNode = function(img){ //展开或收缩节点
		if(window.event && window.event.button>1) { return false; } 
		var u = img.src;
		var t = 0 , cLi = null;
		var li = img.parentElement.parentElement;
		if(li.nextSibling.getAttribute("LiType")=="ChildNodes"){
			cLi = li.nextSibling;
		}
		if (u.length == 0 ){ t = 1; }
		else{if (u.indexOf("minus.gif")>0) { t = 2; } else { t = 3;} }
		if(li.getAttribute("vHasChild")=="1"){
			li.setAttribute("vHasChild","0");
			base.getchilds(li);
			return;
		}
		switch(t){
			case  1:
				break;
			case  2:	//收缩
				img.src = "../../images/smico/plus.gif"
				cLi.style.display = "none";
				break;
			default:	//展开
				img.src = "../../images/smico/minus.gif"
				var li = img.parentElement.parentElement;
				cLi.style.display = "";
				break;
		}
	}

	base.getTextPath = function(li){//获取文本路径
		var txt = li.innerText.replace(/(\s*$)/g,"");
		var item = li;
		while(item.className!="treeview" && item.parentNode)
		{
			item = item.parentNode;
			if(item.tagName=="LI" && item.getAttribute("LiType") == "ChildNodes"){
				var txtli = item.previousSibling;
				txt = txtli.innerText.replace(/(\s*$)/g,"") + "\\" +  txt.replace("<空值>",""); 
			}
		}
		return txt;
	}
	
	base.getTagPath = function(li){//获取tag值路径；ps:tag为自定义属性，ie8,9,10不能直接使用li.tag获取
	    var txt = li.getAttribute('tag').replace(/(\s*$)/g, "");
		var item = li;
		while(item.className!="treeview" && item.parentElement)
		{
			item = item.parentElement;
			if(item.tagName=="LI" && item.getAttribute("LiType") == "ChildNodes"){
				var txtli = item.previousSibling;
				txt = txtli.getAttribute('tag').replace(/(\s*$)/g, "") + "\\" + txt;
			}
		}
		return txt;
	}

	base.getchilds = function(li) { //获取子节点信息
		if(window.event && window.event.button>1) { return false; } 
		if(li.getAttribute("ChildTest")!="1") { 
			if(base.itemClick){return base.itemClick(li);}
			if(base.ItemClick){return base.ItemClick(li);}
			if(base.itemclick){return base.itemclick(li);}
			if(base.Itemclick){return base.Itemclick(li);}
			return false;
		}
		var path1 = base.getTextPath(li);
		var path2 = base.getTagPath(li);
		var root = base.getRoot(li);
		if(ajax){
			if(base.callbackurl.length>0){
				ajax.url = base.callbackurl;
			}
			ajax.regEvent("tvwExpand");
			ajax.addParam("tvwid",root.id);
			ajax.addParam("tagPath",path2);
			ajax.addParam("txtPath",path1);
			ajax.addParam("tag", root.getAttribute('tag'))
			if (tvw.ongetChildren)
			{tvw.ongetChildren(li);}
			r = ajax.send();
			if (r.indexOf("tvwChild=")==0)
			{
				r = r.replace("tvwChild=","")
				var nextli = li.nextSibling
				nextli.children[0].innerHTML = r;
				nextli.style.display = "";
				li.children[0].innerHTML = "<img src='../../images/smico/minus.gif' onmousedown='tvw.expNode(this)'>"
				if (tvw.onAfterChildren){tvw.onAfterChildren(li);}
			}
		}
	}
	
	base.getselectNode = function(root){
		if(root.selectNode){return root.selectNode;}
		var items = root.getElementsByTagName("li");
		for (var i = 0; i < items.length ; i++ )
		{
			if(items[i].className=="tvw_item tvw_selitem"){
				root.selectNode = items[i];
				return root.selectNode;
			}
		}
	}
	
	base.tryexpNode = function(li){ //展开节点,没有则请求服务端
		var img = li.children[0].children[0]
		var t = 0
		if(!img) { t = 1 }
		else{
			u = img.src;
			if (u.length == 0 ){ t = 1; }
			else{if (u.indexOf("minus.gif")>0) { t = 2; } else { t = 3;} }
		}
		if(li.getAttribute("vHasChild")=="1"){t = 1;li.setAttribute("vHasChild","0");}
		switch(t){
			case  1:
				base.getchilds(li);
				break;
			case  2:	//收缩,此处不自动收缩
				break;
			default:	//展开
				img.src = "../../images/smico/minus.gif";
				li.nextSibling.style.display = "";
				break;
		}

		if (base.NodeClick)
		{return base.NodeClick(li)}
	}
	
	base.updateNodeText = function(li , newValue){
		var  span = li.getElementsByTagName("span");
		span[span.length-1].innerHTML = newValue;
	}

	base.delUiNode = function(id,li){ //根据li删除节点，li不存在则删除选中的节点
		if(!li){
			var ul = document.getElementById("treeview_id" + id)
			if(ul){
				var lis = ul.getElementsByTagName("li")
				for (var i=0;i<lis.length ;i ++)
				{
					if (lis[i].className.indexOf("tvw_selitem")>0)
					{
						li = lis[i];
						break;
					}
				}
			}
			else{return false;}
		}
		if(li){
			var nextli = li.nextSibling;
			nextli.outerHTML = "";
			li.outerHTML = "";
		}
	}
		
	base.GoToPage = function(pindex){ //treeview分页
		if(pindex<=0){
			alert("已经是首页")
			return
		}
		window.event.srcElement.disabled = true;
		var td = window.event.srcElement.parentElement;
		var li = window.getParent(td,6).previousSibling;
		if(isNaN(pindex)) { pindex = td.getElementsByTagName("input")[0].value}
		frmdat = td.formdata  + "&sys_tvw_pindex=" + pindex;
		ajax.sendText = frmdat;
		r = ajax.send();
		if (r.indexOf("tvwChild=")==0)
		{
			r = r.replace("tvwChild=","")
			var nextli = li.nextSibling
			nextli.children[0].innerHTML = r;
			nextli.style.display = "";
			li.children[0].innerHTML = "<img src='../../images/smico/minus.gif' onmousedown='tvw.expNode(this)'>"
			if (tvw.onAfterChildren){tvw.onAfterChildren(li,1);}
		}
	}

	return base;
}


var tvw = new treeview()