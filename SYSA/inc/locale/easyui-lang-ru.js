if ($.fn.pagination){
	$.fn.pagination.defaults.beforePageText = '小褌褉邪薪懈褑邪';
	$.fn.pagination.defaults.afterPageText = '懈蟹 {pages}';
	$.fn.pagination.defaults.displayMsg = '袩褉芯褋屑芯褌褉 {from} 写芯 {to} 懈蟹 {total} 蟹邪锌懈褋械泄';
}
if ($.fn.datagrid){
	$.fn.datagrid.defaults.loadMsg = '袨斜褉邪斜邪褌褘胁邪械褌褋褟, 锌芯卸邪谢褍泄褋褌邪 卸写懈褌械 ...';
}
if ($.fn.treegrid && $.fn.datagrid){
	$.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
	$.messager.defaults.ok = '袨泻';
	$.messager.defaults.cancel = '袟邪泻褉褘褌褜';
}
if ($.fn.validatebox){
	$.fn.validatebox.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
	$.fn.validatebox.defaults.rules.email.message = '袩芯卸邪谢褍泄褋褌邪 胁胁械写懈褌械 泻芯褉褉械泻褌薪褘泄 e-mail 邪写褉械褋.';
	$.fn.validatebox.defaults.rules.url.message = '袩芯卸邪谢褍泄褋褌邪 胁胁械写懈褌械 泻芯褉褉械泻褌薪褘泄 URL.';
	$.fn.validatebox.defaults.rules.length.message = '袩芯卸邪谢褍泄褋褌邪 胁胁械写懈褌械 蟹邪褔械薪懈械 屑械卸写褍 {0} 懈 {1}.';
	$.fn.validatebox.defaults.rules.remote.message = '袩芯卸邪谢褍泄褋褌邪 懈褋锌褉邪胁褌械 褝褌芯 锌芯谢械.';
}
if ($.fn.numberbox){
	$.fn.numberbox.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
}
if ($.fn.combobox){
	$.fn.combobox.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
}
if ($.fn.combotree){
	$.fn.combotree.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
}
if ($.fn.combogrid){
	$.fn.combogrid.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
}
if ($.fn.calendar){
	$.fn.calendar.defaults.firstDay = 1;
	$.fn.calendar.defaults.weeks  = ['袙','袩','袙','小','效','袩','小'];
	$.fn.calendar.defaults.months = ['携薪胁', '肖械胁', '袦邪褉', '袗锌褉', '袦邪泄', '袠褞薪', '袠褞谢', '袗胁谐', '小械薪', '袨泻褌', '袧芯褟', '袛械泻'];
}
if ($.fn.datebox){
	$.fn.datebox.defaults.currentText = '小械谐芯写薪褟';
	$.fn.datebox.defaults.closeText = '袟邪泻褉褘褌褜';
	$.fn.datebox.defaults.okText = '袨泻';
	$.fn.datebox.defaults.missingMessage = '协褌芯 锌芯谢械 薪械芯斜褏芯写懈屑芯.';
}
if ($.fn.datetimebox && $.fn.datebox){
	$.extend($.fn.datetimebox.defaults,{
		currentText: $.fn.datebox.defaults.currentText,
		closeText: $.fn.datebox.defaults.closeText,
		okText: $.fn.datebox.defaults.okText,
		missingMessage: $.fn.datebox.defaults.missingMessage
	});
}
