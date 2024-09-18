var sc = 1
function expTree(obj) {	
	if(obj.innerText=="全部收缩") 
	{
		obj.innerText="全部展开"
		sc = 0;
	}
	else{
		sc = 1;
		obj.innerText="全部收缩"
	}
	doSearch();
}

function keyTextFocus(obj) {
	if(obj.value=="输入按回车检索") 
	{
		obj.value = "";
	}
}

function keyTextBlur(obj) {
	if(obj.value.replace(/\s/,"").length=="") 
	{
		obj.style.color="#999999"
		obj.value = "输入按回车检索";
	}
	else{

		obj.style.color="#000"
	}
}

function keyTextKeyUp(obj) {
	if(obj.value.replace(/\s/,"").length==0) 
	{
		obj.style.color="#999999";
	}
	else{
		obj.style.color="#000000";
	}
	//doSearch();
}

function doSearch()
{
	tvw.callback("Storetree",beforeSearch,"");
}

function beforeSearch(){
	var t = document.getElementById("txtKeywords").value;
	ajax.addParam("explan",sc==1?1:0);
	ajax.addParam("unit",document.getElementById("unit").value);
	ajax.addParam("pid",document.getElementById("pid").value);
	ajax.addParam("setmodel",document.getElementById("setmodel").value);
	ajax.addParam("currvalue",document.getElementById("currvalue").value);
	ajax.addParam("extvalue",document.getElementById("extvalue").value);
	ajax.addParam("keytext", t=="输入按回车检索" ? "":t);
}

function __on_sys_tvw_beforePageStatus(){;
	ajax.addParam("setmodel",document.getElementById("setmodel").value);
	ajax.addParam("currvalue",document.getElementById("currvalue").value);
	ajax.addParam("extvalue",document.getElementById("extvalue").value);
}

function showAllStore(){
	var obj = document.getElementById("txtKeywords")
	obj.value="输入按回车检索";
	obj.style.color="#999999";
	doSearch();
}

function selectStore(storeId, storeName)
{
	var txobj = parent.document.getElementsByName("ShowStore_"+document.getElementById("fixName").value)[0];
	var vobj = parent.document.getElementsByName("MainStore_"+document.getElementById("fixName").value)[0];
	if(txobj && vobj)
	{
		txobj.value = storeName;
		vobj.value = storeId;
	}
	if(window.parent.currStore)
	{
		window.parent.currStore.text = storeName;
		window.parent.currStore.value = storeId;
		window.parent.currStore.change();
	}
	if(parent.adClose) {
		parent.adClose();
	}
}

tvw.onitemclick = function(a) {
	if(a.value.length>0)
	{
		//setmode=1 则按仓库分类显示，会显示已停用的库存， 否则按仓库显示，不会显示空分类
		if(document.getElementById("setmodel").value*1!=1 || document.getElementById("fixName").value.length > 0) 
		{
			selectStore(a.value,a.text);
		}
		else
		{
			window.parent.showCK(a.value);
		}
	}
}

function clearTopKeybox(){
	var box = parent.document.getElementById("txtKeywords");
	if(box) 
	{
		box.value = "输入按回车检索";
		box.style.color = "#999999";
	}
}