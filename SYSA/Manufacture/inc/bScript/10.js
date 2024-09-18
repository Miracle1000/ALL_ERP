lvw.oldformulaApply = lvw.formulaApply;
lvw.formulaApply = function(tb,tr){
	lvw.oldformulaApply(tb,tr);
	getWHours(tb.parentElement);
}

lvw.onGetSaveData = function(div){
	getWHours(div);
}

lvw.ondeleteRow = function (div) {
    getWHours(div);
}

function getWHours(div){
	if(div.id!="listview_71"){return;}
	var hdat = div.hdataArray;
	var hours = new Array()
	for (var i=0;i < hdat.length ; i ++)
	{
		var hs = false
		var w = getWfTime(hdat[i])
		for (var ii = 0 ; ii <  hours.length ; ii++ )
		{
			if(hours[ii][0]==hdat[i][2]){ //如果次序号相同，存大的
				if(hours[ii][1]-w<0)
				{
					hours[ii][1]=w
				}
				hs = true
			}
		}
		if(hs==false){
			hours[hours.length] = new  Array()
			hours[hours.length-1][0] = hdat[i][2]
			hours[hours.length-1][1] = w
		}
	}
	var w = 0
	for (var i=0;i< hours.length; i++)
	{
		w = w  + hours[i][1]*1;
	}
	Bill.getinputbyywname("流程工时").value =w.toFixed(4);
}

var __everydayval = 0;
function getWfTime(hdataItem){
	var w =  hdataItem[9]
	var wNum  = 0
	if(__everydayval==0) {
		var http = Bill.ScriptHttp();
		http.regEvent("GetEverydayval");
		var r = http.send();
		if(r=="" || r==0 || isNaN(r)) {
			r = 24;
		}
		__everydayval = parseInt(r);
	}
	if (w.indexOf("天")>0)
	{
		wNum = w.replace("天","")*1*__everydayval;
	}
	else if(w.indexOf("小时")>0)
	{
		wNum = w.replace("小时","")*1
	}
	else if(w.indexOf("分钟")>0)
	{
		wNum = w.replace("分钟","")/60
	}
	else if(w.indexOf("秒")>0)
	{
		wNum = w.replace("秒","")/3600
	}
	else{
		if(isNaN(w)==false) {
			wNum = w;
		}
	}
	wNum =  isNaN(wNum) ? 0 : wNum 
	wNum = (isNaN(hdataItem[7]) || hdataItem[7]==0) ? 0 : (wNum / (isNaN(hdataItem[7]) ? 1 : hdataItem[7]) + hdataItem[8]*1 + hdataItem[10]*1)
	wNum = isNaN(wNum) ? 0 : wNum
	return wNum.toFixed(4) // hdataItem[7]
}