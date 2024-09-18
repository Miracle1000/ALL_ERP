tvw.callbackurl = window.location.href
lvw.hasaddlist = false
var bing = 0
function resulthandle(li) {
	return function (r)
	{
		bing = 0
		li.nextSibling.children[0].innerHTML = r
		tvw.expNode(li.getElementsByTagName("img")[0])
	}
}
function addcptreenode(li){
	if (bing == 1) { return }
	var id = li.tag.replace("sys_pdm_","")
	ajax.url = window.location.href
	ajax.regEvent("AddCPTreeItem");
	ajax.addParam("key",id);
	ajax.addParam("selID",window.asp_id);
	ajax.addParam("sql", document.getElementById("tmpSql").value);
	li.nextSibling.style.display = "block";
	bing = 1
	li.nextSibling.children[0].innerHTML = "<span style='color:blue'>&nbsp;&nbsp;&nbsp;&nbsp;正在加载,请稍等...</span>"
	ajax.send(resulthandle(li));
}
tvw.itemClick = function (li, isproduct) {
    try {
        var id = li.getAttribute('tag')
    } catch (e) {
        var id = li.tag
    }
    if (id&&id.indexOf("sys_pdm_") == 0 && isproduct != 1) { //容错处理
		addcptreenode(li)
		return;
	}
	var disMultiline = window.asp_disMultiline;
	//var status = document.getElementById("status") ? document.getElementById("status").value : "";
	ajax.url = window.location.href
	ajax.regEvent("AddListItem");
	//ajax.addParam("status",status);
	ajax.addParam("key",id);
	ajax.addParam("selID",window.asp_id);
	ajax.addParam("isproduct",isproduct?1:0);
	var r = ajax.send()
	if(r.length==0){
		alert("没有返回可添加的数据，请确认标识字段是否与条件相关。")
		return false
	}
	r = r.split("a\3\4")
	var div = document.getElementById("listview_list1")
	var tb = div.children[0]
	if (disMultiline==0)  //允许多行
	{
		for (var i = 0; i < r.length - 1 ; i ++ )
		{
			var cells = r[i].split("a\1\2") ;
			lvw.addDataRow(div,cells)
			var peatRowIndex = lvw.IsRepeatRow(div)
			if(peatRowIndex>0){
				div.hdataArray.splice(div.hdataArray.length-1,1)
				alert("【" + li.innerText + "】已经添加，位于第" + (peatRowIndex) + "行。" )
				return false;
			}
			else
			{
				lvw.addRow(tb)
			}
			lvw.Refresh(div)
		}
	}
	else{
		if(r.length>0){
			var cells = r[0].split("a\1\2") ;
			var ctr = div.children[0].rows[1]
			if(!lvw.hasaddlist || !ctr){
				lvw.addDataRow(div,cells)
				lvw.addRow(tb)
				lvw.hasaddlist = true
			}
			else{
				lvw.updateDataRow(ctr,cells)
			}
			lvw.Refresh(div)
		}

	}
	if(r.length>0 && disMultiline==0){
		//li.style.color = "#aaaaaa";
		//li.disabled = true;
	}
}
function GroupKeyDown(input){ //关键字搜索输入框按键
	if(window.event.keyCode==13||window.event.keyCode==40){
		input.select();
		input.focus();
		window.event.returnValue = false;
		window.event.keyCode  = 0;
		var status = document.getElementById("status") ? document.getElementById("status").value : "";
		ajax.url = window.location.href
		ajax.regEvent("KeySearch");
		ajax.addParam("status",status);
		ajax.addParam("gpname",document.getElementById("KeyGroup").value);
		ajax.addParam("key",input.value);
		ajax.addParam("selID", window.asp_id);
		var r = ajax.send();
		var rows = r.split("||");
		var hs =  0;
		html = "<ul style='margin:0px;padding:0px;margin-top:4px;margin-left:5px;' class='treeview'>"
		for (var i=0;i<rows.length;i++)
		{
			var item = rows[i]

			if(item.length>0){
				item = item.split(";;")
				if(item.length==3){
					hs ++;
					html = html + "<li onclick='tvw.itemClick(this)' onmousedown='tvw.select(this)' style='white-space: nowrap;' class='tvw_item' tag='" + item[2] + "'><span><img src='../../images/icon_sanjiao.gif'></span><span class='tvw_itemtext' onmouseover='tvw.itemmouseover(this)' onmouseout='tvw.itemmouseout(this)'>" + item[0]
					if (item[1].length>0)
					{
						html = html + "(" + item[1] + ")</span>"
					}
					else{
						html = html + "</span>"
					}
				}
			}
		}
		html = html + "<ul>"
		if (hs<1)
		{html = "<span style='color:red'><br>&nbsp;&nbsp;没有符合条件的数据." + (r.length>5?"<input title='有警告或错误，点击查看详情' type=image src='../../images/smico/study.gif' onclick='this.parentElement.children[2].style.display=\"inline\"'><span style='display:none;color:blue;font-family:arial'><br><br>" + r + "</span>" : "") + "</span>" ;}
		document.getElementById("listPanel").innerHTML = html
		ShowGroupTree(false);
		if (hs==1)
		{
			var li = document.getElementById("listPanel").children[0].children[0];
			tvw.select(li);
			li.click();
		}
		return false;
	}
}
function statusSelect(input){ //人员状态选择检索
		input.select();
		input.focus();
		window.event.returnValue = false;
		window.event.keyCode  = 0;
		var status = document.getElementById("status") ? document.getElementById("status").value : "";
		ajax.url = window.location.href
		ajax.regEvent("KeySearch");
		ajax.addParam("status",status);
		ajax.addParam("gpname",document.getElementById("KeyGroup").value);
		ajax.addParam("key",input.value=="输入后按回车搜索"?"":input.value);
		ajax.addParam("selID", window.asp_id);
		var r = ajax.send();
		var rows = r.split("||");
		var hs =  0;
		html = "<ul style='margin:0px;padding:0px;margin-top:4px;margin-left:5px;' class='treeview'>"
		for (var i=0;i<rows.length;i++)
		{
			var item = rows[i]

			if(item.length>0){
				item = item.split(";;")
				if(item.length==3){
					hs ++;
					html = html + "<li onclick='tvw.itemClick(this)' onmousedown='tvw.select(this)' style='white-space: nowrap;' class='tvw_item' tag='" + item[2] + "'><span><img src='../../images/icon_sanjiao.gif'></span><span class='tvw_itemtext' onmouseover='tvw.itemmouseover(this)' onmouseout='tvw.itemmouseout(this)'>" + item[0]
					if (item[1].length>0)
					{
						html = html + "(" + item[1] + ")</span>"
					}
					else{
						html = html + "</span>"
					}
				}
			}
		}
		html = html + "<ul>"
		if (hs<1)
		{html = "<span style='color:red'><br>&nbsp;&nbsp;没有符合条件的数据." + (r.length>5?"<input title='有警告或错误，点击查看详情' type=image src='../../images/smico/study.gif' onclick='this.parentElement.children[2].style.display=\"inline\"'><span style='display:none;color:blue;font-family:arial'><br><br>" + r + "</span>" : "") + "</span>" ;}
		document.getElementById("listPanel").innerHTML = html
		ShowGroupTree(false);
		if (hs==1)
		{
			var li = document.getElementById("listPanel").children[0].children[0];
			tvw.select(li);
			li.click();
		}
		return false;
}
function ShowGroupTree(visible){ //显示分类树界面
	if(visible){
		document.getElementById("groupPanel").style.display = "block";
		document.getElementById("listPanel").style.display = "none";
	}
	else{
		document.getElementById("groupPanel").style.display = "none";
		document.getElementById("listPanel").style.display = "block";
	}
}

