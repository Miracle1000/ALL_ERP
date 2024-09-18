function KeyMeanFun(lvw, rowindex, cellindex) {
    var cpindex = -1;
    var nindex = -1;
    for (var k = 0; k < lvw.headers.length; k++) {
        if (lvw.headers[k].dbname == "KeyMean") { cpindex = k; }
        if (lvw.headers[k].dbname == "KeyName") { nindex = k; }
    }

    var dateindex = -1;
    for (var l = 1; l < lvw.rows.length; l++) {
        if (lvw.rows[l][nindex] == "日期编码：" || lvw.rows[l][nindex] == "日期编码") {
            dateindex = l;
        }
    }
    if (lvw.rows.length <= 4) {
        lvw.rows[dateindex][nindex + 1] = getNowFormatDate();
    }
    var isReamerZ = 0, isReamerF = 0, isReamerZ1 = 0, isReamerF1 = 0;
    for (var j = 0; j < lvw.rows.length; j++) {


        if (j >= 0 && j < dateindex) {
            if (lvw.rows[j][cpindex] == 2 || lvw.rows[j][cpindex] == -2) {
                lvw.rows[j][cpindex] = 2;
            } else {
                lvw.rows[j][cpindex] = 5;
            }
        }

        if (j == dateindex + 1) {
            lvw.rows[j][cpindex] = 4;
        }
        if (j > dateindex + 1)
            lvw.rows[j][cpindex] = 6;

        if (lvw.rows[j][cpindex] == 2 || lvw.rows[j][cpindex] == 5) {
            isReamerZ += 1;
        }
        if (lvw.rows[j][cpindex] == -2 || lvw.rows[j][cpindex] == -5) {
            isReamerF += 1;
        }
        if (lvw.rows[j][cpindex] == 4 || lvw.rows[j][cpindex] == 6) {
            isReamerZ1 += 1;
        }
        if (lvw.rows[j][cpindex] == -4 || lvw.rows[j][cpindex] == -6) {
            isReamerF1 += 1;
        }
    }

    for (var i = 0; i < lvw.rows.length; i++) {
        var t1 = lvw.rows[i][cpindex];
        if (isReamerZ >= 3) {
            if (i >= 0 && i < dateindex)
                lvw.rows[i][cpindex] = lvw.rows[i][cpindex] == 2 ? -2 : -5;
        }
        if (isReamerF < 3 && isReamerF > 0) {
            if (i >= 0 && i < dateindex)
                lvw.rows[i][cpindex] = lvw.rows[i][cpindex] == -2 ? 2 : 5;
        }
        if (isReamerZ1 >= 3) {
            if (i > dateindex)
                lvw.rows[i][cpindex] = lvw.rows[i][cpindex] == 4 ? -4 : -6;
        }
        if (isReamerF1 < 3 && isReamerF1 > 0) {
            if (i > dateindex)
                lvw.rows[i][cpindex] = lvw.rows[i][cpindex] == -4 ? 4 : 6;
        }
    }
    return lvw.rows[rowindex][cpindex];


}
function getNowFormatDate() {
    var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate

    return currentdate;
}

function SeriNumFun(lvw, rowindex, cellindex) {
    //  var cpindex = -1;
    var nindex = -1;
    for (var k = 0; k < lvw.headers.length; k++) {
        //if (lvw.headers[k].dbname == "SeriNum") { cpindex = k; }
        if (lvw.headers[k].dbname == "isRepeat") { nindex = k; }
    }

    if (lvw.rows[rowindex][nindex] == 1) {
        return lvw.rows[rowindex][cellindex] + "<span class='lvw_plus_msg'>【已存在】</span>";
    }
    else {
        return lvw.rows[rowindex][cellindex];
    }

}