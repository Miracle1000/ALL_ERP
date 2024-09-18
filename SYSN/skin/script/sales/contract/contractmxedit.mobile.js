window.HandleFieldFormul = function(currDBName, mBit,formula) {
	console.log(currDBName)  //taxValue  moneyBeforeTax  hidden 
	/*
	 * 数量       			 num1
	 * 建议进价			 pricejy
	 * 建议总价			 tpricejy 
	 * 未税单价			 price1
	 * 折扣				 discount
	 * 未税折后单价		 priceAfterDiscount
	 * 含税单价			 priceIncludeTax
	 * 含税折后单价  		 priceAfterTax
	 * 税前总价			 moneyBeforeTax
	 * 税额				 taxValue
	 * 产品总价			 money1
	 */
	var pricesale = __currwin.zsml.header.pricebit.sale;
    var v =  $("#"+currDBName).val()*1;
    var includeTax = $("#includeTax").val()*1;
    var taxValue = $("#taxValue").val()*1;
	var pricejy = $("#pricejy").val()*1;
	var num1 = $("#num1").val()*1;
	var price1 = $("#price1").val()*1;
	var priceAfterDiscount = $("#priceAfterDiscount").val()*1;
	var discount = $("#discount").val() * 1;
	var priceAfterTaxPre = $("#priceAfterTaxPre").val() * 1;
	var priceAfterTax = $("#priceAfterTax").val()*1;
	var taxRate = $("#taxRate").val()*1;
	var priceIncludeTax = $("#priceIncludeTax").val()*1; 
	var moneyBeforeTax = $("#moneyBeforeTax").val() * 1;
	var moneyAfterTax = $("#moneyAfterTax").val() * 1;
	var moneyAfterConcessions = $("#moneyAfterConcessions").val() * 1;  
	var concessions = $("#concessions").val() * 1;
	var money1 = $("#money1").val()*1;
    switch (currDBName) {
        case "pricejy":
            $("#tpricejy").val(pricejy*num1);
            $("#__bill_field_tpricejy").text(bill.FormatNumber(pricejy*num1+"",mBit));
            break;
        case "num1":
			if(formula){
				var domv = formula.split("=")[0].replace("@","");
				var backv = formula.split("=")[1];
				var fs = $("input[dbname*='formula_']");
				backv = backv.replace("@num1",num1*1);
				for(var i = 0; i<fs.length; i++){
					var dbname =new RegExp("\@"+ $(fs[i]).attr("dbname"),"g");
					backv = backv.replace(dbname,($(fs[i]).val()==""?0:$(fs[i]).val()));
				}
				$("#" + domv).val(bill.FormatNumber(eval(backv) + "", __currwin.zsml.header.numberbit));
			}
            var tpricejy = pricejy*num1;
			$("#tpricejy").val(bill.FormatNumber(tpricejy+"",mBit));
			$("#__bill_field_tpricejy").text(bill.FormatNumber(pricejy * num1 + "", mBit));

            var moneyBeforeTax = price1 * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

			var money1 = priceIncludeTax * discount * num1;
			$("#money1").val(bill.FormatNumber(money1 + "", mBit));
			$("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
			var moneyAfterConcessions = (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));

			taxValue = priceIncludeTax * discount * num1 - (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue+"",mBit));
            break;
        case "price1":
            var priceAfterDiscount = price1*discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var priceIncludeTax = v * (1 + taxRate * 0.01);
            $("#priceIncludeTax").val(bill.FormatNumber(priceIncludeTax + "", pricesale));

            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

            var moneyBeforeTax = priceAfterDiscount*num1;
			$("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax+"",mBit));
            
            $("#__bill_field_tpricejy").text(bill.FormatNumber(pricejy*num1+"",mBit));

            var money1 = priceAfterTax*num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            $("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
            var moneyAfterConcessions = (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
            $("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));

            taxValue = priceIncludeTax * discount * num1 - (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue+"",mBit));
            break;
        case "discount":
            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            var priceAfterTax = priceIncludeTax * discount;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var moneyBeforeTax = priceAfterDiscount*num1;
			$("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax+"",mBit));
            
			var money1 = priceIncludeTax * discount * num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            $("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
            var moneyAfterConcessions = (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
            $("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));

            taxValue = priceIncludeTax * discount * num1 - (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue+"",mBit));
            break;
        case "priceIncludeTax":
            var price1 =  v/(1+ taxRate* 0.01);
            $("#price1").val(bill.FormatNumber(price1 + "", pricesale));

            var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var moneyBeforeTax = priceIncludeTax / (1 + taxRate * 0.01) * discount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

            var priceAfterTax = priceIncludeTax*discount;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

            var money1 = priceAfterTax*num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            $("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
            var moneyAfterConcessions = (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
            $("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));

            taxValue = priceIncludeTax * discount * num1 - (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue+"",mBit));
            break;
        case "taxRate":

            var price1 = priceIncludeTax/(1+v*0.01);
			$("#price1").val(bill.FormatNumber(price1+"",pricesale));
			var priceAfterDiscount = priceIncludeTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricesale));

            var moneyBeforeTax = priceAfterDiscount * num1;
            $("#moneyBeforeTax").val(bill.FormatNumber(moneyBeforeTax + "", mBit));

			var priceAfterTax = priceIncludeTax * discount;
			$("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
			$("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
			$("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

			var money1 = priceAfterTax * num1;
			$("#money1").val(bill.FormatNumber(money1 + "", mBit));
			$("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
			var moneyAfterConcessions = (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));

			taxValue = priceIncludeTax * discount * num1 - (priceIncludeTax * discount * num1) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue+"",mBit));
            break;
        case "moneyAfterTax":
            $("#money1").val(bill.FormatRound(moneyAfterTax + "", mBit));
            var priceAfterTax = moneyAfterTax / num1;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));

            var moneyAfterConcessions = moneyAfterTax / (1 + taxRate * 0.01);
            $("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));
            taxValue = moneyAfterTax - moneyAfterTax / (1 + taxRate * 0.01);
            $("#taxValue").text(bill.FormatRound(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatRound(taxValue + "", mBit));

            priceIncludeTax = moneyAfterTax / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatRound(priceIncludeTax + "", pricesale));

            price1 = moneyAfterTax / num1 / discount / (1 + taxRate * 0.01);
            $("#price1").val(bill.FormatRound(price1 + "", pricesale));

            moneyBeforeTax = moneyAfterTax / (1 + taxRate * 0.01);
            $("#moneyBeforeTax").val(bill.FormatRound(moneyBeforeTax + "", mBit));

            var priceAfterDiscount = moneyAfterTax / num1 / (1 + taxRate * 0.01);
            $("#priceAfterDiscount").val(bill.FormatRound(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatRound(priceAfterDiscount + "", pricesale));
            break;
        case "moneyAfterConcessions":		//金额发生更改
            var money1 = moneyAfterConcessions * (1 + taxRate * 0.01)
            $("#money1").val(bill.FormatRound(money1 + "", mBit));
            $("#moneyAfterTax").val(bill.FormatNumber(money1 + "", mBit));
            var priceAfterTax = money1 / num1;
            $("#priceAfterTaxPre").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTaxPre").text(bill.FormatNumber(priceAfterTax + "", pricesale));
            $("#priceAfterTax").val(bill.FormatNumber(priceAfterTax + "", pricesale));
            taxValue = money1 - moneyAfterConcessions;
            $("#taxValue").val(bill.FormatRound(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatRound(taxValue + "", mBit));

            priceAfterDiscount = money1 / num1 / (1 + taxRate * 0.01);
            $("#priceAfterDiscount").val(bill.FormatRound(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatRound(priceAfterDiscount + "", pricesale));

            priceAfterTax = money1 / num1;
            $("#priceAfterTax").val(bill.FormatRound(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTax").text(bill.FormatRound(priceAfterTax + "", pricesale));

            price1 = money1 / num1 / discount / (1 + taxRate * 0.01)
            $("#price1").val(bill.FormatRound(price1 + "", pricesale));
            priceIncludeTax = money1 / num1 / discount;
            $("#priceIncludeTax").val(bill.FormatRound(priceIncludeTax + "", pricesale));
            
            moneyBeforeTax = money1 / (1 + taxRate * 0.01);
            $("#moneyBeforeTax").val(bill.FormatRound(moneyBeforeTax + "", mBit));
            break;
        case "moneyBeforeTax":		//税前总价发生更改
            var money1 = v * (1 + taxRate * 0.01)
            $("#money1").val(bill.FormatRound(money1 + "", mBit));
            priceAfterDiscount = v / num1;
            $("#priceAfterDiscount").val(bill.FormatRound(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatRound(priceAfterDiscount + "", pricesale));

            priceAfterTax = money1 / num1;
            $("#priceAfterTax").val(bill.FormatRound(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTax").text(bill.FormatRound(priceAfterTax + "", pricesale));

            price1 = priceAfterDiscount / discount
            $("#price1").val(bill.FormatRound(price1 + "", pricesale));
            priceIncludeTax = priceAfterTax / discount
            $("#priceIncludeTax").val(bill.FormatRound(priceIncludeTax + "", pricesale));
            taxValue = v * taxRate * 0.01
            $("#taxValue").val(bill.FormatRound(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatRound(taxValue + "", mBit));
            break;
        case "money1":
            moneyBeforeTax = v / (1 + taxRate * 0.01)
            $("#moneyBeforeTax").val(bill.FormatRound(moneyBeforeTax + "", mBit));
            var priceAfterDiscount = moneyBeforeTax / num1;
            $("#priceAfterDiscount").val(bill.FormatRound(priceAfterDiscount + "", pricesale));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatRound(priceAfterDiscount + "", pricesale));

            var priceAfterTax = v / num1;
            $("#priceAfterTax").val(bill.FormatRound(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTax").text(bill.FormatRound(priceAfterTax + "", pricesale));

            price1 = priceAfterDiscount / discount
            $("#price1").val(bill.FormatRound(price1 + "", pricesale));
            priceIncludeTax = priceAfterTax / discount
            $("#priceIncludeTax").val(bill.FormatRound(priceIncludeTax + "", pricesale));
            taxValue = v * taxRate * 0.01
            $("#taxValue").text(bill.FormatRound(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatRound(taxValue + "", mBit));
            break;
        case "concessions":
            var moneyAfterConcessions = ((priceIncludeTax * discount * num1) / (1 + taxRate * 0.01)) - concessions;
            $("#moneyAfterConcessions").val(bill.FormatNumber(moneyAfterConcessions + "", mBit));
            var money1 = (priceIncludeTax * discount * num1) - concessions;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            var priceAfterTax = money1 / num1;
            $("#priceAfterTax").val(bill.FormatRound(priceAfterTax + "", pricesale));
            $("#__bill_field_priceAfterTax").text(bill.FormatRound(priceAfterTax + "", pricesale));
            taxValue = money1 - moneyAfterConcessions;
            $("#taxValue").val(bill.FormatRound(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatRound(taxValue + "", mBit));

            break;
        default:
			if(formula){
				var domv = formula.split("=")[0].replace("@","");
				var backv = formula.split("=")[1];
				var fs = $("input[dbname*='formula_']");
				for(var i = 0; i<fs.length; i++){
					var dbname =new RegExp("\@"+ $(fs[i]).attr("dbname"),"g");
					backv = backv.replace(dbname,($(fs[i]).val()==""?0:$(fs[i]).val()));
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