
var g_title,g_tb;
var currentResizeTdObj=null;
function MouseDownToResize(event,obj){
obj=obj||this;
event=event||window.event;
currentResizeTdObj=obj;
obj.mouseDownX=event.clientX;
obj.mouseDownY=event.clientY;
obj.tdW=obj.offsetWidth;
obj.tdH=obj.offsetHeight;
if(obj.setCapture) obj.setCapture();
else event.preventDefault();
}
function MouseMoveToResize(event){
if(!currentResizeTdObj) return ;
var obj=currentResizeTdObj;
event=event||window.event;
    if(!obj.mouseDownX) return false;
    if(obj.parentNode.rowIndex==0) {
      var newWidth=obj.tdW*1+event.clientX*1-obj.mouseDownX;
      if(newWidth>0)
	  {
	   obj.style.width = newWidth;
		//alert(event.srcElement.indexCell);
	   }
    else obj.style.width =1;
}
/*
if(obj.cellIndex==0){
      var newHeight=obj.tdH*1+event.clientY*1-obj.mouseDownY;
      if(newHeight>0) obj.style.height = newHeight;
    else obj.style.height =1;
}
*/
}
function MouseUpToResize(){
if(!currentResizeTdObj) return;
if (currentResizeTdObj.releaseCapture)
{
	currentResizeTdObj.releaseCapture();
	var trobj=currentResizeTdObj.parentElement;
	var cookieWidth="";
	for(var tri=0;tri<trobj.cells.length;tri++)
	{
		cookieWidth+=cookieWidth==""?trobj.cells[tri].offsetWidth:","+trobj.cells[tri].offsetWidth;
	}
}
currentResizeTdObj=null;
}

//改变表格行列宽函数
function ResizeTable_Init(table,needChangeWidth,needChangeHeight)
{
if(!needChangeWidth && !needChangeHeight)
   return;
var oTh=table.rows[0];
if(needChangeWidth){
    for(var i=0;i<oTh.cells.length;i++)   {
       var cell=oTh.cells[i];
       cell.style.cursor="e-resize";
       cell.style.width=cell.offsetWidth;
       cell.onmousedown =MouseDownToResize;
    }
}
/*
if(needChangeHeight){
    for(var j=0;j<table.rows.length;j++)   {
       var cell=table.rows[j].cells[0];
       cell.style.cursor="s-resize";
       cell.onmousedown =MouseDownToResize;
    }
}
if(needChangeWidth && needChangeHeight)
   oTh.cells[0].style.cursor="se-resize";
*/
table.style.width=null;
table.style.tableLayout="fixed";
}
function setLeftBanner()
{
	var aa=document.getElementById('cldiv');
	var bb=document.getElementById('setdiv');
	var td=document.getElementById('left_td');
	if (bb.style.display=="none")
	{
		aa.innerHTML = '<img class="resetElementHidden" src="../images/left-ban1.gif" onClick="setLeftBanner()" /><img class="resetElementShowNoAlign" style="display:none;" src="../skin/default/images/MoZihometop/content/btn_left.png" onClick="setLeftBanner()" />'
		bb.style.display='block'
		td.style.width='170';
	}
	else
	{
		aa.innerHTML= '<img class="resetElementHidden" src="../images/left-ban.gif" onClick="setLeftBanner()" /><img class="resetElementShowNoAlign" style="display:none;" src="../skin/default/images/MoZihometop/content/btn_right.png" onClick="setLeftBanner()" />'
		bb.style.display='none'
		td.style.width='0';
	}
}
