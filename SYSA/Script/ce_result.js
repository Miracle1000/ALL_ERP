
function Myopen(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
}

function test()
{
  if(!confirm('确认删除吗？')) return false;
}
function ask3() {
document.all.form1.action = "shareall.asp?" + getUrl("");
document.all.form1.submit();
}
function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if (e.name != 'chkall')
			e.checked = form.chkall.checked;
	}
}

function ask() {
	document.all.form1.action = "orderall.asp?" + getUrl("backurl=result");
	document.all.form1.submit();
}


	var hwndsp = null
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
function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
}

