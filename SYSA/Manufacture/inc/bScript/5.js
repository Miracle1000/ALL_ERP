window.importHandler = function(oid,bid){
	var url = "../../load/newload/MultiBomImport.asp";
	var drtitle = "物料清单批量导入";
	var div = window.DivOpen("excelindlg",drtitle,650,370,120,'a',true,15,1);
	div.innerHTML = "<iframe src='" + url + "' style='width:100%;height:100%' frameborder=0></iframe>"
	var czButton = window.getParent(div,4).rows[0].cells[1].all[0];
	parent.sys_doxlsdrSendSign = 0;
	czButton.afterclick = function(){
		if(parent.sys_doxlsdrSendSign==1){
			window.location.href = 	"../inc/Billlist.asp?orderid="+oid;
		}
	}
}

Bill.onsave = function(){
	var ChangeModel = document.getElementById("Bill_Info_ChangeModel").value;
	var MBOMPlan = "" ;
	$("input[name='bill_gl_id']:checked").each(function(){ 
		MBOMPlan += (MBOMPlan.length>0?"," :"") + $(this).val() ;
	}); 
	ajax.addParam("MBOMPlan", MBOMPlan);
}