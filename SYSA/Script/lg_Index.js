
	var FileNum = document.getElementById("FileNum");
	FileNum.value = 0;
	function DoInsert(M0, M1, M2, M3, M4, M5, M6, M7, M8, M9){
		//===============================================================
		// M0 : 文件名称
		// M1 : 扩展名称
		// M2 : 保存路径
		// M3 : MIME类型
		// M4 : 文件大小
		// M5 : 图片宽度
		// M6 : 图片高度
		// M7 : 本地路径
		// M8 : 上传方法 - 在该演示中无效，只在爱学儿图文管理系统中有效
		// M9 : 原文件名
		//===============================================================
		FileNum.value = Math.abs(FileNum.value) + 1;
		InsertOption("M0", M0);
		InsertOption("M1", M1);
		InsertOption("M2", M2);
		InsertOption("M3", M3);
		InsertOption("M4", M4);
		InsertOption("M5", M5);
		InsertOption("M6", M6);
		InsertOption("M7", M7);
		//InsertOption("M8", M8);
		InsertOption("M9", M9);
		var aObj = document.getElementById("oFile");
		aObj.href = M2;
		aObj.innerHTML = M2;
	}
	function InsertOption(sObj, sValue){
		var Obj = document.getElementById(sObj);
		oOption = document.createElement("OPTION");
		Obj.add(oOption);
		oOption.innerText = FileNum.value + " --> " + sValue;
		oOption.value = FileNum.value;
		oOption.id = sObj + "_" + FileNum.value;
		oOption.style.color = "#006600";
		oOption.selected = true;
	}
	function ViewThis(sValue){
		var aObj = document.getElementById("oFile");
		aObj.href = eval("document.getElementById(\"M2_" + sValue + "\").innerText;").replace(/^.+UploadFile/gi,"UploadFile");
		aObj.innerHTML = eval("document.getElementById(\"M2_" + sValue + "\").innerText;");
		for(i = 0; i <= 9; i++){
			if(i != 8){
				eval("document.getElementById(\"M" + i + "_" + sValue + "\").selected = true;");
				eval("document.getElementById(\"M" + i + "_" + sValue + "\").style.color = \"#FF0000\";");
			}
		}
	}
