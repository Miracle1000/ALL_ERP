function CostShareMoney(lvwName, rowindex, cellindex) {
	var uPrice = 0;//成本单价
	var uSum = $("div[dbname=Money1]").find("span.billfieldreadonlymodecont").eq(0).text().replace(/\,/g,"")*1;
    var lvw = window["lvw_JsonData_" + lvwName];// 'ShareParts'
    var hd = lvw.headers;
    var rows = lvw.rows;
    var h_allsel = -1;
    var h_num1 = -1;
    for(var i=0;i<hd.length;i++){
    	if(hd[i].dbname =="@allselectcol"){ h_allsel = i; }
    	if(hd[i].dbname =="num1"){ h_num1 = i; }
    }
    var selrows = [];
    var count = 0;
    var Money1 = 0;
    if(lvw.rows[rowindex][h_allsel] == 0){ return Money1.toFixed(window.SysConfig.MoneyBit); }
    for(var i=0;i<rows.length;i++){ if(rows[i][h_allsel] == 1){ selrows.push(i);}}
    for(var i=0;i<selrows.length;i++){ count+=rows[selrows[i]][h_num1];}
    if(count > 0){
    	if(rowindex == selrows[selrows.length-1]){
	    	var subsum = 0;
	    	for(var i=0;i<selrows.length-1;i++){
	    		subsum+=(uSum/count*lvw.rows[selrows[i]][h_num1]).toFixed(window.SysConfig.MoneyBit)*1;
	    	}
	    	Money1 = (uSum - subsum).toFixed(window.SysConfig.MoneyBit);
	    }else{
	    	Money1 = (uSum/count * lvw.rows[rowindex][h_num1]).toFixed(window.SysConfig.MoneyBit);
	    }
	    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], cellindex, 0, Money1, "");
    }
    return Money1;
}


var num1 = 0;
window.setInterval(function () {
  try {
      if ($ID("num1_0").value!=num1) {
          num1 = $ID("num1_0").value;
          ___RefreshListViewByJson(window["lvw_JsonData_ShareParts"]); 
      }
  } catch (e) { }
}, 100);