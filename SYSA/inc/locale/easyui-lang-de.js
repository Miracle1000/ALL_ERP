﻿if ($.fn.pagination){
	$.fn.pagination.defaults.beforePageText = 'Seite';
	$.fn.pagination.defaults.afterPageText = 'von {pages}';
	$.fn.pagination.defaults.displayMsg = '{from} bis {to} von {total} Datens盲tzen';
}
if ($.fn.datagrid){
	$.fn.datagrid.defaults.loadMsg = 'Verarbeitung l盲uft, bitte warten ...';
}
if ($.fn.treegrid && $.fn.datagrid){
	$.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
	$.messager.defaults.ok = 'OK';
	$.messager.defaults.cancel = 'Abbruch';
}
if ($.fn.validatebox){
	$.fn.validatebox.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
	$.fn.validatebox.defaults.rules.email.message = 'Bitte geben Sie eine g眉ltige E-Mail-Adresse ein.';
	$.fn.validatebox.defaults.rules.url.message = 'Bitte geben Sie eine g眉ltige URL ein.';
	$.fn.validatebox.defaults.rules.length.message = 'Bitte geben Sie einen Wert zwischen {0} und {1} ein.';
}
if ($.fn.numberbox){
	$.fn.numberbox.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
}
if ($.fn.combobox){
	$.fn.combobox.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
}
if ($.fn.combotree){
	$.fn.combotree.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
}
if ($.fn.combogrid){
	$.fn.combogrid.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
}
if ($.fn.calendar){
	$.fn.calendar.defaults.firstDay = 1;
	$.fn.calendar.defaults.weeks  = ['S','M','T','W','T','F','S'];
	$.fn.calendar.defaults.months = ['Jan', 'Feb', 'M盲r', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
}
if ($.fn.datebox){
	$.fn.datebox.defaults.currentText = 'Heute';
	$.fn.datebox.defaults.closeText = 'Schlie脽en';
	$.fn.datebox.defaults.okText = 'OK';
	$.fn.datebox.defaults.missingMessage = 'Dieses Feld ist obligatorisch.';
	$.fn.datebox.defaults.formatter = function(date){
		var y = date.getFullYear();
		var m = date.getMonth()+1;
		var d = date.getDate();
		return (d<10?('0'+d):d)+'.'+(m<10?('0'+m):m)+'.'+y;
	};
	$.fn.datebox.defaults.parser = function(s){
		if (!s) return new Date();
		var ss = s.split('.');
		var m = parseInt(ss[1],10);
		var d = parseInt(ss[0],10);
		var y = parseInt(ss[2],10);
		if (!isNaN(y) && !isNaN(m) && !isNaN(d)){
			return new Date(y,m-1,d);
		} else {
			return new Date();
		}
	};
}
if ($.fn.datetimebox && $.fn.datebox){
	$.extend($.fn.datetimebox.defaults,{
		currentText: $.fn.datebox.defaults.currentText,
		closeText: $.fn.datebox.defaults.closeText,
		okText: $.fn.datebox.defaults.okText,
		missingMessage: $.fn.datebox.defaults.missingMessage
	});
}
