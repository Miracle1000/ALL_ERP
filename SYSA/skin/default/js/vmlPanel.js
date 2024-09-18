//绘制扇形
window.sectorInfo = {
    colorOrigin: ["#FFD4CD", "#D5EDFF", "#FCDFA6"],
    newColor: ["#E42E04", "#0D85EC", "#FFA800"],
    minusColor: "#BFBFBF",
    extraColor: "#E42E04",
    drawRange: [[-15, 18], [18, 162], [162, 195]],
    riginR: 85,
    StickR1: 79,
    StickR2: 71,
    StickTextR: 56
}
function sector(angle) {
    var ds = Math.pow(2, 16);
    var html = "";
    var opt;
    if (window.sectorInfo == {} || window.sectorInfo == undefined) { return; }
    var drawRanges = window.sectorInfo.drawRange;
    if (angle) {
        if (angle < 0) {
            var startAg = drawRanges[0][0];
            var endAg = drawRanges[drawRanges.length - 1][1];
            var rangeAg = endAg - startAg;
            var opt = { fillcolor: sectorInfo.minusColor, startAg: startAg * ds, rangeAg: rangeAg * ds }
            html = sectorHtml(opt);
        } else {
            var newDrawRg = [];
            var newColor = [];
            var angle = 180 - angle;
            for (var i = 0; i < drawRanges.length; i++) {
                var drawRange = drawRanges[i];
                var starAg = drawRange[0];
                var endAg = drawRange[1];
                if (angle > starAg & angle < endAg) {
                    if (angle ==0) {
                        newDrawRg.push([starAg, endAg]);
                        newColor.push(sectorInfo.newColor[i]);
                    } else {
                        newDrawRg.push([starAg, angle]);
                        newColor.push(sectorInfo.colorOrigin[i])
                        newDrawRg.push([angle, endAg]);
                        newColor.push(sectorInfo.newColor[i])
                    }
                } else {
                    newDrawRg.push([starAg, endAg]);
                    if (angle <= starAg) {
                        if (angle < 0) {
                            newColor.push([sectorInfo.newColor[0]]);
                        } else { newColor.push(sectorInfo.newColor[i]); }
                        continue;
                    }
                    newColor.push(sectorInfo.colorOrigin[i]);
                }
            }
            for (var i = 0; i < newDrawRg.length; i++) {
                var drawAg = newDrawRg[i];
                var startAg = drawAg[0];
                var rangeAg = drawAg[1] - startAg;
                var opt = { fillcolor: newColor[i], startAg: startAg * ds, rangeAg: rangeAg * ds }
                html += sectorHtml(opt);
            }
        }
    } else {
        for (var i = 0; i < drawRanges.length; i++) {
            var drawRange = drawRanges[i];
            var startAg = drawRange[0];
            var rangeAg = drawRange[1] - startAg
            var opt = { fillcolor: sectorInfo.colorOrigin[i], startAg: startAg * ds, rangeAg: rangeAg * ds }
            html += sectorHtml(opt);
        }
    }
    return html
}

/**
 * **
 * /@description 绘制的扇形html;
 * /@function opt[object]{fillcolor:"填充色",strokecolor:"边框色",startAg:"起始角度",AngleRange:"角度范围"};
 * **
 */
function sectorHtml(opt) {
    var htm =
      "<v:shape style='POSITION: absolute; WIDTH: 170px; HEIGHT: 170px; TOP: 0px; CURSOR: pointer; LEFT: 0px; fill: #ff9900' coordsize = '1000,1000' fillcolor = '" +
      opt.fillcolor + "' strokecolor = '" + opt.fillcolor + "'  path = 'm500 500 ae500 500 500 500 " + parseInt(opt
      .startAg) + " " + parseInt(opt.rangeAg) + " e'></v:shape>";
    return htm;
}

/**
 * **
 * /@description 绘制圆形html;
 * /@function opt[object]{fillcolor:"填充色",strokecolor:"边框色",startAg:"起始角度",AngleRange:"角度范围"};
 * **
 */
function drawCircle() {
    var htm = "<v:shape " +
      "style='POSITION: absolute; WIDTH: 170px; HEIGHT: 170px; TOP: 0px; CURSOR: pointer; LEFT: 0px; fill: #fff' " +
      "coordsize='1000,1000' fillcolor='#fff' strokecolor='#fff' path='m500 500 ae500 500 382 382 0 23592960  e'>" +
      "</v:shape>"
    return htm
}
/*****
 * /@description 绘制刻度;
 * /@function opt[object]{fillcolor:"填充色",strokecolor:"边框色",startAg:"起始角度",AngleRange:"角度范围"};
 */

function drawStick(angle,p) {
    var angle = angle || 18;
    var R0 = sectorInfo.riginR;
    var R1 = sectorInfo.StickR1;
    var R2 = sectorInfo.StickR2;
    var R3 = sectorInfo.StickTextR;
    var htm = "";
    for (var i = 0; i <= 10; i++) {
        var x = parseInt(R0 - R1 * Math.cos(Math.PI / 180 * i * angle));
        var y = parseInt(R0 - R1 * Math.sin(Math.PI / 180 * i * angle));
        var x1 = parseInt(R0 - R2 * Math.cos(Math.PI / 180 * i * angle));
        var y1 = parseInt(R0 - R2 * Math.sin(Math.PI / 180 * i * angle));
        var x2 = parseInt(R0 - R3 * Math.cos(Math.PI / 180 * i * angle));
        var y2 = parseInt(R0 - R3 * Math.sin(Math.PI / 180 * i * angle));
        var s = p ? i * 10 : i;
        htm += stickHtml(x, y, x1, y1) + textHtml(s, x2, y2,"",p);
    }
    function stickHtml(x, y, x1, y1) {
        var htm = "<v:line style='POSITION: absolute; DISPLAY: block; VISIBILITY: visible; COLOR: #000; TOP: " + 0 +
          "px; LEFT: " + 0+ "px'" +
          " from='" + x + "px," + y + "px' to='" + x1 + "px," + y1 +
          "px' strokecolor='#fff' strokeweight='2px'></v:line>";
        return htm;
    }
    return htm;
}

//绘制指针；
function pointer(angle) {
    var htm3 = "<v:image src='../skin/default/images/" + (angle < 0 ? "yi_gray.png" : (angle > 180 ? "yi_red.png" : "yi_blue.png")) + "'" +
    "style='rotation:" + angle + ";;Z-INDEX:999;LEFT:28px;WIDTH:116px;POSITION:absolute;TOP:77px;HEIGHT:18px' />"
    return htm3
}

function textHtml(txt, x, y, type, p) {
    var p = p ? p : "";
    var type = type ? type : "";
    var htm = "<v:textbox style='font-style:italic;FONT-SIZE:12;COLOR:#4A94D3;text-align:left;position:absolute;margin-left:"+(p?-8:-5)+"px;margin-top:"+(p?-2:0)+"px;left:" + x + "px;top: " + (y - 10) + "px;' >" + txt + "</v:textbox>";
    if (type) { htm = "<div style='FONT-SIZE:12px;COLOR:#4A94D3;display:block;text-align:center;width:100px;height:14px;position:absolute;left:" + x + "px;top: " + y  + "px;' >" + txt + "</div>" }
    return htm
}
function drawVmlIE(ele, v, txt, p) {
    var p = p ? p : "";
    var angle =  v / 10 * 180 ;
    var htm = sector(angle) + drawCircle() + drawStick("",p) + pointer(angle) + textHtml(txt, 36, 40,1);
    $(ele).html(htm);
}