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
    if (closeWinhwnd.indexOf("_pricemobilebillscan") == -1 && closeWinhwnd.indexOf("geproductbilllistasp") == -1 && closeWinhwnd.indexOf("_pricemobilebilledit") == -1) { return; }
    $ID("childrefreshEventbox").value = 0;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});

function curPageDatesSave() {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
}

window.SaveDatesBeforeAtuoCom = function () {
    curPageDatesSave();
}

//报价添加底部结算按钮
window.onBeforePageInit = function () {
    var currweb = plus.webview.currentWebview();
    var zsml = currweb.zsml;
    var jbill = zsml.body.bill;
    var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
    if (scanfbtn) {
        if (__currwin.url.indexOf("&view=details") > -1) return;
        scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;'><div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>"
            + "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div></div>";
        setTimeout(function () {
            var h = document.documentElement.offsetHeight;
            $("#page-content").css("height", h - 100);
        }, 300)
    }
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
    el.setAttribute("url", info.hosturl + "/mobilephone/salesManage/product/billlist.asp?fromtype=pricebill&company=" + company + "&invoiceType=" + invoiceType);
    ui.CZSMLPage(el);
}
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
    el.setAttribute("url", "PriceMobileBillScan.ashx?fromtype=pricebill&company=" + company + "&invoiceType=" + invoiceType);
    setTimeout(function () { ui.CZSMLPage(el); }, 300);
}

