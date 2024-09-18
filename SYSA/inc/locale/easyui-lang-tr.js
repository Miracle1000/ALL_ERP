if ($.fn.pagination){
    $.fn.pagination.defaults.beforePageText = 'Sayfa';
    $.fn.pagination.defaults.afterPageText = ' / {pages}';
    $.fn.pagination.defaults.displayMsg = '{from} ile {to} aras谋 g枚steriliyor, toplam {total} kay谋t';
}
if ($.fn.datagrid){
    $.fn.panel.defaults.loadingMessage = "Y眉kleniyor...";
}

if ($.fn.datagrid){
    $.fn.datagrid.defaults.loadingMessage = "Y眉kleniyor...";
    $.fn.datagrid.defaults.loadMsg = '陌艧leminiz Yap谋l谋yor, l眉tfen bekleyin ...';
}
if ($.fn.treegrid && $.fn.datagrid){
    $.fn.treegrid.defaults.loadMsg = $.fn.datagrid.defaults.loadMsg;
}
if ($.messager){
    $.messager.defaults.ok = 'Tamam';
    $.messager.defaults.cancel = '陌ptal';
}
if ($.fn.validatebox){
    $.fn.validatebox.defaults.missingMessage = 'Bu alan zorunludur.';
    $.fn.validatebox.defaults.rules.email.message = 'L眉tfen ge莽erli bir email adresi giriniz.';
    $.fn.validatebox.defaults.rules.url.message = 'L眉tfen ge莽erli bir URL giriniz.';
    $.fn.validatebox.defaults.rules.length.message = 'L眉tfen {0} ile {1} aras谋nda bir de臒er giriniz.';
    $.fn.validatebox.defaults.rules.remote.message = 'L眉tfen bu alan谋 d眉zeltiniz.';
}
if ($.fn.numberbox){
    $.fn.numberbox.defaults.missingMessage = 'Bu alan zorunludur.';
}
if ($.fn.combobox){
    $.fn.combobox.defaults.missingMessage = 'Bu alan zorunludur.';
}
if ($.fn.combotree){
    $.fn.combotree.defaults.missingMessage = 'Bu alan zorunludur.';
}
if ($.fn.combogrid){
    $.fn.combogrid.defaults.missingMessage = 'Bu alan zorunludur.';
}
if ($.fn.calendar){
    $.fn.calendar.defaults.weeks = ['Pz','Pt','Sa','脟a','Pe','Cu','Ct'];
    $.fn.calendar.defaults.months = ['Oca', '艦ub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'A臒u', 'Eyl', 'Eki', 'Kas', 'Ara'];
}
if ($.fn.datebox){
    $.fn.datebox.defaults.currentText = 'Bug眉n';
    $.fn.datebox.defaults.closeText = 'Kapat';
    $.fn.datebox.defaults.okText = 'Tamam';
    $.fn.datebox.defaults.missingMessage = 'Bu alan zorunludur.';
}
if ($.fn.datetimebox && $.fn.datebox){
    $.extend($.fn.datetimebox.defaults,{
        currentText: $.fn.datebox.defaults.currentText,
        closeText: $.fn.datebox.defaults.closeText,
        okText: $.fn.datebox.defaults.okText,
        missingMessage: $.fn.datebox.defaults.missingMessage
    });
    
    $.fn.datebox.defaults.formatter=function(date){
        var y=date.getFullYear();
        var m=date.getMonth()+1;
        var d=date.getDate();
        if(m<10){m="0"+m;}
        if(d<10){d="0"+d;}
        return d+"."+m+"."+y;
    };
}
