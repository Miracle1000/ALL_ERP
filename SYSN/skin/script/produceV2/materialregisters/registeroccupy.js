function SetNum1Bylvw(pRowindex, rowindex)
{
    var numindex = -1;
    var klidindex = -1;
    var unitindex = -1;
    var nowNumindex = -1;
    var Serialindex = -1;
    var lvw = window['lvw_JsonData_kuoutlist'];
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'SpecifiedNum') { numindex = i; }
        if (lvw.headers[i].dbname == 'KuOutListId') { klidindex = i; }
        if (lvw.headers[i].dbname == 'KuoutUnitId') { unitindex = i; }
        if (lvw.headers[i].dbname == 'NowNum') { nowNumindex = i; }
        if (lvw.headers[i].dbname == 'SerialID') { Serialindex = i; }
    }
    var num1 = 0;
    var num2=0;
    var mapping = "";
    var appiontNum = parseFloat($('#numtb').find('span').eq(0).html().replace(/\,/g,""));
    var noappiontNum = parseFloat($('#numtb').find('span').eq(1).html().replace(/\,/g,""))
    var cha = appiontNum - noappiontNum;
    for (var i = 0; i < lvw.rows.length; i++) {
        if (lvw.rows[i][numindex] != '' && lvw.rows[i][numindex] != undefined) {
            if(i!=rowindex){
                num2 += parseFloat(lvw.rows[i][numindex]);
            }
            num1 += parseFloat(lvw.rows[i][numindex]);
            mapping += lvw.rows[i][klidindex] + ',' + lvw.rows[i][numindex] + ',' + lvw.rows[i][unitindex] + ',' + lvw.rows[i][Serialindex] + "|";
        }
      
    }
    var nowNum = lvw.rows[rowindex][nowNumindex];
    var specifiedNum = lvw.rows[rowindex][numindex];
    if ((appiontNum - num1).toFixed(window.SysConfig.NumberBit) < 0 || specifiedNum > nowNum) {
        var isalert=0
        if (specifiedNum > nowNum) {
            alert('不允许超过现有数量！');
            isalert = 1;
        } else {
            alert('数量不能大于应指定数量！');
            isalert = 1;
        }
        $('#numtb').find('span').eq(1).html((appiontNum - num2).toFixed(window.SysConfig.NumberBit));
        __lvw_je_updateCellValue(lvw.id, rowindex, numindex, 0);
        lvw.rows[rowindex][numindex] = 0;
        if (isalert=0) {
            SetNum1Bylvw(pRowindex, rowindex);//重新计算
        }
    }
    else {
    	noappiontNum = (appiontNum - num1).toFixed(window.SysConfig.NumberBit);
        $('#numtb').find('span').eq(1).html(app.NumberFormat(noappiontNum));
        SetOpenerLvwValue(mapping, appiontNum - noappiontNum, pRowindex);
    }
}

function SetOpenerLvwValue(mapping, mapnum, pRowindex)
{
    if (parseFloat(mapnum) == "NaN") mapnum = 0;
    if (mapnum.toString().indexOf("e") > 0 || mapnum.toString().indexOf("E") > 0) { mapnum = mapnum.toFixed(window.SysConfig.NumberBit); }
    var plvw = opener.window['lvw_JsonData_rglvw'];
    var hmapping = -1;
    var hmapnum = -1;
    var hzdmapnum = -1;
    for (var i = 0; i < plvw.headers.length; i++) {
        if (plvw.headers[i].dbname == 'mapping') { hmapping = i; }
        if (plvw.headers[i].dbname == 'mapnum') { hmapnum = i; }
        if (plvw.headers[i].dbname == 'zdmapnum') { hzdmapnum = i; }
    }
    opener.__lvw_je_updateCellValue(plvw.id, pRowindex, hmapping, mapping);
    opener.__lvw_je_updateCellValue(plvw.id, pRowindex, hmapnum, mapnum);

    var zdnumv = "已指定：" + app.FormatNumber(mapnum, "numberbox") + "";
    zdnumv = mapnum == "" ? "" : zdnumv;
    opener.__lvw_je_updateCellValue(plvw.id, pRowindex, hzdmapnum, zdnumv);
    opener.___RefreshListViewByJson(plvw);
    
}

Bill.OnBeforeLoad = function () {
    var r = app.FindUrlParam(window.location.href, "r");
    var n = app.FindUrlParam(window.location.href, "n");
    var plvw = opener.window['lvw_JsonData_rglvw'];
    var hmapping = -1;
    var hmapnum = -1;
    for (var i = 0; i < plvw.headers.length; i++) {
        if (plvw.headers[i].dbname == 'mapping') { hmapping = i; }
        if (plvw.headers[i].dbname == 'mapnum') { hmapnum = i; }
    }
    var hmap = parseFloat(plvw.rows[r][hmapnum]);
    Bill.Data.groups[0].fields[1].children[2].defvalue = parseFloat(n) - (isNaN(hmap) ? 0 : hmap);
    var lvw = Bill.Data.groups[0].fields[2].listview;
    var numindex = -1;
    var klidindex = -1;
    var Serialindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'SpecifiedNum') { numindex = i; }
        if (lvw.headers[i].dbname == 'KuOutListId') { klidindex = i; }
        if (lvw.headers[i].dbname == 'SerialID') { Serialindex = i; }
    }
    var hmapping = plvw.rows[r][hmapping];
    if (hmapping != null && hmapping != "") {
        hmapping = hmapping.toString();
        var m = hmapping.split('|');
        for (var i = 0; i < m.length; i++) {
            if (m[i] != "") {
                var it = m[i].split(',');
                if (it.length >= 2) {
                    for (var ii = 0; ii < lvw.rows.length; ii++) {
                        if (lvw.rows[ii][klidindex] == it[0] && lvw.rows[ii][Serialindex] == it[3]) { lvw.rows[ii][numindex] = it[1]; break; }
                    }
                }
            }
        }
    }
}