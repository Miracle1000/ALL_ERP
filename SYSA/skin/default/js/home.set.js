function expPanel(index){
	for (var i = 1;i<7 ;i++ )
	{
		var div = document.getElementById("cardbody" + i);
		if(div)
		{
			div.style.display = (i == index) ? "block" : "none";
			var targetBtn = document.getElementById("fbutton" + i);
			if (targetBtn) {
				(i == index) ? $(targetBtn).addClass("actived leftNavBg") : $(targetBtn).removeClass("actived leftNavBg");
			}
		}
	}
	switch(index*1)
	{
		case 2 : loadBody("cardbodyPen2","topMenuSet"); break;
		case 3 : loadBody("cardbodyPen3","TopBarSet");	break;
		case 4 : loadBody("cardbodyPen4","SearchSet");	break;
		case 5 : loadBody("cardbodyPen5","SmpCardSet");	break;
		case 6 : loadBody("cardbodyPen6","RgtCardSet");	break;
	}
}

function cuplogo(btn, tipStr){
	if(typeof(tipStr) == "undefined"){
		tipStr = "logo";
	}
	var murl = jQuery(btn.form).find("#logofilepath")[0].value.toLowerCase();
	if(murl.indexOf(".png")==(murl.length-4))
	{
		if(window.confirm("您确定要替换系统当前"+tipStr+"图片吗?"))
		{
			btn.form.submit();
		}
	}
	else{
		alert("请选择正确的png格式图片,目前"+tipStr+"图片格式只允许为png。");
	}
}

function cdeflogo(btn,logoType, tipStr){
	if(typeof(tipStr) == "undefined"){
		tipStr = "logo";
	}
	if(!window.confirm("确定要恢复系统默认"+tipStr+"图片吗？")) {
		return;
	}
	ajax.regEvent("cdeflogo");
	ajax.addParam('logoType',logoType);
	var r = ajax.send();
	if(r=="1"){
		if (logoType == 'pc_home'){
			var url = top.document.getElementById("logoBox").src;
			url = url.split("?")[0];
			var t =  new Date();
			top.document.getElementById("logoBox").src = url + "?t=" +  t.getTime();
		}
		app.showmsg("恢复成功");
	}
	else{
		alert(r)
	}
}

function loadBody(id , evt){
	if(document.getElementById(id).innerHTML.replace(/\s/g,"")=="")
	{
		ajax.regEvent(evt);
		ajax.send
		(
			function(r)
			{
			    document.getElementById(id).innerHTML = r;
			    tvw.canrepeatClick = true;
			    $(".tvw_txt_sel").trigger("click");
			    tvw.canrepeatClick = false;
				if(evt=="SearchSet") 
				{
					//模拟检索导航树的点击事件
					if (document.getElementById("tvw_searchlist_0_0"))
					{
					var box = document.getElementById("tvw_searchlist_0_0").children[0];
					tvwnodedown(box,"tvw_searchlist_0_0");
					}
				}
			}
		);
	}
}

tvw.onitemclick = function(item){
	if(item.id=="tmcls"){
		ajax.regEvent("GetTopMentClsItem")
		ajax.addParam("clsid",item.value);
		document.getElementById("TopMclsPanel").innerHTML = ajax.send();
		return
	}
	if(item.id=="searchlist") {
		if(!isNaN(item.value)){
			ajax.regEvent("GetSearchItem")
			ajax.addParam("clsid",item.value);
			document.getElementById("SearchItemPanel").innerHTML = ajax.send();
		}
	}
}

//更新菜单分类名称
function topMenuChange(){
	ajax.regEvent("topMenuClsUpdate")
	ajax.addParam("id",document.getElementById("itemcls_id").value);
	ajax.addParam("sort",document.getElementById("cls_sort").value);
	ajax.addParam("name",document.getElementById("itemcls_txt").value);
	ajax.addParam("eable",document.getElementById("tmclsstop1").checked?1:0);
	if(document.getElementById("tmyyfw")){
		ajax.addParam("all",document.getElementById("tmyyfw").checked ? 1 : 0);
	}
	else{
		ajax.addParam("all",0);
	}
	var r = ajax.send();
	if(r==1)
	{
		var nd = tvw.getselNode("tmcls");
		if(nd){
			tvw.setNodeText(nd,document.getElementById("itemcls_txt").value);
		}
	}
	else{
		alert(r)
	}
}

//更新菜单最大显示行数设置
function UpTopMenuPageSize(v){
	ajax.regEvent("topMCSizeUpdate")
	ajax.addParam("size",v)
	var r = ajax.send();
	if(r!="1"){alert(r)}
}

