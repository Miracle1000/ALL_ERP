if ($.fn.pagination){
	$.fn.pagination.defaults.beforePageText = '危蔚位委未伪';
	$.fn.pagination.defaults.afterPageText = '伪蟺蠈 {pages}';
	$.fn.pagination.defaults.displayMsg = '螘渭蠁维谓喂蟽畏 {from} 蔚蠋蟼 {to} 伪蟺蠈 {total} 伪谓蟿喂魏蔚委渭蔚谓伪';
}
if ($.fn.datagrid){
	$.fn.datagrid.defaults.loadMsg = '螕委谓蔚蟿伪喂 螘蟺蔚尉蔚蟻纬伪蟽委伪, 螤伪蟻伪魏伪位蠋 螤蔚蟻喂渭苇谓蔚蟿蔚 ...';
}
if ($.fn.treegrid && $.fn.datagrid){
	$.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
	$.messager.defaults.ok = '螘谓蟿维尉蔚喂';
	$.messager.defaults.cancel = '螁魏蠀蟻慰';
}
if ($.fn.validatebox){
	$.fn.validatebox.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
	$.fn.validatebox.defaults.rules.email.message = '螤伪蟻伪魏伪位蠋 蔚喂蟽维纬蔚蟿蔚 蟽蠅蟽蟿萎 螚位.螖喂蔚蠉胃蠀谓蟽畏.';
	$.fn.validatebox.defaults.rules.url.message = '螤伪蟻伪魏伪位蠋 蔚喂蟽维纬蔚蟿蔚 蟽蠅蟽蟿蠈 蟽蠉谓未蔚蟽渭慰.';
	$.fn.validatebox.defaults.rules.length.message = '螤伪蟻伪魏伪位蠋 蔚喂蟽维纬蔚蟿蔚 蟿喂渭萎 渭蔚蟿伪尉蠉 {0} 魏伪喂 {1}.';
	$.fn.validatebox.defaults.rules.remote.message = '螤伪蟻伪魏伪位蠋 未喂慰蟻胃蠋蟽蟿蔚 伪蠀蟿蠈 蟿慰 蟺蔚未委慰.';
}
if ($.fn.numberbox){
	$.fn.numberbox.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
}
if ($.fn.combobox){
	$.fn.combobox.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
}
if ($.fn.combotree){
	$.fn.combotree.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
}
if ($.fn.combogrid){
	$.fn.combogrid.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
}
if ($.fn.calendar){
	$.fn.calendar.defaults.weeks = ['螝蠀蟻','螖蔚蠀','韦蟻喂','韦蔚蟿','螤蔚渭','螤伪蟻','危伪尾'];
	$.fn.calendar.defaults.months = ['螜伪谓', '桅蔚尾', '螠伪蟻', '螒蟺蟻', '螠伪蠆', '螜慰蠀', '螜慰蠀', '螒蠀纬', '危蔚蟺', '螣魏蟿', '螡慰蔚', '螖蔚魏'];
}
if ($.fn.datebox){
	$.fn.datebox.defaults.currentText = '危萎渭蔚蟻伪';
	$.fn.datebox.defaults.closeText = '螝位蔚委蟽喂渭慰';
	$.fn.datebox.defaults.okText = '螘谓蟿维尉蔚喂';
	$.fn.datebox.defaults.missingMessage = '韦慰 蟺蔚未委慰 蔚委谓伪喂 蠀蟺慰蠂蟻蔚蠅蟿喂魏蠈.';
}
if ($.fn.datetimebox && $.fn.datebox){
	$.extend($.fn.datetimebox.defaults,{
		currentText: $.fn.datebox.defaults.currentText,
		closeText: $.fn.datebox.defaults.closeText,
		okText: $.fn.datebox.defaults.okText,
		missingMessage: $.fn.datebox.defaults.missingMessage
	});
}