////清空按钮
//window.createBtnForSpecGroup = function (btn) {
//    return "<div class='bill_txt' onclick='window.clearBtn(this);' action='SysBillCallBack' url='ClearAllCaiGouMxList'  target='" + (btn.target || "") + "' >" + btn.title + "</div>"
//}
window.HandleFieldFormul = function (currDBName, mBit, formula, isMainPage, numBox) {
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
    var pricesale = __currwin.zsml.header.pricebit.sale;
    var ratebit = __currwin.zsml.header.ratebit;
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
    var priceAfterTaxClone = $("#priceAfterTaxClone").val() * 1;

    var taxValue = $("#taxValue").val() * 1;
    var money1 = $("#money1").val() * 1;
    var includeTax = $("#includeTax").val() * 1;
    if (isMainPage) {
        var dbnameid = $(window.event.target).attr("dbname");
        var rowinx = dbnameid ? dbnameid.split("_")[1] : $(numBox).attr("dbname").split("_")[1] ;
        num1 = $("[dbname=num1_" + rowinx + "]").val();
        priceAfterTax = $("[dbname=priceAfterTax_" + rowinx + "]").val();
        //for (let key in window) {
        //    if (key.indexOf("LVW") == 0) {
        //        var lvw = window[key];
        //        break;
        //    }
        //}
        var lvw = window[this.dbsignID]
        if (lvw) {
            var rows = lvw.rows;
            var hd = lvw.headers;
            var variable = "pricejy,tpricejy,price1,discount,priceAfterDiscount,moneyBeforeTax,priceIncludeTax,taxRate,priceAfterTax,priceAfterTaxClone,taxValue,money1,includeTax,id".split(",");
            var varr = [];
            for (var i = 0; i < variable.length; i++) {
                var vname = variable[i];
                varr[vname + "Inx"] = -1;
                for (var j = 0; j < hd.length; j++) {
                    if (hd[j].dbname == vname) {
                        varr[vname + "Inx"] = j;
                        eval(" " + vname + " = " + rows[rowinx][j]);
                        break;
                    }
                }
            }
        }
    }
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
            $("#tpricejy").val(bill.FormatNumber(tpricejy + "", pricesale));
            moneyBeforeTax = priceAfterDiscount * num1;
            $("#moneyBeforeTax").val(bill.FormatRound(moneyBeforeTax + "", mBit));
            money1 = priceAfterTax * num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            taxValue = priceAfterDiscount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            // $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            if (isMainPage && lvw) {
                rows[rowinx][varr["tpricejyInx"]] = bill.FormatNumber(tpricejy + "", pricesale);
                rows[rowinx][varr["moneyBeforeTaxInx"]] = bill.FormatRound(moneyBeforeTax + "", mBit);
                rows[rowinx][varr["money1Inx"]] = bill.FormatNumber(money1 + "", mBit);
                rows[rowinx][varr["taxValueInx"]] = bill.FormatNumber(taxValue + "", mBit);
            }
            break;
        case "price1":
            var priceAfterDiscount = price1 * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            //$("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var priceIncludeTax = price1 * (1 + taxRate * 0.01);
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricesale));

            var priceAfterTax = price1 * (1 + taxRate * 0.01) * discount;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricesale);
            $("#priceAfterTax").val(priceAfterTax);
            $("#priceAfterTaxClone").val(priceAfterTax);
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricesale));

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
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            //$("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricesale));

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
            price1 = bill.FormatNumber(price1 + "", pricesale);
            $("#price1").val(price1);
            //$("#__bill_field_price1").text(bill.FormatNumber(price1 + "", mBit));

            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            //$("#__bill_field_priceAfterTax").text(bill.FormatNumber(priceAfterTax + "", pricesale));

            moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "priceAfterTax":
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            var priceIncludeTax = priceAfterTax / discount;
            priceIncludeTax = bill.FormatNumber(priceIncludeTax + "", pricesale);
            $("#priceIncludeTax").val(priceIncludeTax);

            var price1 = priceIncludeTax / (1 + taxRate * 0.01);
            price1 = bill.FormatNumber(price1 + "", pricesale);
            $("#price1").val(price1);

            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            if (isMainPage && lvw) {
                rows[rowinx][varr["priceAfterTaxCloneInx"]] = bill.FormatNumber(priceAfterTax + "", pricesale);
                rows[rowinx][varr["priceIncludeTaxInx"]] = priceIncludeTax;
                rows[rowinx][varr["price1Inx"]] = price1;
                rows[rowinx][varr["priceAfterDiscountInx"]] = bill.FormatNumber(priceAfterDiscount + "", pricesale);
                rows[rowinx][varr["moneyBeforeTaxInx"]] = bill.FormatNumber(moneyBeforeTax + "", pricesale);
                rows[rowinx][varr["money1Inx"]] = bill.FormatRound(money1 + "", mBit);
                rows[rowinx][varr["taxValueInx"]] = bill.FormatNumber(taxValue + "", mBit);
            }
            break;
        case "priceAfterTaxClone":
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTaxClone + "", pricesale));
            var priceIncludeTax = priceAfterTaxClone / discount;
            priceIncludeTax = bill.FormatNumber(priceIncludeTax + "", pricesale);
            $("#priceIncludeTax").val(priceIncludeTax);

            var price1 = priceIncludeTax / (1 + taxRate * 0.01);
            price1 = bill.FormatNumber(price1 + "", pricesale);
            $("#price1").val(price1);

            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatRound(money1 + "", mBit));

            taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "taxRate":
            if (includeTax == 1) {
                var price1 = priceIncludeTax / (1 + taxRate * 0.01);
                price1 = bill.FormatNumber(price1 + "", pricesale);
                $("#price1").val(price1);

                priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
                $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));

                moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
                $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

                money1 = priceAfterTax * num1;
                $("#money1").val(bill.FormatNumber(money1 + "", mBit));

                taxValue = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1 * taxRate * 0.01;
                $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
                //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            } else {
                var priceIncludeTax = price1 * (1 + taxRate * 0.01);
                priceIncludeTax = bill.FormatNumber(priceIncludeTax + "", pricesale);
                $("#priceIncludeTax").val(priceIncludeTax);

                priceAfterTax = price1 * (1 + taxRate * 0.01) * discount;
                $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));
                $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricesale));

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
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            priceAfterTax = moneyBeforeTax * (1 + taxRate * 0.01) / num1;
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTaxClone").val(bill.FormatNumber(priceAfterTax + "", pricesale));

            price1 = moneyBeforeTax / num1 / discount;
            $("#price1").val(bill.FormatNumber(price1 + "", pricesale));
            //$("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricesale));

            var priceIncludeTax = moneyBeforeTax * (1 + taxRate * 0.01) / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricesale));
            //$("#__bill_field_priceIncludeTax").text(bill.FormatNumber(priceIncludeTax + "", pricesale));

            taxValue = moneyBeforeTax * taxRate * 0.01;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            //$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "money1":

            moneyBeforeTax = money1 / (1 + taxRate * 0.01);
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            var priceAfterDiscount = money1 / (1 + taxRate * 0.01) / num1;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var priceAfterTax = money1 / num1;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricesale);
            $("#priceAfterTax").val(priceAfterTax);
            $("#priceAfterTaxClone").val(priceAfterTax);

            price1 = money1 / (1 + taxRate * 0.01) / num1 / discount;
            $("#price1").val(bill.FormatNumber(price1 + "", pricesale));
            $("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricesale));

            priceIncludeTax = money1 / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricesale));

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
            $("#zk").val(bill.FormatNumber(1, __currwin.zsml.header.discountbit));
            $("#money1").val(money1);
            break;
        case "zk":
            var money1sumv = $("#premoney").val();
            var zk = $("#zk").val();
            $("#zk").val(bill.FormatNumber(zk * 1, __currwin.zsml.header.discountbit));
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
//继承处理采购结算弹层样式呈现
window.procLayerUiForSpePage = function (bd, lay) {
    var gps = lay.groups;
    bd.push("<div id='layerParForSpe'  onclick='$(this).remove()'>");
    bd.push("<div class='layer' style='display:" + (lay.visible || lay.ui.visible ? "" : "none") + ";width:100%;height:100%;top:0px;border:none;top:-1px;'>");
    if (window.appconfig && window.appconfig.appName == "MoziBox")
    {
        bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:50px;line-height:50px;background-color:#3B3E50;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>");
    }
    else
    {
        bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:50px;line-height:50px;background-color:#075387 ;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>");
    }
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
//采购明细单行明细删除按钮回调事件
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
    var dbsign = $("#MobListView_pricelist").attr("dbsign");
    bill.clearListViewRows(dbsign, true);
}
//获取url中的参数
function getUrlParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
    var r = window.location.search.substr(1).match(reg);  //匹配目标参数
    if (r != null) return unescape(r[2]); return null; //返回参数值
}
//联动更新底部结算信息
window.updateSumForSpcFun = function (lvw, rowindex, dbi, v) {
    var hds = lvw.headers;
    var midx = 0;
    var nidx = 0;
    var pidx = 0;
    for (var i = 0; i < hds.length; i++) {
        if (hds[i].dbname == "money1") { midx = i; }
        if (hds[i].dbname == "num1") { nidx = i; }
        if (hds[i].dbname == "priceAfterTax") { pidx = i; }
    }
    if (hds[dbi].dbname == "priceAfterTax") {
        lvw.rows[rowindex][pidx] = v;
        lvw.rows[rowindex][midx] = v * 1 * (lvw.rows[rowindex][nidx] * 1);
    }
    if (hds[dbi].dbname == "num1") {
        lvw.rows[rowindex][nidx] = v;
        lvw.rows[rowindex][midx] = v * 1 * (lvw.rows[rowindex][pidx] * 1);
    }
}


$(function () {
    try {
        var moneybit = __currwin.zsml.header.moneybit;
        //HandleFieldFormul('num1', moneybit,);
        //HandleFieldFormul('priceAfterTax', moneybit);
    } catch (e) { }

    //点击改变chengenum的值 
    window.AfterCChangeNumValue = function (numbox, val) {
        HandleFieldFormul("num1", __currwin.zsml.header.moneybit, null, true, numbox);
    }
})