function addtopMenuCls(ParentID){
	var win =  app.createWindow("newclsItemdlg","添加新分类","","", "120", 400, 210, 1, "", "");
	ajax.regEvent("CNewTopMenuClsDlg");
	ajax.addParam("PID",ParentID)
	var r =  ajax.send();
	win.innerHTML = r;
}

function tmcls_oncallback(){
	tvw.getselNode("tmcls").active();
}

function addnewTopClsItem() //添加顶部菜单分类
{
	ajax.regEvent("addNewTopMenuCls");
	ajax.addParam("name",document.getElementById("nitemcls_txt").value);
	ajax.addParam("pid",document.getElementById("ntmclspid").value);
	ajax.addParam("stoped",document.getElementById("ntmclsstop2").checked?1:0);
	var r = ajax.send();
	if(!isNaN(r)){ 
		tvw.callback("tmcls",function(){ajax.addParam("newclsId", r);}, tmcls_oncallback);
		return true; 
	}
	else{ alert(r);}
}

function delTopMenuCls(cls)  //删除顶部菜单分类
{
	if(window.confirm("注意：删除该分类，将同时删除该分类所包含的子分类和子菜单。\n\n您确定要继续吗？"))
	{
		ajax.regEvent("delTopMenuCLs");
		ajax.addParam("cls",cls);
		var r = ajax.send();
		if(!isNaN(r)) {
			tvw.callback("tmcls",function(){ajax.addParam("newclsId", r);}, tmcls_oncallback);
		}
		else{
			alert(r)
		}
	}
}

window.listview_onaddnew = function(id) //触发顶部菜单项添加事件
{
	if(id=="topmenuitem") { editTopMenuItem(0); return; }
	if(id=="topbaredit") { edittopbarItem(0) ; return;}
}

function editTopMenuItem(id)  //显示顶部菜单添加编辑界面
{
    changeLeftNavUrl();
	if(id == 0) {
		var win =  app.createWindow("newcItemdlg","添加菜单","","", "120", 400, 210, 3, "", "");
	}
	else{
		var win =  app.createWindow("newcItemdlg","修改菜单","","", "120", 400, 210, 3, "", "");
	}
	ajax.regEvent("CNewTopMenuItemDlg");
	ajax.addParam("menuId",id);
	var r =  ajax.send();
	win.innerHTML = r;
	setTimeout("showSysUrl();",50);
}

function addnewTopItem(id) { //添加顶部菜单
    var urlbox = document.getElementById("topmenuitemurl");
    var url = urlbox.value;
    if (url.toLowerCase().replace("http://", "").replace("/", "").length == 0) 
    {
        app.Alert("请输入网址");
        urlbox.focus();
        urlbox.select();
        return false;  
    }
	ajax.regEvent("addnewTopItem");
	ajax.addParam("id",id);
	ajax.addParam("title",document.getElementById("topmenuitemtit").value);
	ajax.addParam("cls",document.getElementById("itemcls_id").value);
	ajax.addParam("stoped",document.getElementById("topmitemck2").checked?1:0);
	ajax.addParam("url", document.getElementById("topmenuitemurl").value);
	ajax.addParam("sort", document.getElementById("topmenuitemsort").value);
	if(document.getElementById("tmitemsall")){
		ajax.addParam("yyall",document.getElementById("tmitemsall").checked ? 1 : 0);
	}
	else{
		ajax.addParam("yyall","0");
	}
	var r = ajax.send();
	if(!isNaN(r)){ 
		lvw_refresh("topmenuitem");
		return true; 
	}
	else{ alert(r);}
}

function delTopItem(id){ //删除顶部导航菜单
	if(!window.confirm("确定要删除该导航吗？")){
		return false;
	}
	ajax.regEvent("delTopItem");
	ajax.addParam("id",id);
	var r = ajax.send();
	if(r=="1") {
		lvw_refresh("topmenuitem");
		return true;
	}
	else{
		alert(r);
		return false;
	}
} 

function delTopBarItem(id){ //删除顶部导航菜单
	if(!window.confirm("确定要删除该工具栏吗？")){
		return false;
	}
	ajax.regEvent("delTopBarItem");
	ajax.addParam("id",id);
	var r = ajax.send();
	if(r=="1") {
		lvw_refresh("topbaredit");
		return true;
	}
	else{
		alert(r);
		return false;
	}
} 


