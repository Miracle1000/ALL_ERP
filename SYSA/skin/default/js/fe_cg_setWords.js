function saveWord(date1,typ)
{	//'BUG 6578 Sword 2014-12-10 凭证字相关bug 
	var status = "设置";
	if (typ==1){status = "重置";}
	var words = $("select:[name=VoucherWord][d="+date1+"]").val();
	ajax.regEvent("setWord")
	ajax.addParam('date1', date1);
	ajax.addParam('typ', typ);
	ajax.addParam('words', words);
	ajax.send(function(r){
		 if (r == "1") {
			app.Alert(status + "成功");
			lvw_refresh('mlistvw');
		 }
		 else
		 {
			if (r=="0")
			{		
				app.Alert("不能"+ status +"该月凭证字");
				lvw_refresh('mlistvw');
			}
		 }
	});
}