//继承处理报价结算弹层样式呈现
window.procLayerUiForSpePage = function (bd, lay) {
    var gps = lay.groups;
    bd.push("<div id='layerParForSpe'  onclick='$(this).remove()'>");
    bd.push("<div class='layer' style='display:" + (lay.visible || lay.ui.visible ? "" : "none") + ";width:100%;height:100%;top:0px;border:none;top:-1px;'>");
    bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:50px;line-height:50px;background-color: #075387;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>");
    bd.push("<div id='lay_cont' style='height:" + (ui.clientHeight - 100) + "px'>")
    bd.push("<table class='bill_table'>");
    bd.push("<colgroup><col style='width:25%'></col><col style='width:2px'></col><col></col></colgroup>");
    for (var q = 0; q < gps.length; q++) {
        var fds = gps[q].fields;
        for (var w = 0; w < fds.length; w++) {
            bill.GetItemFieldHtml(fds[w]);
        }
    }
    bd.push("</table>");
    bd.push("</div>");
    bd.push("<div class='caigouBtmArea' style='width:100%;height:50px;position: fixed;bottom: 0;left:0px;background: #FFF;'>");
    bd.push("<div style='width:60%;display:block;float:left;height:100%;line-height:50px;overflow:hidden;position:relative;visibility:hidden;' id='lay_area'>"
        + "  	<span style='float:left;display:inline-block;margin-left:15px;height:50px;line-height:50px;'>优惠后总额：</span>"
        + "		<span style='float:left;display:inline-block;margin-left:5px;height:50px;color:red;line-height:50px;' id='lay_money1'></span>"
        + " 	</div>"
        + " 	<div onclick='ui.CZSMLPage(this)' target='none' method='post' action='SysBillSave' style='width:40%;display:block;float:left;height:50px;line-height:50px;color:#FFF;overflow:hidden;background-color:#ff6411;text-align:center'>保存</div>")
    bd.push("</div>")
    bd.push("</div>");
    bd.push("</div>");
    setTimeout(function () {
        SetPriceMoneyVal()
    }, 300)
}

function SetPriceMoneyVal() {
    var money1 = 0;
    var power = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "money1") { money1 = v; }
        if (dbname == "power") { power = v; }
    }, "post");
    $('#lay_money1').html(bill.FormatNumber(money1, __currwin.zsml.header.moneybit));
    $('#lay_area').css("visibility", (power == "1" ? "visible" : "hidden"));
}

//优惠方式 回调方法
window.HandleSaleType = function () {
    var yhtype = $("input[name='yhtype']:checked").val();
    if (yhtype == undefined) { yhtype = 0; }
    if (yhtype == 0) {
        $("#yhmoneytd").show();
        $("#zktd").hide();
    } else {
        $("#yhmoneytd").hide();
        $("#zktd").show();
    }
}

//处理展开收缩按钮
window.clickmore = function (el) {
    var ismore = $(el).attr("ismore");
    if (ismore == "0") {
        $(el).attr("ismore", "1");
        $(".cg-btn-txt").html("收缩");
        $(".cg-arrow").removeClass("cg-down");
        $(".cg-arrow").addClass("cg-up");
        $ID("ismore").value = 1;
        bill.triggerFieldEvent($ID("ismore"), "change");
    } else {
        $(el).attr("ismore", "0");
        $(".cg-btn-txt").html("更多");
        $(".cg-arrow").addClass("cg-down");
        $(".cg-arrow").removeClass("cg-up");
        $ID("ismore").value = 0;
        bill.triggerFieldEvent($ID("ismore"), "change");
    }
}

//页面绑定回调呈现方式
app.addMessageEvent("childpageclose", function (data, closeWinhwnd) {
    if (closeWinhwnd.indexOf("_pricemobilebillscan") == -1 && closeWinhwnd.indexOf("geproductbilllistasp") == -1 && closeWinhwnd.indexOf("_pricemobileofferedit") == -1) { return; }
    $ID("childrefreshEventbox").value = 0;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});

