
	$(document).ready(function(){
		  $('.menu_ul1').decorateIframe();
		  $('.menu_ul2').addClass("iframe-x").decorateIframe(); 
	 });	 


function clearSpace(obj){
	if (/[\u0000-\u001f\u007f\u0080-\u009F]/.test(obj.value)){
		obj.value = obj.value.replace(/[\u0000-\u001f\u007f\u0080-\u009F]/gi,'');
	}
	while (/ $/.test(obj.value)){
		obj.value = obj.value.replace(/ $/g,'');
	}

	while (/^ /.test(obj.value)){
		obj.value = obj.value.replace(/^ /g,'');
	}
}

function checkDot2(sid, num_dot, int_dot) {
    if (typeof (int_dot) == "undefined") {
        int_dot = 8;	//整数位最大长度默认为12
    }
    var txtvalueObj = typeof (sid) == "object" ? sid : document.getElementById(sid);
    var re = /[^\d]/g;
    var txtvalue = txtvalueObj.value;//正则获取的是数字
    if (txtvalue.indexOf('.') >= 0) {
        var txt1, txt2, txt3;
        txt1 = txtvalue.split('.');
        txt2 = txt1[0];
        if (txt2.indexOf('-') >= 0) { txt2 = "-" + txt2.replace(/\-/g, ''); }
        txt3 = txt1[1].replace(/\-/g, '');
        if (txt2.length == 0) {
            txt2 = "0";
        }
        else {
            if (txt2.length > int_dot) {//整数部分不能大于12位
                txt2 = txt2.substr(0, int_dot);
            }
        }
        if (txt1.length == 2) {
            if (txt3.length > num_dot) {//小数部分不能大于8位
                txt3 = txt3.substr(0, num_dot);
            }
        }
        txtvalueObj.value = txt2 + "." + txt3; $(txtvalueObj).change();
    }
    else {//整数不能超过12位
        if (txtvalue.length > int_dot) {
            txtvalueObj.value = txtvalue.substr(0, int_dot); $(txtvalueObj).change();
        }
        else {
            if (txtvalue.indexOf('-') >= 0) {
                txtvalueObj.value = "-" + txtvalue.replace(/\-/g, ''); $(txtvalueObj).change();
            }
        }
    }
}