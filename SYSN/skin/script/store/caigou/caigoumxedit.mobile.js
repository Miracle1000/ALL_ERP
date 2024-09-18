window.HandleFieldFormul = function (currDBName, mBit, formula) {
    console.log(currDBName)
    //taxValue           moneyAfterDiscount  hidden
	/*
	 * 开单数量          num1       
	 * 建议进价			 pricejy
	 * 未税单价			 price1
	 * 折扣				 discount
	 * 未税折后单价		 priceAfterDiscount
     * 税率				 taxRate
	 * 含税单价			 priceAfterTax
     * 含税折后单价  	 priceAfterDiscountTaxPre
     * 税后总价          TaxDstMoney
     * 明细优惠          Concessions
     * 优惠后单价  	     priceAfterDiscountTax
     * 金额              moneyAfterDiscount
	 * 税额				 taxValue
	 * 优惠后总价		 money1
	 */
	var pricestore = __currwin.zsml.header.pricebit.store;
    var v =  $("#"+currDBName).val()*1;
    var includeTax = $("#includeTax").val()*1;
    var num1 = $("#num1").val() * 1;
	var pricejy = $("#pricejy").val()*1;
	var price1 = $("#price1").val() * 1;

	var discount = $("#discount").val() * 1;
	var priceAfterDiscount = $("#priceAfterDiscount").val() * 1;

	var taxRate = $("#taxRate").val() * 1;
	var priceAfterTax = $("#priceAfterTax").val() * 1;
	var priceAfterDiscountTaxPre = $("#priceAfterDiscountTaxPre").val() * 1;
	var TaxDstMoney = $("#TaxDstMoney").val() * 1;

	var Concessions = $("#Concessions").val() * 1;
	var priceAfterDiscountTax = $("#priceAfterDiscountTax").val() * 1;
	var moneyAfterDiscount = $("#moneyAfterDiscount").val() * 1;
	var taxValue = $("#taxValue").val() * 1;
	var money1 = $("#money1").val() * 1;
    switch (currDBName) {
        case "pricejy":
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
			}/*
            税后总价=含税单价*折扣*数量,
			明细优惠=@@手动录入,
			优惠后总价=(含税单价*折扣*数量)-明细优惠,
			金额=((含税单价*折扣*数量)-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			优惠后单价=(含税单价*折扣*数量-明细优惠)/数量,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
			TaxDstMoney = priceAfterTax * discount * num1;
			$("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));
       
			money1 = priceAfterTax * discount * num1 - Concessions;
			$("#money1").val(bill.FormatNumber(money1 + "", mBit));
			moneyAfterDiscount = ((priceAfterTax * discount * num1) - Concessions) / (1 + taxRate * 0.01)
			$("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

			taxValue = (priceAfterTax * discount * num1 - Concessions) - (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01);
			$("#taxValue").val(bill.FormatNumber(taxValue+"",mBit));
			$("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

			priceAfterDiscountTax = (priceAfterTax * discount * num1 - Concessions) / num1;
			$("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
			$("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            break;
        case "price1":
            /*
            未税折后单价=未税单价*折扣,
			含税单价=未税单价*(1+税率*0.01),
			含税折后单价=含税单价*折扣,
			税后总价=含税单价*折扣*数量,
			明细优惠=@@手动录入,
			优惠后总价=(含税单价*折扣*数量)-明细优惠,
			金额=(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			优惠后单价=(含税单价*折扣*数量-明细优惠)/数量,
			优惠最大值=税后总价,
			优惠提示语='不能大于'+税后总价
            */
            var priceAfterDiscount = price1 * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceAfterTax = v * (1 + taxRate * 0.01);
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);

            var priceAfterDiscountTaxPre = priceAfterTax*discount;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            TaxDstMoney = priceAfterTax * discount * num1;
            $("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));

            money1 = priceAfterTax * discount * num1 - Concessions;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            moneyAfterDiscount = ((priceAfterTax * discount * num1) - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

            taxValue = (priceAfterTax * discount * num1 - Concessions) - (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            priceAfterDiscountTax = (priceAfterTax * discount * num1 - Concessions) / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            break;
        case "discount":
            /*
            未税折后单价=含税单价/(1+税率*0.01)*折扣,
			含税折后单价=含税单价*折扣,
			税后总价=含税单价*折扣*数量,
			明细优惠=@@手动录入,
			优惠后总价=(含税单价*折扣*数量)-明细优惠,
			金额=(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			优惠后单价=(含税单价*折扣*数量-明细优惠)/数量,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
             */
            var priceAfterDiscount = priceAfterTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            var priceAfterDiscountTaxPre = priceAfterTax * discount;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            TaxDstMoney = priceAfterTax * discount * num1;
            $("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));

            money1 = priceAfterTax * discount * num1 - Concessions;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            moneyAfterDiscount = ((priceAfterTax * discount * num1) - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

            taxValue = (priceAfterTax * discount * num1 - Concessions) - (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            priceAfterDiscountTax = (priceAfterTax * discount * num1 - Concessions) / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            break;
        case "priceAfterTax":
            /*
            含税折后单价=含税单价*折扣,
			未税单价=含税单价/(1+税率*0.01),
			未税折后单价=含税单价/(1+税率*0.01)*折扣,
			税后总价=含税单价*折扣*数量,
			明细优惠=@@手动录入,
			优惠后总价=(含税单价*折扣*数量)-明细优惠,
			金额=(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			优惠后单价=(含税单价*折扣*数量-明细优惠)/数量,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
            var price1 = v /(1 + taxRate * 0.01);
            price1 = bill.FormatNumber(price1 + "", pricestore);
            $("#price1").val(price1);
            $("#__bill_field_price1").text(bill.FormatNumber(price1 + "", mBit));

            var priceAfterDiscountTaxPre = priceAfterTax * discount;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            var priceAfterDiscount = priceAfterTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            TaxDstMoney = priceAfterTax * discount * num1;
            $("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));

            money1 = priceAfterTax * discount * num1 - Concessions;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
            moneyAfterDiscount = ((priceAfterTax * discount * num1) - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));
            taxValue = (priceAfterTax * discount * num1 - Concessions) - (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            priceAfterDiscountTax = (priceAfterTax * discount * num1 - Concessions) / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            break;
        case "taxRate":
            /*
            税后总价=@@不变,
			含税折后单价=@@不变,
			明细优惠=@@手动录入,
			优惠后总价=@@不变,
			优惠后单价=@@不变,
			金额=(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			未税单价=含税单价/(1+税率*0.01),
			未税折后单价=含税单价/(1+税率*0.01)*折扣,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
            moneyAfterDiscount = ((priceAfterTax * discount * num1) - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

            taxValue = (priceAfterTax * discount * num1 - Concessions) - (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            var price1 = priceAfterTax / (1 + taxRate * 0.01);
            price1 = bill.FormatNumber(price1 + "", pricestore);
            $("#price1").val(price1);

            var priceAfterDiscount = priceAfterTax / (1 + taxRate * 0.01) * discount;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            break;
        case "TaxDstMoney":
            /*
            明细优惠=@@手动录入,
			优惠后总价=税后总价-明细优惠,
			优惠后单价=(税后总价-明细优惠)/数量,
			金额=(税后总价-明细优惠)/(1+税率*0.01),
			税额=(税后总价-明细优惠)-(税后总价-明细优惠)/(1+税率*0.01),
			含税折后单价=税后总价/数量,
			含税单价=税后总价/数量/折扣,
			未税单价=税后总价/数量/折扣/(1+税率*0.01),
			未税折后单价=税后总价/数量/(1+税率*0.01),
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
           */
            money1 = TaxDstMoney - Concessions;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));

            var priceAfterDiscountTax = (TaxDstMoney - Concessions) / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));

            moneyAfterDiscount = (TaxDstMoney - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

            taxValue = (TaxDstMoney - Concessions) - (TaxDstMoney - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            var priceAfterDiscountTaxPre = TaxDstMoney/num1;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            var priceAfterTax = TaxDstMoney/num1 / discount;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);

            price1 = TaxDstMoney / num1 / discount / (1 + taxRate * 0.01);
            $("#price1").val(bill.FormatNumber(price1 + "", pricestore));
            $("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricestore));

            var priceAfterDiscount = TaxDstMoney / num1 / (1 + taxRate * 0.01) ;
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            break;
        case "Concessions":
            /*
            税后总价=@@不变,
			优惠后总价=(含税单价*折扣*数量)-明细优惠,
			优惠后单价=(含税单价*折扣*数量-明细优惠)/数量,
			金额=(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			税额=(含税单价*折扣*数量-明细优惠)-(含税单价*折扣*数量-明细优惠)/(1+税率*0.01),
			含税折后单价=@@不变,
			含税单价=@@不变,
			未税折后单价=@@不变,
			未税单价=@@不变,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
            money1 = bill.FormatNumber(priceAfterTax * discount * num1 - Concessions + "", mBit);
            $("#money1").val(money1 );

            var priceAfterDiscountTax = (priceAfterTax * discount * num1 - Concessions) / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));

            moneyAfterDiscount = (priceAfterTax * discount * num1 - Concessions) / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));

            taxValue = (priceAfterTax * discount * num1 - Concessions) - (TaxDstMoney - Concessions) / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            break;
        case "moneyAfterDiscount":
            /*
            优惠后总价=金额*(1+税率*0.01),
			优惠后单价=优惠后总价/数量,
			税额=优惠后总价-金额,
			明细优惠=@@手动录入,
			税后总价=优惠后总价*1+明细优惠*1,

			含税折后单价=(优惠后总价*1+明细优惠*1)/数量,
			含税单价=(优惠后总价*1+明细优惠*1)/数量/折扣,
			未税单价=(优惠后总价*1+明细优惠*1)/数量/折扣/(1+税率*0.01),
			未税折后单价=(优惠后总价*1+明细优惠*1)/数量/(1+税率*0.01),
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
            var money1 = parseFloat(bill.FormatNumber(v * (1 + taxRate * 0.01) + "", mBit));
            $("#money1").val(money1);

            var priceAfterDiscountTax = money1 / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));

            taxValue = money1 - v;
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));
            
            TaxDstMoney = money1 + Concessions;
            $("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));

            var priceAfterDiscountTaxPre = (money1 + Concessions)/num1;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            var priceAfterTax = (money1 + Concessions) / num1 / discount;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);

            price1 = (money1 + Concessions) / num1 / discount / (1 + taxRate * 0.01);
            $("#price1").val(bill.FormatNumber(price1 + "", pricestore));

            var priceAfterDiscount = (money1 + Concessions) / num1 / (1 + taxRate * 0.01);
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            break
        case "money1":
            /*
            优惠后单价=优惠后总价/数量,
			明细优惠=@@手动录入,
			税后总价=优惠后总价*1+明细优惠*1,
			含税折后单价=(优惠后总价*1+明细优惠*1)/数量,
			含税单价=(优惠后总价*1+明细优惠*1)/数量/折扣,
			金额=优惠后总价/(1+税率*0.01),
			税额=优惠后总价-优惠后总价/(1+税率*0.01),
			未税折后单价=(优惠后总价*1+明细优惠*1)/数量/(1+税率*0.01),
			未税单价=(优惠后总价*1+明细优惠*1)/数量/(1+税率*0.01)/折扣,
			优惠最大值=优惠后总价,
			优惠提示语='不能大于'+税后总价
            */
            var priceAfterDiscountTax = money1 / num1;
            $("#priceAfterDiscountTax").val(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));
            $("#__bill_field_priceAfterDiscountTax").text(bill.FormatNumber(priceAfterDiscountTax + "", pricestore));

            TaxDstMoney = money1 + Concessions;
            $("#TaxDstMoney").val(bill.FormatNumber(TaxDstMoney + "", mBit));

            var priceAfterDiscountTaxPre = (money1 + Concessions) / num1;
            $("#priceAfterDiscountTaxPre").val(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));
            $("#__bill_field_priceAfterDiscountTaxPre").text(bill.FormatNumber(priceAfterDiscountTaxPre + "", pricestore));

            var priceAfterTax = (money1 + Concessions) / num1 / discount;
            priceAfterTax = bill.FormatNumber(priceAfterTax + "", pricestore);
            $("#priceAfterTax").val(priceAfterTax);

            moneyAfterDiscount = money1 / (1 + taxRate * 0.01)
            $("#moneyAfterDiscount").val(bill.FormatNumber(moneyAfterDiscount + "", mBit));
            taxValue = money1 - money1 / (1 + taxRate * 0.01);
            $("#taxValue").val(bill.FormatNumber(taxValue + "", mBit));
            $("#__bill_field_taxValue").text(bill.FormatNumber(taxValue + "", mBit));

            var priceAfterDiscount = (money1 + Concessions) / num1 / (1 + taxRate * 0.01);
            $("#priceAfterDiscount").val(bill.FormatNumber(priceAfterDiscount + "", pricestore));
            $("#__bill_field_priceAfterDiscount").text(bill.FormatNumber(priceAfterDiscount + "", pricestore));

            price1 = (money1 + Concessions) / num1/ (1 + taxRate * 0.01) / discount ;
            $("#price1").val(bill.FormatNumber(price1 + "", pricestore));
            $("#__bill_field_price1").text(bill.FormatNumber(price1 + "", pricestore));
            break;
        default:
            if (formula) {
		        var domv = formula.split("=")[0].replace("@", "");
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