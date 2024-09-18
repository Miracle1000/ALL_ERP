// JavaScript Document
function change1(a,b)
{
	if(eval(a).runtimeStyle.display=='')
	{
		eval(a).runtimeStyle.display='none';
		eval(b).className='menu3';
	}
	else
	{
		eval(a).runtimeStyle.display='';
		eval(b).className='menu4';
	}
}
function change2(a,b)
{
	if(eval(a).runtimeStyle.display=='')
	{
		eval(a).runtimeStyle.display='none';
		eval(b).className='menu1';
	}
	else
	{
		eval(a).runtimeStyle.display='';
		eval(b).className='menu2';
	}
}
function changeleft1(a,b)
{
	if($(a).style.display=='')
	{
		$(a).style.display='none';
		$(b).className='nav_left1';
	}
	else
	{
		$(a).style.display='';
		$(b).className='nav_left2';
	}
}



//left tab change
function selectTag(showContent,selfObj){
	// change tab
	var tag = $("leftmenu").getElementsByTagName("a");
	var taglength = tag.length;
	for(var i=0; i<taglength; i++){
		tag[i].className = "";
	}
	selfObj.className = "up";
	// change content
	for(var i=1;i<4;i++){
		$("leftmenu"+i).style.display = "none";
	}
	$(showContent).style.display = "block";	
}

function scrollImg(){
    var posY;
    if (window.innerHeight) {
        posY = window.pageYOffset;
    }
else if (document.documentElement && document.documentElement.scrollTop) {
posY = document.documentElement.scrollTop;
}
else if (document.body) {
posY = document.body.scrollTop;
    }
var ad=document.getElementById("btn_sh");
    ad.style.top=(posY+20)+"px";
    setTimeout("scrollImg()",50);
}

window.onload=function()
{
scrollImg();
for(var ii=0; ii<document.links.length; ii++)
document.links[ii].onfocus=function(){this.blur()}
}
function fHideFocus(tName){
aTag=document.getElementsByTagName(tName);
for(i=0;i<aTag.length;i++)aTag[i].hideFocus=true;
}
