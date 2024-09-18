
function test()
{
  if(!confirm('确认删除吗？')) return false;
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

function Myopen(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=0;
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
	
	function PrintAll(isSum){
		var selectid = document.getElementsByName("selectid");
		var ids = "";
		for(var i = 0; i < selectid.length; i++){
			if(selectid[i].checked){
				ids = ids + "," + selectid[i].value;
			}
		}
		ids = ids.replace(",","");
		if(ids.length == 0){
			alert("您没有选择任何信息，请选择后再打印！");
			return false;
		}
		ids = ids.split(",");
		if (ids.length > 50){alert("选择的单据数量不要超过50个！");return false;}
		window.OpenNoUrl('../Manufacture/inc/printerResolve.asp?formid=' + ids + '&sort=4&isSum='+isSum,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
	}

	function NewPrintAll(){
		var selectid = document.getElementsByName("selectid");
		var ids = "";
		for(var i = 0; i < selectid.length; i++){
			if(selectid[i].checked){
				ids = ids + "|" + selectid[i].value;
			}
		}
		ids = ids.replace("|","");
		if(ids.length == 0){
			alert("您没有选择任何信息，请选择后再打印！");
			return false;
		}
		var idsArr = ids.split("|");
		if (idsArr.length > 50){alert("选择的单据数量不要超过50个！");return false;}
		window.OpenNoUrl('../../SYSN/view/comm/TemplatePreview.ashx?sort=4&ord='+ids,'newwin33','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
	} 
	
window.OpenNoUrl = function(url, name, attr) {
	//通过代理的方式，屏蔽url
	var urls = window.location.href.split("/");
	urls[urls.length-1] = url;
	window.currOpenNoUrl= urls.join("/");
	window.open(  window.sysCurrPath + "inc/datawin.asp", name, attr);
}