function addnewTopBarItem(id) { //添加顶部工具栏导航
    if (document.getElementById("topbaricosel").value == 0&&$("#imgbindata").val()=="") {  alert("您还没有上传图片！"); return; }
	ajax.regEvent("addnewTopBarItem");
	ajax.addParam("id", id);
	ajax.addParam("title",document.getElementById("topbaritemtit").value);
	ajax.addParam("ico",document.getElementById("topbaricosel").value);
	ajax.addParam("stoped",document.getElementById("topbaritemdisstop").checked ? 0 : 1);
	ajax.addParam("url",document.getElementById("topbaritemurl").value);
	ajax.addParam("umsg",document.getElementById("topbaritemmsg").value);
	ajax.addParam("sort", document.getElementById("topbaritemsort").value);
	ajax.addParam("imgbindata", document.getElementById("imgbindata").value);
	ajax.addParam("imgfilename", document.getElementById("imgfilename").value);
	var r = ajax.send();
	if(!isNaN(r)){ 
		lvw_refresh("topbaredit");
		return true; 
	}
	else{ alert(r);}
}

function edittopbarItem(id)
{
	if(id == 0) {
		var win =  app.createWindow("newcItemdlg","添加工具栏","","", "120", 400, 300, 1, "", "");
	}
	else{
		var win =  app.createWindow("newcItemdlg","修改工具栏","","", "120", 400, 300, 1, "", "");
	}
	ajax.regEvent("CNewTopBarItemDlg");
	ajax.addParam("Id",id);
	var r =  ajax.send();
	win.innerHTML = r;
	if ($("#topbaricosel").val() == 0) {
	    var picName = $("#imgfilename").val();
	    $("#uploadIcon").show(); $("a.delIcon").removeClass("disShow");
	    $("#fileName").text(picName);
	    $("#fileName").attr("title", picName);
	    $("#warmTips").show();
	}
}

function changeLeftNavUrl() {//设置顶部菜单时左侧导航切换到树结构
    var frmbody = top.window.document.getElementById("frmbody");
    if (!frmbody) { return; }
    var leftFrame = frmbody.contentWindow.document.getElementById("leftFrame");
    if(!leftFrame){return}
    var src = leftFrame.src;
    if (src.indexOf("/leftTreeNav.html") < 0) { leftFrame.src = "leftTreeNav.html" }
}

//设置是否启用字段
function src_fieldsClick(ckbox) {
	ckbox.parentNode.className = ckbox.checked ? "lvw_cell" : "lvw_cell disqy";
}

//修改检索模式
function UpdateSearchConfig(id,cmd,value){
	ajax.regEvent("UpdateSearchConfig");
	ajax.addParam("Id",id);
	ajax.addParam("cmd",cmd);
	ajax.addParam("value",value);
	var r =  ajax.send();
	if(r!="1"){
		alert(r);
	}
}

function topmUsered(utype, id )
{
	ajax.regEvent("setTopMenuUsered");
	ajax.addParam("uState",utype);
	ajax.addParam("id",id);
	var r =  ajax.send();
	if(r=="1"){
		lvw_refresh("topmenuitem");
		return true; 
	}
	else{
		alert(r)
		return false;
	}
}

function showSysUrl()
{
	var div = document.getElementById("sd0001");
	if(!div){
		div = document.createElement("div");
		div.id = "sd0001";
		div.className = "ShaDiv";
		document.body.appendChild(div);
	}
	div.style.display = "block";
	
	var div2 = top.document.getElementById("sd0002");
	if(!div2){
		div2 = top.document.createElement("div");
		div2.id = "sd0002";
		div2.className = "ShaDiv";
		div2.style.height = "100px";
		top.document.body.appendChild(div2);
	}
	div2.style.display = "block";

	var div3 = top.document.getElementById("sd0003");
	if(!div3){
		div3 = top.document.createElement("div");
		div3.id = "sd0003";
		div3.style.position = "absolute";
		div3.style.left = "0px"
		div3.style.width = "100%";
		div3.style.height = "50px";
		div3.style.top = "40px";
		div3.style.textAlign = "center";
		div3.innerHTML = "<span style='padding:10px;color:#fff;background-color:#556677;line-height:20px;'>提示您：可点击选中左侧导航菜单，作为顶部菜单收藏项。</span>";
		top.document.body.appendChild(div3);
	}
	div3.style.display = "block";

	var div4 = window.parent.document.getElementById("sd0004");
	if (!div4) {
	    div4 = document.createElement("div");
	    div4.id = "sd0004";
	    div4.className = "ShaDiv";
	    window.parent.document.body.appendChild(div4);
	}
	div4.style.display = "block";
	//收藏左侧菜单接口
	top.LeftMenuFun = function(title,url,otype) 
	{
		document.getElementById("topmenuitemurl").value = "sys:" + url;
		if(document.getElementById("topmenuitemurlhide"))
		{
			//如果没有则表示原本就是系统菜单
			document.getElementById("topmenuitemurl").style.display = "none";
			document.getElementById("topmenuitemurlhide").style.display = "inline";
		}
		document.getElementById("topmenuitemtit").value = title;
	}
}