//扫描添加按钮
window.getIntoScanfPage = function (el) {
    var company = "";
    var invoiceType = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "company") { company = v; }
        if (dbname == "invoiceType") { invoiceType = v; }
    }, "post");
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
    var pnum = $("#pnumbox").text();
    var pmoney = $("#pmoneybox").text().replace("￥", "");
    var pcount = $("#countbox").text();
    var lvw = window[this.dbsignID]
    if (lvw) {
        var rows = lvw.rows;
        var hd = lvw.headers;
        var idInx = -1;
        var pricelistcount = 0;
        for (var i = 0; i < hd.length; i++) {
            if (hd[i].dbname == "id") { idInx = i; break; }
        }
        for (var j = 0; j < rows.length; j++) {
            if (rows[j][i] < 0) { pricelistcount++; }
        }
    }
    el.setAttribute("url", "PriceMobileBillScan.ashx?fromtype=priceofferbill&company=" + company + "&invoiceType=" + invoiceType + "&pnum=" + pnum + "&pmoney=" + pmoney + "&pcount=" + pcount + "&plcount=" + pricelistcount);
    ui.CZSMLPage(el);
}

//手动添加产品按钮
window.getIntoChooseProcPage = function (el) {
    var company = "";
    var invoiceType = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "company") { company = v; }
        if (dbname == "invoiceType") { invoiceType = v; }
    }, "post");
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");

    el.setAttribute("url", info.hosturl + "/mobilephone/salesManage/product/billlist.asp?fromtype=priceofferbill&company=" + company + "&invoiceType=" + invoiceType);
    ui.CZSMLPage(el);
}

//采购添加底部结算按钮
window.onBeforePageInit = function () {
    var currweb = plus.webview.currentWebview();
    var zsml = currweb.zsml;
    var jbill = zsml.body.bill;
    var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
    scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;'><div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>"
        + "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div></div>";
    setTimeout(function () {
        var h = document.documentElement.offsetHeight;
        $("#page-content").css("height", h - 100);
    }, 300)
}

//联动更新底部结算信息
window.updateSumForSpcFun = function (lvw, rowindex, dbi, v) {
    var hds = lvw.headers;
    var midx = 0;
    var nidx = 0;
    var pidx = 0;
    var disdx = 0;
    for (var i = 0; i < hds.length; i++) {
        if (hds[i].dbname == "money1") { midx = i; }
        if (hds[i].dbname == "num1") { nidx = i; }
        if (hds[i].dbname == "priceIncludeTax") { pidx = i; }
        if (hds[i].dbname == "discount") { disdx = i; }
    }
    if (hds[dbi].dbname == "priceIncludeTax") {
        lvw.rows[rowindex][pidx] = v;
        lvw.rows[rowindex][midx] = v * 1 * (lvw.rows[rowindex][nidx] * 1) * (lvw.rows[rowindex][disdx] * 1);
    }
    if (hds[dbi].dbname == "num1") {
        lvw.rows[rowindex][nidx] = v;
        lvw.rows[rowindex][midx] = v * 1 * (lvw.rows[rowindex][pidx] * 1) * (lvw.rows[rowindex][disdx] * 1);
    }
}

//报价明细单行明细删除按钮回调事件
window.deleteListviewRowForServer = function (lvw, pos) {
    var len = lvw.headers.length;
    var rowData = {};
    var rows = lvw.rows;
    var keyfieldvalue = "";
    for (var i = 0; i < len; i++) {
        if (lvw.headers[i].dbname != "") {
            rowData[lvw.headers[i].dbname] = (lvw.rows[pos][i] != null ? lvw.rows[pos][i] : null);
            if (lvw.headers[i].dbname.toLowerCase() == ("" + lvw.keyfield || "").toLowerCase()) {
                keyfieldvalue = rowData[lvw.headers[i].dbname];
            }
        }
    }
    var parms = new Object();
    parms["buttontext"] = "删除";
    parms["listviewid"] = lvw.id;
    parms["currrowdata"] = app.GetJSON(rowData);
    parms["keyfieldvalue"] = keyfieldvalue;
    app.RegEvent("sys.listview.handlebtnclick", parms);
}

//清空按钮
window.createBtnForSpecGroup = function (btn) {
    return "<div class='bill_txt' onclick='window.clearBtn(this);' action='SysBillCallBack' url='ClearAllPriceMxList'  target='" + (btn.target || "") + "' >" + btn.title + "</div>"
}

window.clearBtn = function (el) {
    var ev = window.event;
    ev.stopPropagation();
    ui.confirm("您确定要清空报价明细?", function (e) {
        if (e.index == 1) {
            var parms = new Object();
            ui.CZSMLPage(el);
        }
    }, info.alertTitle, ["取消", "确定"])
}

