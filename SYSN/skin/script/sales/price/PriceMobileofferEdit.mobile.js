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