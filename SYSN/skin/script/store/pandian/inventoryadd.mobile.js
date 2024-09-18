window.HandleFieldFormul = function (currDBName, mBit) {
	var num1 = $("#num1").val() * 1;
	var num2 = $("#num2").val() * 1;
	$("#num3").val(bill.FormatNumber(num2 - num1, mBit));
	$("#num3").parent().html(bill.FormatNumber(num2 - num1, mBit) + $("#num3")[0].outerHTML);
}