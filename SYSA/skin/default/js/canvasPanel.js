window.canvasImage = {};
window.requestAnimFrame = (function () {
    return window.requestAnimationFrame ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame ||
            function (callback) {
                window.setTimeout(callback, 1000 / 60);
            };
})();
canvasImage.baseInfo = function (context, Option) {
    var Option = Option || {};
    this.origin = Option.origin || [85, 85];//圆点坐标
    this.initColor = ["#FCDFA6", "#D5EDFF", "#FFD4CD"];//初始化颜色；
    this.drawColor = ["#FFA800", "#0D85EC", "#E42E04", "#bfbfbf"];//旋转颜色
    this.sectorOut_r = Option.sectorOut_r || 85;//最大扇形半径
    this.sectorIn_r = Option.sectorOut_r || 65;//内部圆的半径
    this.stickLength = Option.stickLength || 11;//刻度数量
    this.sticksColor = Option.sticksColor || "#fff";//刻度颜色
    this.stickFonts = Option.stickFont || "italic 8px bold 黑体";//刻度文字样式
    this.stickWidth = Option.stickWidth || "4px";//刻度线宽度
    this.stickTextR = Option.stickTextR || 57//绘制刻度文本区域半径
    this.font = Option.font || "12px";//绘制文字样式
    this.angleRang = [[Math.PI / 12 * 11, Math.PI / 10 * 11], [Math.PI / 10 * 11, Math.PI / 10 * 19], [Math.PI / 10 * 19, Math.PI / 12 * 25]]//扇形范围；
    this.pointPosition = [[8, 0], [2.6, 8], [-56, 0]]//指针点坐标
    this.context = context ? context : "";
}
canvasImage.baseInfo();
//绘制扇形
//wise绘制方向、顺时针false/逆时针true
canvasImage.drawSector = function (r, starAngle, endAngle, wise, color, context) {
    var context = context || this.context;
    context.beginPath();
    context.moveTo(this.origin[0], this.origin[1]);
    context.arc(this.origin[0], this.origin[1], r, starAngle, endAngle, wise || false);
    context.fillStyle = color || "#fff";
    context.fill();
}

//由角度求坐标；angle要用弧度
canvasImage.coordxy = function (r, angle) {
    var x = this.origin[0] - r * Math.cos(angle);
    var y = this.origin[1] - r * Math.sin(angle);
    return [x, y]
}

//绘制刻度线;
canvasImage.drawStickLine = function (x1, y1, x2, y2, context) {
    var context = context || this.context;
    context.lineWidth = this.stickWidth;
    context.beginPath();
    context.moveTo(x1, y1);
    context.lineTo(x2, y2);
    context.strokeStyle = this.sticksColor;
    context.stroke();
}

//绘制刻度;angle为刻度最小角度单元（角度）;num刻度数量；
canvasImage.drawSticks = function (r1, r2, angle, num, context) {
    var num = num || this.stickLength;
    for (var i = 0; i < num; i++) {
        var a = Math.PI / 180 * i * angle;
        var xy1 = this.coordxy(r1, a)
        var xy2 = this.coordxy(r2, a)
        this.drawStickLine(xy1[0], xy1[1], xy2[0], xy2[1], context)
    }
}

//绘制文本；
//【txt,x,y】【必填】opt[Object]-->[font,color,alignStyle,textBaseline][可选]
canvasImage.drawText = function (txt, x, y, context, opt) {
    var opt = opt || {};
    var context = context || this.context;
    context.font = opt.font || "italic 8px bold 黑体";
    context.fillStyle = opt.color || "#4A94D3";
    context.textAlign = opt.alignStyle || "right";
    context.textBaseline = opt.textBaseline || "middle";
    context.fillText(txt, x, y);
}

//绘制刻度文本angle为刻度最小角度单元;
canvasImage.drawStickText = function (angle, num, context,p) {
    var num = num || this.stickLength;
    for (var i = 0; i < num; i++) {
        var a = angle * Math.PI / 180 * i;
        var xy = this.coordxy(this.stickTextR, a);
        var s = p ? i * 10 : i;
        var opt = p ? { alignStyle: "center" } : {};
        this.drawText(s, xy[0], xy[1], context, opt);
    }
}

