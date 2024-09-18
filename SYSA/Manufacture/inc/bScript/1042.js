window.bill_onLoad = function()
{
	if (document.getElementsByName("MT6")[0])
	{
		document.getElementsByName("MT6")[0].onpropertychange = function()
		{
			if(window.event.propertyName=="value") {
				http = Bill.ScriptHttp();
				http.regEvent("Get_HrmContractDate");
				http.addParam("ord",document.getElementsByName("MT6")[0].value);
				r = http.send();
				if (r!="0")
				{
					document.getElementsByName("MT7")[0].value=r.split(",")[0];
					document.getElementsByName("MT8")[0].value=r.split(",")[1];
				}			
			}
		}
	}
}