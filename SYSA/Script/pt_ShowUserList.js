
    function checkAll7(str){
        var a=document.getElementById("Wd"+str).getElementsByTagName("input");
        var b=document.getElementById("Wt"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

function CheckSelection()
{
	var rvalue=false;
	try
	{
		if(document.getElementById("rbtn2").checked)
		{
			var ulist=document.getElementsByName("W1");
			var notchecked=true;
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W2");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W3");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			
			if(notchecked)
			{
				document.getElementById("ulist1").innerText="请选择可操作范围";
				rvalue = false;
			}
			else
			{
				document.getElementById("ulist1").innerText="";
				rvalue = true;
			}
		}
		else
		{
			rvalue = true;
			
		}
	}
	catch(e3){}
	finally
	{return rvalue;}
}
