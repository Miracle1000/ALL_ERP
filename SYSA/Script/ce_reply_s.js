
function share_CancelPerson(divid,str_id2)
{
	if (!document.getElementById(divid).checked)
	{
		var divobj=document.getElementById(str_id2);
		var docObj=divobj.getElementsByTagName("input");
		//alert(docObj.length);
		for(var i=0;i<docObj.length;i++)
		{
			docObj[i].fireEvent("onClick");
		}
	}
}
function share_ShowPerson(str_id,str_name)
{
	if (document.getElementById(str_id).checked)
	{
		document.getElementById('sharer').innerHTML=document.getElementById('sharer').innerHTML+"&nbsp;&nbsp;"+str_name;
	}
	else
	{
		var str_rs=document.getElementById('sharer').innerHTML;
		document.getElementById('sharer').innerHTML=str_rs.replace("&nbsp;&nbsp;"+str_name,"");
	}
}

  function checkAll(str){
    var a=document.getElementById("t"+str).getElementsByTagName("input");
    var b=document.getElementById("d"+str);
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
  }

function Update(txt){
	var i = recc;
	alert(i);
	if(!i){i=0}
	//if(i==1){txt.recc=2;return;}
	if(i==1 || i==2){
		recc =  0;
		checkreply(2,0);
	}
}
function checkreply(typeid,i)
{
	if (typeid==1)
	{
		var rep=document.getElementById("lcb"+i).value;
		document.getElementById("mb_intro").value=rep;
		document.getElementById("intro").value=rep;
		document.getElementById("intro_jy").value=rep;
		document.getElementById("intro_rc").value=rep;
	}
	else
	{
		if (typeid==2)
		{
			var rep=document.getElementById("intro").value;
			document.getElementById("mb_intro").value=rep;
			document.getElementById("intro_jy").value=rep;
			document.getElementById("intro_rc").value=rep;
		}
	}
}

