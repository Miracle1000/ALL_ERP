//谭:utf-8转码, wekit环境下不能用vbs。
function GB2312UTF8() {
    this.Dig2Dec = function(s) {
        var retV = 0;
        if (s.length == 4) {
            for (var i = 0; i < 4; i++) {
                retV += eval_r(s.charAt(i)) * Math.pow(2, 3 - i);
            }
            return retV;
        }
        return - 1;
    }
    this.Hex2Utf8 = function(s) {
        var retS = "";
        var tempS = "";
        var ss = "";
        if (s.length == 16) {
            tempS = "1110" + s.substring(0, 4);
            tempS += "10" + s.substring(4, 10);
            tempS += "10" + s.substring(10, 16);
            var sss = "0123456789ABCDEF";
            for (var i = 0; i < 3; i++) {
                retS += "%";
                ss = tempS.substring(i * 8, (eval_r(i) + 1) * 8);
                retS += sss.charAt(this.Dig2Dec(ss.substring(0, 4)));
                retS += sss.charAt(this.Dig2Dec(ss.substring(4, 8)));
            }
            return retS;
        }
        return "";
    }
    this.Dec2Dig = function(n1) {
        var s = "";
        var n2 = 0;
        for (var i = 0; i < 4; i++) {
            n2 = Math.pow(2, 3 - i);
            if (n1 >= n2) {
                s += '1';
                n1 = n1 - n2;
            } else s += '0';
        }
        return s;
    }

    this.Str2Hex = function(s) {
        var c = "";
        var n;
        var ss = "0123456789ABCDEF";
        var digS = "";
        for (var i = 0; i < s.length; i++) {
            c = s.charAt(i);
            n = ss.indexOf(c);
            digS += this.Dec2Dig(eval_r(n));
        }
        return digS;
    }
    this.Gb2312ToUtf8 = function(s1) {
        var s = escape(s1);
        var sa = s.split("%");
        var retV = "";
        if (sa[0] != "") {
            retV = sa[0];
        }
        for (var i = 1; i < sa.length; i++) {
            if (sa[i].substring(0, 1) == "u") {
                retV += this.Hex2Utf8(this.Str2Hex(sa[i].substring(1, 5)));
                if (sa[i].length) {
                    retV += sa[i].substring(5);
                }
            } else {
                retV += ("%" + sa[i]);
                if (sa[i].length) {
                    retV += sa[i].substring(5);
                }
            }
        }
        return retV;
    }
    this.Utf8ToGb2312 = function(str1) {
        var substr = "";
        var a = "";
        var b = "";
        var c = "";
        var i = -1;
        i = str1.indexOf("%");
        if (i == -1) {
            return str1;
        }
        while (i != -1) {
            if (i < 3) {
                substr = substr + str1.substr(0, i - 1);
                str1 = str1.substr(i + 1, str1.length - i);
                a = str1.substr(0, 2);
                str1 = str1.substr(2, str1.length - 2);
                if (parseInt("0x" + a) & 0x80 == 0) {
                    substr = substr + String.fromCharCode(parseInt("0x" + a));
                } else if (parseInt("0x" + a) & 0xE0 == 0xC0) { //two byte
                    b = str1.substr(1, 2);
                    str1 = str1.substr(3, str1.length - 3);
                    var widechar = (parseInt("0x" + a) & 0x1F) << 6;
                    widechar = widechar | (parseInt("0x" + b) & 0x3F);
                    substr = substr + String.fromCharCode(widechar);
                } else {
                    b = str1.substr(1, 2);
                    str1 = str1.substr(3, str1.length - 3);
                    c = str1.substr(1, 2);
                    str1 = str1.substr(3, str1.length - 3);
                    var widechar = (parseInt("0x" + a) & 0x0F) << 12;
                    widechar = widechar | ((parseInt("0x" + b) & 0x3F) << 6);
                    widechar = widechar | (parseInt("0x" + c) & 0x3F);
                    substr = substr + String.fromCharCode(widechar);
                }
            } else {
                substr = substr + str1.substring(0, i);
                str1 = str1.substring(i);
            }
            i = str1.indexOf("%");
        }

        return substr + str1;
    }
}
//谭:公共js下，需要对相对路径进行判断;
$(function(){
	window.isgoodlistPage = window.location.href.toLowerCase().indexOf("html/goodlist.html")>0;
	//二维码扫描事件
	$("#sweep").unbind().bind("click",function(){
		 wx_ScanQRCode(function(result){
			if((result).indexOf("view.asp?V") > 0){
				result = "QrUrlzzzzzzzz"+(result).split("view.asp?")[1];
				if(window.isgoodlistPage) {
					pageNum = 1  //goodList页面直接刷
					loadMore("searchKey",result,pageNum);
				} else {
					window.location = window.htmlvirpath + "html/goodList.html?ScanQR=1&result="+result;
				}
			} else {
				var v = result.split("\r\n");
				for(var i=0;i<v.length;i++){
					if(v[i].indexOf("商品号：")==0){
						result = v[i];
						break;
					}
				}
				//result = gb2utf8(result);
				if(window.isgoodlistPage) {
					pageNum = 1  //goodList页面直接刷
					loadMore("searchKey",result,pageNum);
				} else {
					window.location = window.htmlvirpath + "html/goodList.html?ScanQR=1&result="+encodeURIComponent(result);
				}
			}
		 })
	 });
	 
	//语音点击事件
	$(".speak").unbind().bind("click",function(){
		wx_StartRecord(function(result, success){
			if(success) { 
				$("#searchDiv").show();
				var searBtn = $("#al-search");
				searBtn.unbind().bind("keydown",function(){
					if(event.keyCode==13){$("#search").click();}
				});
				$("#search").click(function(){
					searTxt = searBtn.val();
					if(searTxt){
						window.bindSearchHistory("al-search");
						$("#al-search").attr("value","");
						if(window.isgoodlistPage) {
							pageNum = 1  //goodList页面直接刷
							loadMore("searchKey",searTxt,pageNum);
						} else {
							window.location = window.htmlvirpath + "html/goodList.html?result="+encodeURIComponent(result);
						}
					}
				});
				searBtn.val(result);
				$("#search").click();
			}
		})
	});
})

function gb2utf8(data){ 
     return (new GB2312UTF8()).Gb2312ToUtf8(data);
}
