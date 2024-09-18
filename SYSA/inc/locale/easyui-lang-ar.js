if ($.fn.pagination){
	$.fn.pagination.defaults.beforePageText = '氐賮丨丞';
	$.fn.pagination.defaults.afterPageText = '賲賳 {pages}';
	$.fn.pagination.defaults.displayMsg = '毓乇囟 {from} 廿賱賶 {to} 賲賳 {total} 毓賳氐乇';
}
if ($.fn.datagrid){
	$.fn.datagrid.defaults.loadMsg = '賲毓丕賱噩丞, 丕賱乇噩丕亍 丕賱廿賳鬲馗丕乇 ...';
}
if ($.fn.treegrid && $.fn.datagrid){
	$.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
	$.messager.defaults.ok = '賲賵丕賮賯';
	$.messager.defaults.cancel = '廿賱睾丕亍';
}
if ($.fn.validatebox){
	$.fn.validatebox.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
	$.fn.validatebox.defaults.rules.email.message = '丕賱乇噩丕亍 廿丿禺丕賱 亘乇賷丿 廿賱賰鬲乇賵賳賷 氐丨賷丨.';
	$.fn.validatebox.defaults.rules.url.message = '丕賱乇噩丕亍 廿丿禺丕賱 乇丕亘胤 氐丨賷丨.';
	$.fn.validatebox.defaults.rules.length.message = '丕賱乇噩丕亍 廿丿禺丕賱 賯賷賲丞 亘賷賳 {0} 賵 {1}.';
	$.fn.validatebox.defaults.rules.remote.message = '丕賱乇噩丕亍 丕賱鬲兀賰丿 賲賳 丕賱丨賯賱.';
}
if ($.fn.numberbox){
	$.fn.numberbox.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
}
if ($.fn.combobox){
	$.fn.combobox.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
}
if ($.fn.combotree){
	$.fn.combotree.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
}
if ($.fn.combogrid){
	$.fn.combogrid.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
}
if ($.fn.calendar){
	$.fn.calendar.defaults.weeks = ['S','M','T','W','T','F','S'];
	$.fn.calendar.defaults.months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
}
if ($.fn.datebox){
	$.fn.datebox.defaults.currentText = '丕賱賷賵賲';
	$.fn.datebox.defaults.closeText = '廿睾賱丕賯';
	$.fn.datebox.defaults.okText = '賲賵丕賮賯';
	$.fn.datebox.defaults.missingMessage = '賴匕丕 丕賱丨賯賱 賲胤賱賵亘.';
}
if ($.fn.datetimebox && $.fn.datebox){
	$.extend($.fn.datetimebox.defaults,{
		currentText: $.fn.datebox.defaults.currentText,
		closeText: $.fn.datebox.defaults.closeText,
		okText: $.fn.datebox.defaults.okText,
		missingMessage: $.fn.datebox.defaults.missingMessage
	});
}
