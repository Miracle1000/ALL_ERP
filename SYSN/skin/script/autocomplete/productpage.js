window.onTreeViewNodeClick = function (eobj) {
	setTimeout(CSetProcuctClass,100);
}

function CSetProcuctClass() {
	var nodes = window.TreeView.GetCheckedNodes(window.TreeView.objects[0]);
	var cks = [];
	for (var i=0; i<nodes.length ; i++)
	{
		cks[i] = nodes[i].id;
	}
	$ID("productsorts").value = cks.join(",");
	Report.SetSearchData(0); 
    Report.ReportSubmit();
}