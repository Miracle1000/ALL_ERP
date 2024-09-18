var me = new Object();
me.ckCount = 0;
me.http = Bill.ScriptHttp();
function loadHandles(oid_bid) {
	me.http.url = "../../sale/sale_handle.asp";
	me.http.regEvent("");
	me.http.addParam("oid",oid_bid.split("__")[0]);
	me.http.addParam("bid",oid_bid.split("__")[1]);
	var r = me.http.send()
	document.getElementById("handlesarea").innerHTML=r;
}