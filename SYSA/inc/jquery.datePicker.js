$.fn.datePicker = function(obj){
	var selbox = this;
	if(obj && obj.startDate){
		$(selbox).attr("minDate",  obj.startDate );
	} else {
		$(selbox).attr("minDate",  "1980-1-1" );
	}
	var button = $('<a href="javascript:void(0);" minDate="' +  (obj.startDate || "1980-1-1") + '" class="dp-choose-date" title="选择日期"><img minDate="' +  (obj.startDate || "1980-1-1") + '" src='+window.sysCurrPath+'images/button_buy02.gif border=0  align=absmiddle></a>');
	$(selbox).after(button);
	button.bind( 'click', function() { datedlg.show(selbox[0],window.event); } );
	$(selbox).bind("click", function(){ datedlg.show(selbox[0],window.event); });
}