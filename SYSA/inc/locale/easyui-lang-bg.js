if ($.fn.pagination){
	$.fn.pagination.defaults.beforePageText = '小褌褉邪薪懈褑邪';
	$.fn.pagination.defaults.afterPageText = '芯褌 {pages}';
	$.fn.pagination.defaults.displayMsg = '袩芯泻邪蟹邪薪懈 {from} 蟹邪 {to} 芯褌 {total} 锌褉芯写褍泻褌懈';
}
if ($.fn.datagrid){
	$.fn.datagrid.defaults.loadMsg = '袨斜褉邪斜芯褌泻邪, 屑芯谢褟 懈蟹褔邪泻邪泄褌械 ...';
}
if ($.fn.treegrid && $.fn.datagrid){
	$.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
	$.messager.defaults.ok = '袛芯斜褉械';
	$.messager.defaults.cancel = '袟邪写褉邪褋泻胁邪屑';
}
if ($.fn.validatebox){
	$.fn.validatebox.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
	$.fn.validatebox.defaults.rules.email.message = '袦芯谢褟, 胁褗胁械写械褌械 胁邪谢懈写械薪 懈屑械泄谢 邪写褉械褋.';
	$.fn.validatebox.defaults.rules.url.message = '袦芯谢褟 胁褗胁械写械褌械 胁邪谢懈写械薪 URL.';
	$.fn.validatebox.defaults.rules.length.message = '袦芯谢褟, 胁褗胁械写械褌械 褋褌芯泄薪芯褋褌 屑械卸写褍 {0} 懈 {1}.';
}
if ($.fn.numberbox){
	$.fn.numberbox.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
}
if ($.fn.combobox){
	$.fn.combobox.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
}
if ($.fn.combotree){
	$.fn.combotree.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
}
if ($.fn.combogrid){
	$.fn.combogrid.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
}
if ($.fn.calendar){
	$.fn.calendar.defaults.weeks = ['S','M','T','W','T','F','S'];
	$.fn.calendar.defaults.months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
}
if ($.fn.datebox){
	$.fn.datebox.defaults.currentText = '袛薪械褋';
	$.fn.datebox.defaults.closeText = '袘谢懈蟹芯';
	$.fn.datebox.defaults.okText = '袛芯斜褉械';
	$.fn.datebox.defaults.missingMessage = '孝芯胁邪 锌芯谢械 械 蟹邪写褗谢卸懈褌械谢薪芯.';
}
if ($.fn.datetimebox && $.fn.datebox){
	$.extend($.fn.datetimebox.defaults,{
		currentText: $.fn.datebox.defaults.currentText,
		closeText: $.fn.datebox.defaults.closeText,
		okText: $.fn.datebox.defaults.okText,
		missingMessage: $.fn.datebox.defaults.missingMessage
	});
}
