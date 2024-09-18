
    function checkAll(str){
        var a=document.getElementById("j"+str).getElementsByTagName("input");
        var b=document.getElementById("k"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk(str){
        var a=document.getElementById("p"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
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

    function checkAll8(str){
        var a=document.getElementById("k"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
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
        var a=document.getElementById("k"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
         if(b.checked==false){
		 for(var i=0;i<a.length;i++){
                a[i].checked=b.checked;
                return ;
            }
			b.checked=false;
        }

    }

    function fixChk4(str){
        var a=document.getElementById("k"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }

    }

var tem = "";
function checkqn(e,itemName,thisvalue,name)
{
  tem= document.getElementById(name).value;
  var aa=document.getElementsByName(itemName);
  var bb=document.getElementById(name);
  if(e.checked==true){
  	tem += thisvalue+",";
  }
else{
   tem = tem.replace(thisvalue+",","");
}
bb.value=tem;

  for (var i=0; i<aa.length; i++)
   aa[i].checked = e.checked;
}

function dochange(str)
{
var obj=document.getElementsByTagName("input")
for(var i=0;i<obj.length;i++)
if(obj[i].type=="radio" && obj[i].value==str)
obj[i].checked=true;
}
function doradio(){
var obj=document.getElementsByTagName("input")
for(var i=0;i<obj.length;i++)
if(obj[i].type=="radio" && obj[i].checked)
//	document.all.member.value=obj[i].value
	$("input[name=member").val(obj[i].value);
}

function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}

}


var arrSort=window.sortlist.split(",");
function ZKAll(flg)
{
	for(var k=0;k<arrSort.length;k++)
	{
		if(document.getElementById('nr_'+arrSort[k]))
		{
			callServer4(''+window.userid+'','nr_'+arrSort[k],'jt_'+arrSort[k],arrSort[k],flg);
		}
	}
	callServer6(''+window.userid+'',flg)
	if(flg==2)
	{
		document.getElementById("titlestr").innerHTML="<a href=\"###\" onclick=\"ZKAll(1)\"><u>收缩全部列表</u></a>";
	}
	else
	{
		document.getElementById("titlestr").innerHTML="<a href=\"###\" onclick=\"javascript:ZKAll(2);\"><u>展开全部列表</u></a>";
	}
	if (window.parent)
	{
		window.parent.frameResize();
	}
}

function zzjgOnclick(obj,sort1,rd){
	document.getElementById('ksearch_'+sort1+'_a1').style.display = (obj.checked?'':'none')
	document.getElementById('ksearch_'+sort1+'_a2').style.display = (obj.checked?'':'none')
	document.getElementById('showlbl_'+sort1+'_jg').innerHTML='';
	if(check_ckxz('search_'+sort1+'_a')){
		callServer2_jg('ksearch_'+sort1+'_a1',rd,sort1);
	}else{
		setJGOpen(rd,sort1,false);
	}
}

function calcHeight(){
	var totalHeight = 0;
	var $floatDiv = $('span[id*="ttk"]:visible:parent');
	var floatDivHeight = ($floatDiv.size()>0?($floatDiv.height()+5):0);
	var floatDivTop = ($floatDiv.size()>0?$floatDiv.position().top:0);
	$(document.body).children('table').each(function(){totalHeight += $(this).height();});
	totalHeight = totalHeight > floatDivTop + floatDivHeight ? totalHeight : floatDivTop + floatDivHeight;
	return totalHeight;
}

jQuery(function(){
	jQuery(document.body).click(function(){
		var $frame = parent.jQuery('#cFF2');
		$frame.height(calcHeight());
	});
});