//清除顶部遮盖层
window.onbeforeunload = function(){
	closeShardDiv();
}

//关闭拾选导航时产生的阴影
function closeShardDiv() {
    var div4 = window.parent.document.getElementById("sd0004");
	var div3 = top.document.getElementById("sd0003");
	var div2 = top.document.getElementById("sd0002");
	var div1 = document.getElementById("sd0001");
	if (div4) { div4.style.display = "none"; }
	if(div3) {div3.style.display = "none";}
	if(div2) {div2.style.display = "none";}
	if(div1) {div1.style.display = "none";}
	top.LeftMenuFun = null;
	if (top.LeftNavUrlChange) { top.LeftNavUrlChange() }
}

//加载
function doload(index)
{
    var fun = document.getElementById("fbutton" + (index + 1));
    if(!fun && index==0){
        fun = document.getElementById("fbutton2");
    }
    if (fun) {
        fun.click();
    }
}

//设置报表是否隐藏
function updateCardv(id, v) 
{
	ajax.regEvent("updateCard")
	ajax.addParam("cmdtype","visible")
	ajax.addParam("id",id)
	ajax.addParam("value",v)
	var r = ajax.send();
	if(r!="ok")
	{
		alert("设置失败",r);
	}
}

//设置报表的顺序
function UpdateCardSort(id, obj) 
{
	if(isNaN(obj.value) || obj.value == "") 
	{
		app.Alert("顺序必须是有效的数字");
		obj.select();
		return;
	}else if (parseInt(obj.value)>999)
	{
		app.Alert("顺序不能超过999");
		obj.select();
		return;
	}
	ajax.regEvent("updateCard")
	ajax.addParam("cmdtype","sort")
	ajax.addParam("id",id)
	ajax.addParam("value",obj.value)
	var r = ajax.send();
	if(r!="ok")
	{
		alert("设置失败",r);
	}
}

//设置列表的天数范围
function updatetxts(id, obj) {
	if(isNaN(obj.value) || obj.value == "") 
	{
		app.Alert("天数必须是有效的数字");
		obj.select();
		return;
	}else if (parseInt(obj.value)>365){
		app.Alert("天数必须是0到365的数字");
		obj.select();
		return;
	}
	ajax.regEvent("updateCard")
	ajax.addParam("cmdtype","tsfw")
	ajax.addParam("id",id)
	ajax.addParam("value",obj.value)
	var r = ajax.send();
	if(r!="ok")
	{
		alert("设置失败",r);
	}
}

//更新最大显示行
function UpdateCardRows(id, obj) 
{
	if(isNaN(obj.value) || obj.value == "") 
	{
		app.Alert("最大行数必须是有效的数字");
		obj.select();
		return;
	}else if (parseInt(obj.value)>100){
		app.Alert("最大行数必须是0到100的数字");
		obj.select();
		return;
	}
	ajax.regEvent("updateCard")
	ajax.addParam("cmdtype","maxrows")
	ajax.addParam("id",id)
	ajax.addParam("value",obj.value)
	var r = ajax.send();
	if(r!="ok")
	{
		alert("设置失败",r);
	}
}

//修改卡片存储过程权限判断依据
function updateCardfw(id, v)
{
	ajax.regEvent("updateCard")
	ajax.addParam("cmdtype","cardpower")
	ajax.addParam("id",id)
	ajax.addParam("value",v)
	var r = ajax.send();
	if(r!="ok")
	{
		alert("设置失败",r);
	}
}

//删除工具栏项目
function deltopbarItem(id)
{
	if(!window.confirm("确定要删除吗？"))
	{
		return false;
	}
	ajax.regEvent("delTopBarItem")
	ajax.addParam("id",id)
	var r = ajax.send();
	if(r!="1")
	{
		alert("删除失败",r);
	}
	else
	{
		lvw_refresh("topbaredit"); //刷新列表
	}
}

//设置工具栏的禁用状态，v=1表示禁用，v=0表示不禁用
function enabletopbarItem(id, v) 
{
	ajax.regEvent("enableTopBarItem")
	ajax.addParam("id",id)
	ajax.addParam("v",v)
	var r = ajax.send();
	if(r!="1")
	{
		alert("设置禁用状态失败",r);
	}
	else
	{
		lvw_refresh("topbaredit"); //刷新列表
	}
}

