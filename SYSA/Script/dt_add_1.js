
	function change(){
	  $ID("mxh1").style.display="none";
	  $ID("shortSec").value=2;
	}
	function change1(){
		$ID("mxh1").style.display="inline";
		secShortDate();
	}

	function secShortDate(){
		var beginDate=$ID("date3").value;
		var endDate=$ID("date4").value;
		if(beginDate!="" && endDate!=""){
			$ID("shortSec").value=2;
			var d1 = new Date(beginDate.replace(/\-/g, "\/"));
			var d2 = new Date(endDate.replace(/\-/g, "\/"));
			if(d1>=d2){
				$ID("shortSec").value=1;
				$ID("shortSec").setAttribute("msg","开始时间不能大于或等于结束时间");
			}
		}else{
			$ID("shortSec").value=1;
			$ID("shortSec").setAttribute("msg","选择起止日期");
		}
	}

	// --列头全选框被单击---
	function ChkAllClick(sonName, cbAllId){
		var arrSon = document.getElementsByName(sonName);
	 var cbAll = document.getElementById(cbAllId);
	 var tempState=cbAll.checked;
	 for(i=0;i<arrSon.length;i++) {
	  if(arrSon[i].checked!=tempState)
			   arrSon[i].click();
	 }
	}
	//清理页面

	function restbon(){
	  //$ID("mxh1").style.display="none";

	  $ID("title").value = "";
	  $ID("intro").value = "";
	  $ID("C_Level").selectedIndex  = 0;
	  if ($ID("validity") == 1){
	  	  $ID("shortSec").value=1;}
		  if ($ID("validity") == 2)
		  {
		  	  $ID("shortSec").value=2;}
		//mysel(0);FnUserOrd(0,'bm');
	}
	
