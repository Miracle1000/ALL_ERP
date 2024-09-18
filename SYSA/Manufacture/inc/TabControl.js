var Tabs = {
	ITEMClick : function(item) {
		var  tr = item.parentElement;
		for (var i = 0;i< tr.cells.length; i++ )
		{
			var cell = tr.cells[i];
			if(cell.className.toLowerCase()=="sstabitem_select"){
				if(cell==item){return ;}
				else{ 
					cell.className = "ssTabItem";
					cell.style.zIndex = cell.style.zIndex - 100
					break ;
				}
			}
		}
		item.className = "ssTabItem_select";
		item.style.zIndex = item.style.zIndex + 100
		if (Tabs.ItemClick){Tabs.ItemClick(item.cellIndex,item.parentElement.parentElement.parentElement.id.replace("TabCtl_",""),item.tag)}
	}
	,
	itemover : function (obj,color){
		//obj.style.textDecoration = "underline";
		if(color){
			obj.style.color = color;
		}
	}
	,
	itemout : function (obj,color){
		//obj.style.textDecoration = "none";
		if(color){
			obj.style.color = color;
		}
	}
	,
	itembgover : function (obj,color){}
	,
	itembgout : function (obj,color){}
}
var tabs = Tabs;