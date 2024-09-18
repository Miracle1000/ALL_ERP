var me = new Object();
me.ckCount = 0;
me.http = Bill.ScriptHttp();

lvw.oldupdateRowByInput = lvw.updateRowByInput
lvw.updateRowByInput = function (input) {

	if(input.className=="ctllvwCurrInput"){
		lvw.oldupdateRowByInput(input);
		if(window.event && 	window.event.type == "click") {
			return;
		}
		var td = getParent(input,5);
		var tr = td.parentElement;
		var cindex = lvw.cellIndex(td);
		var c2 = lvw.getCellIndexByName("",tr,"辅助单位")
		if(cindex ==c2 || cindex == c2-2){
			me.getnewUnitNum(tr);
			if (cindex ==c2-2 )
			{
				me.RefreshMaterials(tr)  //刷新物料耗材 , 此处废弃不用
			}
		}
		
	}
}

me.RefreshMaterials = function(tr){
	var i1 =  lvw.getCellIndexByName("",tr,"molist");
	var i2 =  lvw.getCellIndexByName("",tr,"委外数量");
	var molist = lvw.getCellValue(tr.cells[i1])
	var num = lvw.getCellValue(tr.cells[i2])
	var div = lvw.items(1);
	if (div)
	{
		var i1 =  lvw.getCellIndexByName(div.children[0],null,"molist");
		var i2 =  lvw.getCellIndexByName(div.children[0],null,"实际耗材");
		var i3 =  lvw.getCellIndexByName(div.children[0],null,"单件耗材");
		var i4=  lvw.getCellIndexByName(div.children[0],null,"预算耗材");
		for (var i = 0; i< div.hdataArray.length ;i++)
		{
			if(div.hdataArray[i][i1]==molist){
				div.hdataArray[i][i2] = Math.fnum(num*div.hdataArray[i][i3]);
				div.hdataArray[i][i4] = Math.fnum(num*div.hdataArray[i][i3]) 
			}
		}
		lvw.Refresh(div);
	}
	
}

me.getnewUnitNum = function(tr){ //重新获取辅助单位比例
	var rDat = lvw.getDataRowDataByTR(tr)
	var ix = lvw.getCellIndexByName("",tr,"辅助单位")
	var v1 = lvw.getcelldata(tr.cells[lvw.getCellIndexByName("",tr,"产品id")]);
	var v2 = lvw.getcelldata(tr.cells[lvw.getCellIndexByName("",tr,"单位ID")]);
	var v3 = lvw.getcelldata(tr.cells[ix]);
	var v4 = lvw.getcelldata(tr.cells[lvw.getCellIndexByName("",tr,"委外数量")]);
	me.http.regEvent("B25_GetUnitBl"); 
	me.http.addParam("productid",v1)
	me.http.addParam("unit1",v2)
	me.http.addParam("unit2",v3)
	var r = me.http.send();
	var td = tr.cells[ix*1 + 1]
	var n = isNaN(r) ? "" : Math.fnum(r*v4)
	lvw.updateDataCell(td, n == 0 ? "" : n)
	lvw.RefreshRow(tr);
}
lvw.GetSaveDetailDataHook = function(rows,divID){
	//alert(divID + "\n\n\n" + rows)
	if(divID=="listview_71"){
		for (var i = 0; i < rows.length ; i++ )
		{
			
			var cells = rows[i].split("#oc");
			if(isNaN(cells[5]) || cells[5].length==0 ){cells[5]="0"}  //辅助单位为空则转为0
			if(isNaN(cells[6]) || cells[6].length==0 ){cells[6]="0"}  //辅助数量为空则转为0
			rows[i] = cells.join("#oc");

		}
	}
	return rows.join("#or");
}