
function checkSelect()
{
	if ( document.getElementById("sorttype").value==0)
	{
		document.getElementById("sorttype_Msg").innerHTML="请选择分类！";
		return false;
	}
	else
	{
		document.getElementById("sorttype_Msg").innerHTML="";
	}
	if (document.getElementById("title").value.length>50 || document.getElementById("title").value.length==0)
	{
		document.getElementById("title_Msg").innerHTML="标题必须在1-50字之间！";
		return false;
	}
	else
	{
		document.getElementById("title_Msg").innerHTML="";
	}
	var member1 = "";
	$("input[name='member1']").each(function(){
		if($(this).attr("checked")){
			member1 = $(this).val();
		}
	});
	if (member1 == "1"){
		var w1num = $("input[name='W1']").size();
		var w2num = $("input[name='W2']").size();
		var w3num = $("input[name='W3']").size();
		if((w1num+w2num+w3num)==0){
			document.getElementById("lbmsg").innerHTML="请选择人员！";
			return false;
		}else{
			var chknum = 0;
			$("input[name='W1']").each(function(){
				if($(this).attr("checked")){
					chknum += 1;
					return true;
				}
			});
			$("input[name='W2']").each(function(){
				if($(this).attr("checked")){
					chknum += 1;
					return true;
				}
			});
			$("input[name='W3']").each(function(){
				if($(this).attr("checked")){
					chknum += 1;
					return true;
				}
			});
			if(chknum>0){
				return true
			}else{
				document.getElementById("lbmsg").innerHTML="请选择人员！";
				return false;
			}
		}
	}else{
		return true;
	}
}


    function checkAll(str){
        var a=document.getElementById("d"+str).getElementsByTagName("input");
        var b=document.getElementById("t"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk(str){
        var a=document.getElementById("t1").getElementsByTagName("input");
        var b=document.getElementById("d1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll2(str){
        var a=document.getElementById("u"+str).getElementsByTagName("input");
        var b=document.getElementById("e"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk2(str){
        var a=document.getElementById("u1").getElementsByTagName("input");
        var b=document.getElementById("e1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll3(str){
        var a=document.getElementById("h"+str).getElementsByTagName("input");
        var b=document.getElementById("i"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk3(str){
        var a=document.getElementById("h1").getElementsByTagName("input");
        var b=document.getElementById("i1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll7(str){
        var a=document.getElementById("Wd"+str).getElementsByTagName("input");
        var b=document.getElementById("Wt"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk7(str){
        var a=document.getElementById("Wd1").getElementsByTagName("input");
        var b=document.getElementById("Wt1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll4(str){
        var a=document.getElementById("j"+str).getElementsByTagName("input");
        var b=document.getElementById("k"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk4(str){
        var a=document.getElementById("j1").getElementsByTagName("input");
        var b=document.getElementById("k1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }
