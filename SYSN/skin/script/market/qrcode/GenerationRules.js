window.slcoldis = function (oldName, obj, indexcol, checked) {
    if (checked == "") checked = 0;
    var result = '<td class="lvw_cell lvw_noEd" dbcolindex="1" islvw="1" realindex="1" style="text-align: center; background-color: rgb(224, 241, 255);" align="center" uitype="lvwallselectcol" lvw_id="CodeTypeFields" dbname="CodeTypeFields_@allselectcol_' + indexcol + '_1"><input id="CodeTypeFields_jec_' + indexcol + '_1" ' + (checked == 0 ? "" : 'checked') + ' onclick="__lvw_je_updateCellValue(\'CodeTypeFields\',' + indexcol + ',1,this.checked?1:0, undefined, undefined, true)" type="checkbox"></td>';
    if (indexcol == 0 && (oldName == '流水号' || oldName == '商品号')) {
         result = ""
     }
     window["lvw_JsonData_CodeTypeFields"].rows[0][1] = 0;
     return result;
}