//设置报表的分类, rptID 报表ID
function UpdateRptCls(rptId) {
    var win = app.createWindow("setrptCls", "设置报表所属栏目", "", "", 120 + document.body.scrollTop + document.documentElement.scrollTop, 400, 170, 1, 1, "");
    ajax.regEvent("UpdateRptClsPage")
    ajax.addParam("ID", rptId)
    win.innerHTML = ajax.send();
}

function saveRptClsUpdate(id , ncls) {
    ajax.regEvent("UpdateRptClsSave")
    ajax.addParam("ID", id);
    ajax.addParam("cls", ncls);
    var r = ajax.send();
    if (r != "ok") {
        app.Alert(r);
    }
    else {
        app.closeWindow("setrptCls");
        app.Alert("保存成功");
        if (document.getElementById("lvw_cardsdata")) {lvw_refresh("cardsdata");}
		if (document.getElementById("lvw_cardrsdata")){lvw_refresh("cardrsdata");}
    }
}

//工具栏图标上传函数
function uploadPicInfo(ele) {
    //console.log(ele.value);
	$("#uploadicoform")[0].submit();
}
function delIcon(ele) {
	var isdel = confirm("确定删除吗？")
	if (isdel) {
	    $("#imgbindata").val("");
	    $("#imgfilename").val("");
	    $("#upLoaderBtn").val("");
	    $("#fileName").text("");
	    $("#fileName").attr("title", "");
	    $("#defineIconTxt").show();
	    $("a.delIcon").addClass("disShow");
		$("#topbarico").attr("src", "").hide();
	}

}

window.onUploadBase64Complete = function (fdata) {
    if (fdata.length == 0) { alert("请上传图标！") }
    var picName = fdata[0].FileName; var pic, picArr;
    if (picName) {
        var picFormat = ["gif", "png", "jpg"]
        picArr = picName.split(".")
        pic = picArr[picArr.length - 1];
        if (pic && picFormat.indexOf(pic) < 0) { $("#upLoaderBtn").val(""); app.showMsg("此处不支持" + pic + "格式的图片"); return; }
    }
    if (!fdata[0].FileSize) { return; }
    var fileSize = fdata[0].FileSize / 1024;
    if (fileSize > 2) { $("#upLoaderBtn").val(""); app.showMsg("文件太大，超过了2KB!"); return; }
    var FileData=fdata[0].FileData;
    if (FileData) {
        $("#imgbindata").val(FileData);
        $("#imgfilename").val(picName);
        $("#fileName").text(picName);
        $("#fileName").attr("title", picName);
        $("a.delIcon").removeClass("disShow");
        $("#defineIconTxt").hide();
        //ie89下图片地址处理
        if (app.getIEVer() < 9) { $("#topbarico").attr("src", fdata[0].FilePathIE).show(); } else {
            $("#topbarico").attr("src", 'data:image/' + pic + ';base64,' + FileData).show();
        }
    }
}

function change(info) {
    var selected = document.getElementById("topbaricosel");
    var o = document.getElementById("topbarico");
    var noUploader = document.getElementById("defineIconTxt");
    var uploadIcon = document.getElementById("uploadIcon");
    var warmTips = document.getElementById("warmTips");
    var imgName = $("#imgfilename").val();
    var imgData=$("#imgbindata").val();
    if (selected.value == 0) {
        var imgNameArr = imgName.split(".")
        if (imgNameArr.length > 1) {
            var extendtion = imgNameArr[imgNameArr.length - 1]
            //ie89下图片地址处理
            if (app.getIEVer < 9) { o.src = 'data:image/' + extendtion + ';base64,' + imgData; } else {
                o.src = 'data:image/' + extendtion + ';base64,' + imgData;
            }
            $("#fileName").text(imgName).show();
            if (imgData) { o.style.display = ""; noUploader.style.display = "none"; $("a.delIcon").removeClass("disShow"); } else { o.style.display = "none"; noUploader.style.display = ""; }
        } else {
            o.style.display = "none"; noUploader.style.display = "";
        }
        uploadIcon.style.display = "";
        warmTips.style.display = "";
        return;
    }
    if (selected.value != 0) {
        if (window.top.SysConfig.SystemType == 3) {//信湖系统
            o.src = "../../skin/" + info + "/images/MoZihometop/home/" + selected.value;
        } else {
            o.src = "../../skin/" + info + "/images/toolbar/" + selected.value;
        }
        noUploader.style.display = "none";
        uploadIcon.style.display = "none";
        o.style.display = "";
        warmTips.style.display = "none";
    }
   
}