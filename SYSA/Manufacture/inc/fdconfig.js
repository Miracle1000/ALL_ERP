var fSet = new Object();
window.newaddindex = 0;
fSet.addField = function(){ //添加字段
	var pageIndex = 0 , currPage = null
	while (document.getElementById("F_TableItem" + pageIndex))
	{
		currPage = document.getElementById("F_TableItem" + pageIndex); 
		if(currPage.style.display.length==0){break;}
		pageIndex ++; 
	}

	var box = document.getElementById("nullField" + pageIndex)
	var newField = (box ? box : document.getElementById("nullField")).children[0].cloneNode(true)
	if(currPage){

		var radios = newField.getElementsByTagName("td")[8];
		if(radios.innerHTML.indexOf("fd_0_rdo")==-1){
			 radios = newField.getElementsByTagName("td")[9];
		}
		window.newaddindex  ++;
	
		radios.innerHTML = radios.innerHTML.replace(/fd_0_rdo/g,"A_" + window.newaddindex + "fd_0_rdo");
		maxCount = currPage.children.length + 1
	    newField.rows[0].cells[0].children[1].innerHTML = "<img src='../../images/jiantou.gif'>自定义字段" + maxCount ;
		currPage.appendChild(newField)
	}
}

fSet.CreatedefList = function(span){ //创建空自定义枚举内容
	var t = new Date()
	ajax.regEvent("CdefList");
	span.parentElement.innerHTML = ajax.send().replace(/\_lvwtt\#\$/g,"_lvw" + t.getTime());
	lvw.UpdateAllScroll()
}

fSet.CleardefList = function(span){
	span.parentElement.parentElement.innerHTML = "<span class=link style='left:10px' onmouseover='Bill.showunderline(this,\"red\")' "
								+ "onmouseout='Bill.hideunderline(this,\"blue\")' onclick='fSet.CreatedefList(this)'>创建内容</span> "
								+ "<span class=link style='position:relative;left:10px;display:none' onmouseover='Bill.showunderline(this,\"red\")' onmouseout='Bill.hideunderline(this,\"blue\")'  onclick='fSet.SelectSysList(this)'>内置内容</span>"
}

fSet.dataTypeChange = function(sBox){
	var display = sBox.value == 7 ? "" : "none";
	var notnull = (sBox.value == 7 || sBox.value == 6 || sBox.value == 4 || sBox.value == 3) ? "hidden" : ""
	var rows = sBox.parentElement.parentElement.parentElement.rows
	rows[rows.length-1].style.display = display;
	rows[rows.length-2].cells[1].children[0].cells[6].style.visibility = notnull;
	rows[rows.length-2].cells[1].children[0].cells[7].style.visibility = notnull;
}

fSet.SelectSysList = function(span){  //显示系统枚举项目的清单
	ajax.regEvent("getSysList");
	var r =  ajax.send();
	span.parentElement.innerHTML = r;
	lvw.UpdateAllScroll()
}

fSet.ShowSysListBody = function(sBox){ //显示具体枚举项目的内容
	ajax.regEvent("ShowSysListBody");
	ajax.addParam("SelectId",sBox.value);
	var r =  ajax.send();
	var tb = window.getParent(sBox,4)
	tb.rows[2].cells[0].innerHTML = r
	lvw.UpdateAllScroll()
}

fSet.delField = function(lk){
	var fdTab = window.getParent(lk,7);
	fdTab.parentElement.removeNode(fdTab);
	//自动更新标题序号
	var pageIndex = 0 , currPage = null
	while (document.getElementById("F_TableItem" + pageIndex))
	{
		currPage = document.getElementById("F_TableItem" + pageIndex); 
		if(currPage.style.display.length==0){break;}
		pageIndex ++; 
	}
	if(currPage){
		for (var i = 0; i <  currPage.children.length; i ++ )
		{
			var tb = currPage.children[i]
			tb.rows[0].cells[0].children[1].innerHTML = "<img src='../../images/jiantou.gif'>自定义字段" + (i+1) + (tb.rows[1].cells[1].children[0].value.length>0 ? "-[" + tb.rows[1].cells[1].children[0].value + "]" : "");
		}
	}
}

fSet.SaveField = function(){
	window.errorMessage = new Array();
	window.currSelIndex = 0;
	var data = this.GetSaveData();
	if(data.indexOf("#error")>=0){
		alert(window.errorMessage.join("\n\n"));
		return false;
	}
	ajax.regEvent("Save");
	ajax.addParam("data",data);
	ajax.addParam("url",window.location.href.split("?")[1]);
	ajax.addParam("selindex",window.currSelIndex);
	ajax.exec();
}


fSet.GetSaveData = function(){
	var dbody = document.getElementById("billBodyDiv") 
	var PageDatas = new Array()
	for (var  i=0; i < dbody.children.length ; i ++ )
	{
		var title = document.getElementById("TabCtl_topMenu").rows[0].cells[i].innerText.replace(/\s/g,"");
		if(dbody.children[i].style.display!="none"){  window.currSelIndex = i; }
		dat = this.GetPageData(dbody.children[i], title)
		if(dat.length==0){return "";}
		if(dat!="$data$"){
			PageDatas[PageDatas.length] = dbody.children[i].getAttribute("orderid") + "\2"+ dat;
		}
		else{
			PageDatas[PageDatas.length] = dbody.children[i].getAttribute("orderid") + "\2";  //binary:2016.02.01注意，如无此句，系统将无法删除空的
		}
	}
	return PageDatas.join("<#page#>");
}

fSet.GetPageData = function(ItemPage, title){
	var  FieldDatas = new Array()
	var  dat = ""
	if (ItemPage.children.length==0)
	{
		return "$data$"
	}
	for (var i=0;i<ItemPage.children.length ;i++ )
	{
		dat =  this.GetFieldData(ItemPage.children[i], title);
		if(dat.length==0){return "";}
		FieldDatas[FieldDatas.length] = dat;
		
	}
	return  FieldDatas.join("<#field#>")
}
fSet.WriteVar = function(varName) {
	try{
		return eval("var " + varName + " = true;" + varName)
	}
	catch(e){
		return false;
	}
}
fSet.GetFieldData = function(FieldDiv, title) {
	var islist = false
	var vname = FieldDiv.rows[1].cells[1].children[0].value
	if(!fSet.WriteVar(vname) || vname.indexOf("_")==0){
		window.errorMessage[window.errorMessage.length] = ("【" + title + "】中字段名称【" + FieldDiv.rows[1].cells[1].children[0].value + "】不符合要求。 \n  说明：字段名称必须以字母和汉字开始，不能包含空格或标点符合。")
		return "#error";
	}
	if(FieldDiv.rows[1].cells[3].children[0].value-7 == 0){
		islist = true
	}
	return	FieldDiv.parentElement.getAttribute("childid") + "<#item#>"				//子表配置id,对于主表为0
			+ FieldDiv.getAttribute("ConfigId") + "<#item#>"						//原始配置id,存在则是修改，为0则添加
			+ FieldDiv.rows[1].cells[1].children[0].value + "<#item#>"	//字段名称
			+ FieldDiv.rows[1].cells[3].children[0].value + "<#item#>"	//字段类型
			+ FieldDiv.rows[2].cells[1].getElementsByTagName("Input")[0].checked*1 + "<#item#>"	//是否启用
			+ FieldDiv.rows[2].cells[3].children[0].value + "<#item#>"								//排序序号
			+ FieldDiv.rows[3].cells[1].children[0].rows[0].cells[0].children[0].checked*1 + "<#item#>"	//是否检索
			+ FieldDiv.rows[3].cells[1].children[0].rows[0].cells[3].children[0].checked*1 + "<#item#>"	//是否导出
			+ FieldDiv.rows[3].cells[1].children[0].rows[0].cells[6].children[0].checked*1 + "<#item#>"	//是否必填
			+ FieldDiv.rows[3].cells[1].children[0].rows[0].cells[9].children[0].checked*1 + "<#item#>"	//是否必填
			+ (islist ? this.GetListBodyData(FieldDiv.rows[4].cells[1]) : "")
}

fSet.GetListBodyData = function(td){
	var cld = td.children[0];
	var cldname = $(cld).attr("name");
	if(cld.tagName == "TABLE"){
		if(cldname=="SysDefList"){
			return cld.rows[0].cells[0].children[0].value
		}
	}
	if(cld.tagName == "DIV"){
		if(cldname=="MyDefList"){
			if(!cld.selid){cld.selid = 0}
			return cld.selid + "===" + this.GetDefListData(cld.children[0].rows[0].cells[0].children[0]) 
		}
	}
	return "";
}

fSet.GetDefListData = function(div){
	return lvw.GetSaveDetailData(div)
}