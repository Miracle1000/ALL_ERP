var pic = new Image();
pic.src="../skin/"+window.infoSkin+"/images/btn_right.gif";

function toggleMenu()
{
  frmBody = parent.document.getElementById('frame-body');
  imgArrow = $ID('img');
  var leftmenu = frmBody.rows[0].cells[0];
  if (leftmenu.offsetWidth==0)
  {
    leftmenu.style.width = "209px";
    imgArrow.src="../skin/"+window.infoSkin+"/images/btn_left.gif";
  }
  else
  {
    leftmenu.style.width = "0px";
    imgArrow.src="../skin/"+window.infoSkin+"/images/btn_right.gif";
  }
}

top.CHiddenLeftMenu = function(){
	var frmBody = parent.document.getElementById('frame-body');
	 var leftmenu = frmBody.rows[0].cells[0];
	 if (leftmenu.offsetWidth>0){
		leftmenu.style.width = "0px";
		$ID('img').src="../skin/"+window.infoSkin+"/images/btn_right.gif";
	 }
}

top.CShowLeftMenu = function(){
	var frmBody = parent.document.getElementById('frame-body');
	 var leftmenu = frmBody.rows[0].cells[0];
	 if (leftmenu.offsetWidth==0){
		leftmenu.style.width = "209px";
		$ID('img').src="../skin/"+window.infoSkin+"/images/btn_left.gif";
	 }
}

var orgX = 0;
document.onmousedown = function(e)
{
}

document.onmouseup = function(e)
{
}

var Browser = new Object();

Browser.isMozilla = (typeof document.implementation != 'undefined') && (typeof document.implementation.createDocument != 'undefined') && (typeof HTMLDocument != 'undefined');
Browser.isIE = window.ActiveXObject ? true : false;
Browser.isFirefox = (navigator.userAgent.toLowerCase().indexOf("firefox") != - 1);
Browser.isSafari = (navigator.userAgent.toLowerCase().indexOf("safari") != - 1);
Browser.isOpera = (navigator.userAgent.toLowerCase().indexOf("opera") != - 1);

var Utils = new Object();

Utils.fixEvent = function(e)
{
  var evt = (typeof e == "undefined") ? window.event : e;
  return evt;
}

function onresizeEnd(){
}

window.ShowChildrenMenu = function(title, treehtml){
	var td = $ID("childmenubody");
	parent.currChildMenuDataTitle = title;
	parent.currChildMenuTreeHtml = treehtml;
	if(title=="") {
			td.style.display = "none";
			td.parentNode.parentNode.parentNode.style.width = "5px"
			return;
	} else {
			try{td.style.display = window.ActiveXObject?"inline":"table-cell";} catch(e){ td.style.display = "inline";}
			td.parentNode.parentNode.parentNode.style.width = "100%";
			$ID("treebody_bg").style.overflowX = "hidden";
			$ID("treebody_bg").style.position = "relative";
	}
	$ID("currtitle").innerHTML =  title;
	var treebox  = $ID("treebody_bg").children[0];
	treebox.innerHTML = treehtml;
	var treebg = treebox.children[0];
	var id = treebg.id.replace("_bg","");
	var ids = id.split("_");
	treebox.id = ids[0] + "_" + ids[1];
	var json = treebg.getAttribute("datajosn");
	var jobj = eval("(" + json + ")");
	var fdeep = jobj[0].deep;
	var deepstr = new RegExp(",deep:\"" + fdeep,'gm');
	var deepstr2 = new RegExp(",deep:'" + fdeep,'gm');
	json = json.replace(deepstr, ",deep:\"0").replace(deepstr2,",deep:'0");
	treebg.setAttribute("datajosn", json);
	__tvw_execDataJosn(treebg);
	treebg.style.display="block";
	autosizetreediv();
};

function autosizetreediv(){
		$ID("treebody_bg").style.height = ($(window).height() - 45) + "px";
};
$(function(){
	if(	parent.currChildMenuDataTitle && parent.currChildMenuDataTitle.length>0) {
			window.ShowChildrenMenu(parent.currChildMenuDataTitle,  parent.currChildMenuTreeHtml);
	}
	$(window).resize(function(){ autosizetreediv(); });
});
