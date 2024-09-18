window.triggerSys_global_pagesClick = function (_this, wfpaid) {
    document.querySelector('[dbname=\'sys_global_pages\']').click();
}

window.triggerAddRowClick = function (_this) {
    $('#AddRow').trigger('change');
}