window.bill_onLoad = function(){
	var v = Bill.getinputbyywname("工艺流程ID").value
	if(!isNaN(v) && v>0){
		Bill.RefreshDetail(true)
	}
}