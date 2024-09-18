function bntClick(obj,typ){
	if (typ==1){
		var lvw = new Listview("zttj");
		lvw.beginCallBack("zttj");
		lvw.addParam("date1", $("#date1_v_0").val());	
		lvw.addParam("date2", $("#date1_v_1").val());	
		lvw.exec();
		bill.showVmlImage("pghz" , "pghz", "zttj");
	}
	else if (typ ==2)
	{
		var lvw = new Listview("tjlist");
		lvw.beginCallBack("tjlist");
		lvw.addParam("date1", $("#date2_v_0").val());	
		lvw.addParam("date2", $("#date2_v_1").val());	
		lvw.addParam("gx", $("#gx").val());	
		lvw.addParam("B", $("#B").val());	
		lvw.addParam("C", $("#C").val());
		lvw.exec();
	}
}

bill.onPageLoad = function(){
	bill.showVmlImage("pghz" , "pghz", "zttj");
}