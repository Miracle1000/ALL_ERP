function resize(){
	$("#allMenu").css({ height: $(window).height() - $("#allMenu")[0].getBoundingClientRect().top });
}

function frameResize(){
	document.getElementById("cFF").style.height=I1.document.body.scrollHeight+0+"px";
}
var sc = 1
function expTree(obj) {
	if(obj.innerText.replace(/ /g,'')=="全部收缩") 
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
	tvw.callback("Menutree",beforeSearch,"");
}

function beforeSearch(){
	var t = document.getElementById("txtKeywords").value;
	ajax.addParam("explan",sc==1?1:0);
	ajax.addParam("keytext", t=="输入按回车检索" ? "":t);
}

//function __on_sys_tvw_beforePageStatus(){;
	//ajax.addParam("setmodel",document.getElementById("setmodel").value);
	//ajax.addParam("currvalue",document.getElementById("currvalue").value);
	//ajax.addParam("extvalue",document.getElementById("extvalue").value);
//}

function showAllStore(){
	var obj = document.getElementById("txtKeywords")
	obj.value="输入按回车检索";
	obj.style.color="#999999";
	doSearch();
}

tvw.onitemclick = function(a) {
	if(a.value.length>0)
	{
		window.location.href = "result3.asp?productmenu=" + a.value + "&clo=35";
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