//绘制指针；
canvasImage.drawPoint = function (angle, context) {
    context.save();
    context.translate(this.origin[0], this.origin[1]);
    context.rotate(Math.PI / 180 * angle);
    context.beginPath();
    context.moveTo(this.pointPosition[0][0], this.pointPosition[0][1]);
    context.lineTo(this.pointPosition[1][0], this.pointPosition[1][1]);
    context.lineTo(this.pointPosition[2][0], this.pointPosition[2][1]);
    context.fillStyle = angle <= 180 ? (angle >= 0 ? "#3599fb" : "#9e9e9e") : "#ff3414";
    context.fill();
    context.beginPath();
    context.moveTo(this.pointPosition[0][0], this.pointPosition[0][1]);
    context.lineTo(this.pointPosition[1][0], -this.pointPosition[1][1]);
    context.lineTo(this.pointPosition[2][0], this.pointPosition[2][1]);
    context.fillStyle = angle <= 180 ? (angle >= 0 ? "#0d86ec" : "#7c7c7c") : "#d91400";
    context.fill();
    context.beginPath();
    context.arc(0, 0, 2.4, 0, Math.PI * 2, false);
    context.fillStyle = "#fff";
    context.fill();
    context.restore();
}

//绘制仪表盘区域扇形；
canvasImage.drawInsPanleSec = function (angle, MaxR, context) {
    var a = Math.PI / 180 * (angle + 180);
    if (angle > 0) {
        if (a > Math.PI * 2) { this.drawSector(MaxR, this.angleRang[0][0], this.angleRang[2][1], false, this.drawColor[2], context); return }
        var sectorArr = [];
        var color = [], index;
        for (var i = 0; i < this.angleRang.length; i++) {
            var startA = this.angleRang[i];
            if (a > startA[0] && a < startA[1]) {
                index = i;
                if (a == Math.PI *2) {
                    sectorArr.push(startA);
                    color.push(this.drawColor[i]);
                } else {
                    sectorArr.push([startA[0], a]);
                    sectorArr.push([a, startA[1]]);
                    color.push(this.drawColor[i]);
                    color.push(this.initColor[i]);
                }
            } else {
                sectorArr.push(startA);
                if (a >= startA[1]) {
                    color.push(this.drawColor[i]);
                } else {
                    color.push(this.initColor[i]);
                }
            }
        }
        for (var i = 0; i < sectorArr.length; i++) {
            var ang = sectorArr[i];
            this.drawSector(MaxR, ang[0], ang[1], false, color[i], context)
        }

    } else if (angle < 0) {
        this.drawSector(MaxR, this.angleRang[0][0], this.angleRang[2][1], false, this.drawColor[3], context)
    } else {
        for (var i = 0; i < this.angleRang.length; i++) {
            var ang = this.angleRang[i];
            this.drawSector(MaxR, ang[0], ang[1], false, this.initColor[i], context)
        }
    }
}

//绘制仪表盘；
canvasImage.drawInsPanle = function (angle, txt, context,p) {
    context.clearRect(0, 0, 170, 200);
    this.drawInsPanleSec(angle, 85, context);
    this.drawSector(65, 0, Math.PI * 2, '', '', context);
    this.drawSticks(79, 73, 18, '', context);//绘制刻度线；
    this.drawStickText(18, '', context,p)//绘制刻度文本；
    this.drawText(txt, 85, 50, context, { font: "10px 黑体", color: "#7c9bb5", alignStyle: "center" });
    this.drawPoint(angle, context);
}
canvasImage.drawAnimate = function (txt1, a, context,p) {
    var angle = 0;
    function run(txt) {
        if (angle>0&&angle >= a) {
            angle = a
            canvasImage.drawInsPanle(angle, txt1, context, p);
            return;
        }
        if (angle < 0 && angle <= a) {
            angle = a
            canvasImage.drawInsPanle(angle, txt1, context,p);
            return;
        }

        canvasImage.drawInsPanle(angle, txt1, context,p);
        if (angle == 0) { setTimeout(function () { requestAnimFrame(run) }, 500) } else { requestAnimFrame(run) }
      
        if (a >= 0) {
            angle = angle + 6
        } else {
            angle = angle - 2
        }
        
    }
    requestAnimFrame(run);
}

function animate(element, unit, v,percentage) {
    if (app.getIEVer() < 9) { return; }
    var context = element[0].getContext("2d");
    if(isNaN(v)){v=0}
    var angle = v / 10 * 180;
    var p = percentage ? percentage : "";
    canvasImage.drawAnimate(unit, angle, context,p)
}
