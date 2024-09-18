window.onDisplayListViewCell = function (lvw, header, rowindex, cellindex) {
	return;
	if(rowindex>=0){
		header.max = lvw.rows[rowindex][cellindex];
		header.min = 0;
	}
}

window.onListViewRowAfterDelete = function (lvw, pos) {
    $('#money1_0').blur(); $('#money1_0').change();
}
