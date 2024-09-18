function FormatNumber(srcStr, nAfterDot)        //nAfterDot表示小数位数
{
    var srcStr, nAfterDot;
    var resultStr, nTen;
    srcStr = "" + srcStr + "";
    strLen = srcStr.length;
    dotPos = srcStr.indexOf(".", 0);
    if (dotPos == -1) {
        resultStr = srcStr + ".";
        for (i = 0; i < nAfterDot; i++) {
            resultStr = resultStr + "0";
        }
        return resultStr;
    }
    else {
        if ((strLen - dotPos - 1) >= nAfterDot) {
            nAfter = dotPos + nAfterDot + 1;
            nTen = 1;
            for (j = 0; j < nAfterDot; j++) {
                nTen = nTen * 10;
            }
            resultStr = (Math.round(parseFloat(srcStr) * nTen) / nTen) +"";
            strLen = resultStr.length;
        }
        else {
            resultStr = srcStr;
        }
        if (resultStr.indexOf(".", 0) == -1) {
            resultStr = resultStr + ".";
            strLen += 1;
        }
        for (i = 0; i < (nAfterDot - strLen + dotPos + 1) ; i++) {
            resultStr = resultStr + "0";
        }
        return resultStr;
    }
}

function FormatRound(num, nAfterDot) {
    var d = nAfterDot || 0;
    var m = Math.pow(10, d);
    var n = +(d ? num * m : num).toFixed(12);
    var i = Math.floor(n), f = n - i;
    var e = 1e-8;
    var r = (f > 0.5 - e && f < 0.5 + e) ?
                ((i % 2 == 0) ? i : i + 1) : Math.round(n);
    var v = d ? r / m : r;
    return FormatNumber(v, nAfterDot);
}
