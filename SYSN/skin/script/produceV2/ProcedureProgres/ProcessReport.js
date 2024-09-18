 window.OnListViewInsertNewRow = function (jlvw, rowindex, srcfrom) {
	var posi = rowindex - 1;
	if (posi < 0) { return;}
	var OriIndex=-1;
	for (var i = 0; i < jlvw.headers.length; i++) {
		if(jlvw.headers[i].dbname=="OriSeralNumber" ){
		  if(jlvw.headers[i].visible)
		    OriIndex=i;
			break;
		}
	}
	//只有序列号模式下才显示
	if(OriIndex>0)
	{
		if(jlvw.headers[OriIndex].visible)
		{
		 for (var i = 0; i < jlvw.headers.length; i++) { 
				switch (jlvw.headers[i].dbname.toLowerCase()) {
			case "cateid":
			case "wtime":
				jlvw.rows[rowindex][i] = jlvw.rows[posi][i];
			default:
				break;
		}
	}
		}
	}
}