window.clearLvwForPrice = function () {
    var dbsign = $("#MobListView_detailList").attr("dbsign");
    bill.clearListViewRows(dbsign, true);
}


window.HandleFieldFormul = function (currDBName, mBit, formula) {
    /*
     * 数量		num1
     * 未税单价	price1
     * 折扣		discount
     * 折后单价	priceAfterDiscount
     * 含税单价	priceIncludeTax
     * 含税折后单价  priceAfterTax
     * 税率		taxRate
     * 税前总价	moneyBeforeTax   未税折后总价
     * 税额		taxValue
     * 税后总价	money1
     * 建议进价	pricejy 
     * 建议总价	tpricejy
     */
    var pricestore = __currwin.zsml.header.pricebit.sale;
    /*正式报价产品明细-含税单价赋值*/
    if (currDBName == "priceIncludeTax") {        
        var dbnameid = $(window.event.target).attr("dbname");
        var rowinx = dbnameid ? dbnameid.split("_")[1] : $(numBox).attr("dbname").split("_")[1];
        var priceAfterTaxClone = $("#priceIncludeTax_" + rowinx).val() * 1 * $("#discount_" + rowinx).val() * 1;
        priceAfterTaxClone = bill.FormatNumber(priceAfterTaxClone + "", pricestore);
        $('span[showdbname="priceAfterTaxClone_' + rowinx + '"]').html(priceAfterTaxClone);
    }
    var v = $("#" + currDBName).val() * 1;
    var num1 = $("#num1").val() * 1;
    var pricejy = $("#pricejy").val() * 1;
    var tpricejy = $("#tpricejy").val() * 1;
    var price1 = $("#price1").val() * 1;

    var discount = $("#discount").val() * 1;
    var priceAfterDiscount = $("#priceAfterDiscount").val() * 1;
    var moneyBeforeTax = $("#moneyBeforeTax").val() * 1;
    var priceIncludeTax = $("#priceIncludeTax").val() * 1;

    var taxRate = $("#taxRate").val() * 1;
    var priceAfterTax = $("#priceAfterTax").val() * 1;

    var taxValue = $("#taxValue").val() * 1;
    var money1 = $("#money1").val() * 1;
    var includeTax = $("#includeTax").val() * 1;
    switch (currDBName) {
        case "pricejy":
            tpricejy = pricejy * num1;
            $("#tpricejy").val(bill.FormatNumber(tpricejy + "", pricesale));
            break;
        case "num1":
            if (formula) {
                var domv = formula.split("=")[0].replace("@", "");
                var backv = formula.split("=")[1];
                var fs = $("input[dbname*='formula_']");
                backv = backv.replace("@num1", num1 * 1);
                for (var i = 0; i < fs.length; i++) {
                    var dbname = new RegExp("\@" + $(fs[i]).attr("dbname"), "g");
                    backv = backv.replace(dbname, ($(fs[i]).val() == "" ? 0 : $(fs[i]).val()));
                }
                $("#" + domv).val(bill.FormatNumber(eval(backv) + "", __currwin.zsml.header.numberbit));
            }

            tpricejy = pricejy * num1;
            $("#tpricejy").val(bill.FormatNumber(tpricejy + "", mBit));

            moneyBeforeTax = priceAfterDiscount * num1;
            $("#moneyBeforeTax").val(bill.FormatRound(moneyBeforeTax + "", mBit));

            money1 = price1 * (1 + taxRate * 0.01) * discount * num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));

            taxValue = priceAfterDiscount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            // $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            break;
        case "price1":
            var priceAfterDiscount = price1 * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            //$("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceIncludeTax = price1 * (1 + taxRate * 0.01);
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricestore));

            var priceAfterTax = price1 * (1 + taxRate * 0.01) * discount;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);
            $("#priceAfterTaxClone").val(priceAfterTax);
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricestore));

            moneyBeforeTax = price1 * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = price1 * (1 + taxRate * 0.01) * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = price1 * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "discount":
            var priceAfterDiscount = price1 * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            //$("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricestore));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricestore));
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricestore));

            moneyBeforeTax = price1 * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = price1 * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "priceIncludeTax":

            var price1 = priceIncludeTax / (1 + taxRate * 0.01);
            price1 = bill.FormatNumber(price1 + "", pricestore);
            $("#price1").val(price1);
            //$("#__bill_field_price1").text(bill.FormatNumber(price1 + "", mBit));

            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricestore));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricestore));
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricestore));

            moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "taxRate":
            if (includeTax == 1) {
                var price1 = priceIncludeTax / (1 + taxRate * 0.01);
                price1 = bill.FormatNumber(price1 + "", pricestore);
                $("#price1").val(price1);

                priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
                $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", mBit));

                moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
                $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

                money1 = priceAfterTax * num1;
                $("#money1").val(bill.FormatNumber(money1 + "", mBit));

                taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
                $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
                //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            } else {
                var priceIncludeTax = price1 * (1 + taxRate * 0.01);
                priceIncludeTax = bill.FormatNumber(priceIncludeTax + "", pricestore);
                $("#priceIncludeTax").val(priceIncludeTax);

                priceAfterTax = price1 * (1 + taxRate * 0.01) * discount;
                $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", mBit));
                $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", mBit));

                moneyBeforeTax = priceAfterDiscount * num1;
                $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

                money1 = price1 * (1 + taxRate * 0.01) * discount * num1;
                $("#money1").val(bill.FormatNumber(money1 + "", mBit));

                taxValue = priceAfterDiscount * num1 * taxRate * 0.01;
                $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
                //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            }
            break;
        case "moneyBeforeTax":
            money1 = moneyBeforeTax * (1 + taxRate * 0.01);
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            priceAfterDiscount = moneyBeforeTax / num1;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            priceAfterTax = moneyBeforeTax * (1 + taxRate * 0.01) / num1;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", mBit));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", mBit));

            price1 = moneyBeforeTax / num1 / discount;
            $("#price1").val(bill.FormatNumber(price1 + "", pricestore));
            //$("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricestore));

            var priceIncludeTax = moneyBeforeTax * (1 + taxRate * 0.01) / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricestore));
            //$("#__bill_field_priceIncludeTax").text(bill.FormatNumber(priceIncludeTax + "", pricestore));

            taxValue = moneyBeforeTax * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "money1":

            moneyBeforeTax = money1 / (1 + taxRate * 0.01);
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            var priceAfterDiscount = money1 / (1 + taxRate * 0.01) / num1;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceAfterTax = money1 / num1;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);
            $("#priceAfterTaxClone").val(priceAfterTax);

            price1 = money1 / (1 + taxRate * 0.01) / num1 / discount;
            $("#price1").val(bill.FormatNumber(price1 + "", pricestore));
            $("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricestore));

            priceIncludeTax = money1 / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", mBit));

            taxValue = money1 / (1 + taxRate * 0.01) * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            break;
        case "yhmoney":
            var money1sumv = $("#premoney").val();
            var yhmoney = $("#yhmoney").val();
            $("#yhmoney").val(bill.FormatNumber(yhmoney * 1, mBit));
            var money1 = bill.FormatNumber(money1sumv * 1 - yhmoney * 1, mBit);
            $("#lay_money1").html(money1);
            $("#zk").val(bill.FormatNumber(1, mBit));
            $("#money1").val(money1);
            break;
        case "zk":
            var money1sumv = $("#premoney").val();
            var zk = $("#zk").val();
            $("#zk").val(bill.FormatNumber(zk * 1, mBit));
            var money1 = bill.FormatNumber(money1sumv * 1 * zk * 1, mBit);
            $("#lay_money1").html(money1);
            $("#yhmoney").val(bill.FormatNumber(money1sumv - money1, mBit));
            $("#money1").val(money1);
            break;
        default:
            if (formula) {
                var domv = formula.split("=")[0].replace("@", "");
                var backv = formula.split("=")[1];
                var fs = $("input[dbname*='formula_']");
                for (var i = 0; i < fs.length; i++) {
                    var dbname = new RegExp("\@" + $(fs[i]).attr("dbname"), "g");
                    backv = backv.replace(dbname, ($(fs[i]).val() == "" ? 0 : $(fs[i]).val()));
                }
                if (backv.indexOf("num1") > 0) {
                    var dbname = new RegExp("\@num1", "g");
                    backv = backv.replace(dbname, num1);
                }
                $("#" + domv).val(bill.FormatNumber(eval(backv) + "", __currwin.zsml.header.numberbit));
                HandleFieldFormul(domv, mBit);
            }
            break;
    }
}



function mesage() {
    $("#meessg_0").text("折扣必须控制在0-1.5之间");
}


