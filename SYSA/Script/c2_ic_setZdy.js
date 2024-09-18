
swpCss=function(obj){obj.className=obj.className.indexOf("_over")>0?obj.className.replace("_over",""):obj.className+"_over";}		
__tabClick=function(id,srcTag,index){
	var pobj=srcTag.parentNode.parentNode;
	var iheight=pobj.getAttribute("itemheight");
	var c=pobj.getAttribute("count");
	if(srcTag.className.indexOf("sel")<0)
	{
		srcTag.className="tabstrip_item_sel_over";
		srcTag.style.height=(iheight*1+2)+"px";
		//switch(index){
			//case 4:
			//document.getElementById("S9").src="../sort5/edit2.asp?listhead=0";break
			//case 6:
			//document.getElementById("S9").src="../sort5/edit2.asp?listhead=0";break
			//case 7:
			//document.getElementById("S9").src="../sortClass/setcl.asp?sort=2&title_display=0";break
			//case 8: 
				//document.getElementById("S9").src="tb7.asp?listhead=0";break;
			//default:
			//document.getElementById("S9").src="tb"+index+".asp?listhead=0";break;
		//}
		document.getElementById("S9").src="setZdyField.asp?listhead=0&top=" + index
	}
	for(var i=0;i<c;i++)
	{
		var item=$ID("TBSr_"+id+"_"+(i+1));
		if(item && item.id!=srcTag.id&&item.className.indexOf("sel")>0)
		{
			item.className="tabstrip_item";
			item.style.height=iheight+"px";
		}
	}
}
document.onkeydown=function(e){ 
	//if(event.ctrlKey&&event.altKey){ location.href='set_khcl_old.asp'; }
}
