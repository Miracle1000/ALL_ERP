//类：执行状态
//by:snihaps 
//time:2011-12-12

var process={

		/*弹出执行状态框*/
		showProcessDiv:function(orderID,billID,pxID,dbItem)
		{
			//var parentDiv=window.DivOpen("processStatus" ,"执行状态", 600,450,"dd","dd",false,2);
			ajax.regEvent("showProcessStatus");
			ajax.addParam("orderID",orderID);
			ajax.addParam("billID",billID);
			ajax.addParam("pxID",pxID);
			ajax.addParam("dbItem",dbItem);
			alert(ajax.send());
			window.location.reload();
		//	parentDiv.innerHTML=ajax.send();
		}
};