function PageOpen(url){ //弹出页面
	var w = 860 , h = 640 ;
	var l = (screen.availWidth - w) / 2
	var t = (screen.availHeight - h) / 2
	window.open(url,null,"height=" + h + ",width=" + w + ",left=" + l + ",top=" + t + ",status=no,toolbar=no,menubar=no,location=no,resizable=yes")
}

function doSave(){ //保存页面数据
	var i , ii , iii
	var div = document.getElementById("listview_list1")
	lvw.TryCreateHiddenPageDataToArray(div);
	var tb = div.children[0]
	var sCol = window.asp_sColumns.split(";");
	var aindex = div.autoindex=="1"?1:0;
	var hsCheck = div.checkbox=="1"?1:0; //是否有选择框
	var hsAutoSum = div.autosum=="1"?1:0;
	var  rows = new Array()
	var tests = ""
	for(i = 0 ; i < div.hdataArray.length; i ++ ) {  //老版错误for(i = 1 ; i < div.hdataArray.length - hsAutoSum ; i ++ )
		var tr = tb.rows[i];
		var r = new Array();
		var iii = 0;
		var cells = div.hdataArray[i];
		var headers = tb.rows[0].cells;
		for (ii = 0; ii < sCol.length ; ii ++ )
		{
			if(isNaN(sCol[ii]) || sCol[ii].length == 0 ){
				r[ii] = "$0x-null"
				tests +=("ii=" + ii + ", sCol[" + ii + "]=" + sCol[ii] + ", value=$0x-null\n")
			}
			else{
				if(sCol[ii]==-1){
					r[ii] = "$0x-space"
					tests +=("ii=" + ii + ", sCol[" + ii + "]=" + sCol[ii] + ", value=$0x-space\n")
				}
				else{
					var cellindex = sCol[ii]*1+1
					if(cellindex<cells.length) //考虑到产品自定义字段动态的情况
					{
						tests +=("ii=" + ii + ", sCol[" + ii + "]=" + sCol[ii] + ", value=" + cells[cellindex] + "\n")
						r[ii] = cells[cellindex].replace("#lvwtag",lvw.sBoxSpr).replace(/\\/g,"\\\\").replace(/\"/g,'\\"').replace(/\r\n/g,"\\r\\n").replace(/\n/g,"\\n");
					}
				}
			}
		}
		rows[i] = "[\"" + r.join("\",\"") + "\"]";
	}

	if (window.dialogArguments !=undefined) {
	    top.returnValue = "[" + rows.join(",") + "]";   //模态框走该分支
	} else {
		if(top.opener && top.opener.showModalDialogProxyFun) {
			top.opener.showModalDialogProxyFun("[" + rows.join(",") + "]");
		}
	}
	//测试代码，误删：alert("window.asp_sColumns=[" + window.asp_sColumns + "]\n\n" + tests)
	top.close();
}
var moveing = false
function BeginResize(rbar){
	if(!rbar){return;}
	rbar.style.backgroundImage = "url(../../images/smico/resizesd.gif)";
	rbar.setCapture();
	moveing = true
}
function EndResize(rbar){
	if(!rbar){
		if($ID("RightListDiv")) { $ID("RightListDiv").style.left = "0px";}
		return;
	}
	rbar.style.backgroundImage = "url()";
	rbar.releaseCapture();
	moveing = false
	if($ID("leftMenuDiv")) {
		if($ID("leftproductfrm")){
			$ID("leftMenuDiv").style.height = document.documentElement.offsetHeight + "px";
		}
		$ID("leftMenuDiv").style.width = (rbar.offsetLeft -3) + "px"; 
	}
	if($ID("RightListDiv")) { $ID("RightListDiv").style.left = (rbar.offsetLeft + 5) + "px";}
	if($ID("listPanel")) { $ID("listPanel").style.width =  (rbar.offsetLeft -5) + "px";}
	if($ID("groupPanel")) {$ID("groupPanel").style.width =  (rbar.offsetLeft -5) + "px";}
	if($ID("leftproductfrm")) {
		$ID("leftproductfrm").style.height = $ID("leftMenuDiv").offsetHeight + "px";
	}
}
function MoveReSize(rbar){
	if(moveing){
		if ((window.event.x-2) > 100 && (window.event.x-2) < document.body.offsetWidth -200 )
			rbar.style.left = (window.event.x-2) + "px"
	}
}

window.$ID = function(id){
	return document.getElementById(id);
}

$(window).load(function(){
	var disMultiline = window.asp_disMultiline;
	//var status = document.getElementById("status") ? document.getElementById("status").value : "";
	ajax.url = window.location.href
	ajax.regEvent("AddInitItems");
	ajax.addParam("selID",window.asp_id);
	var r = ajax.send()
	if(r.length==0){return false;}
	r = r.split("a\3\4")
	var div = document.getElementById("listview_list1")
	var tb = div.children[0]
	if (disMultiline==0)  //允许多行
	{
		for (var i = 0; i < r.length - 1 ; i ++ )
		{
			var cells = r[i].split("a\1\2") ;
			lvw.addDataRow(div,cells)
			lvw.addRow(tb)
			lvw.Refresh(div)
		}
	}
	else{
		if(r.length>0){
			var cells = r[0].split("a\1\2") ;
			var ctr = div.children[0].rows[1]
			if(!lvw.hasaddlist || !ctr){
				lvw.addDataRow(div,cells)
				lvw.addRow(tb)
				lvw.hasaddlist = true
			}
			else{
				lvw.updateDataRow(ctr,cells)
			}
			lvw.Refresh(div)
		}

	}
})