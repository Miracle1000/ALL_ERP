
function pro_type1(val)
{
	url="getDate.asp?tp=1&Sid="+val;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var test=xmlHttp.responseText;
			var re1=test.indexOf('</noscript>');
			var re2=test.length;
			ajaxhtml=test.substring(re1+11,re2);
			document.getElementById('test2').innerHTML="("+ajaxhtml+")";
		}
	}
	xmlHttp.send(null);	
}
function CheckAll()
{
	var chkall=document.getElementById('all');
	var chkchlid=document.getElementsByName('id');
	if (chkall.checked)
	{
		for(i=0;i<chkchlid.length;i++)
		{
			chkchlid[i].checked=true;
		}
	}
	else
	{
		for(i=0;i<chkchlid.length;i++)
		{
			chkchlid[i].checked=false;
		}
	}
}
function chkall()
{
	var chkall=document.getElementById('chkall1');
	var chkchlid=document.getElementsByName('chkchild1');
	for(i=0;i<chkchlid.length;i++)
	{
		if (chkall.checked)
		{
			chkchlid[i].checked=true;
		}
		else
		{
			chkchlid[i].checked=false;
		}
		addDataList(chkchlid[i]);
	}
}
function OpenResult(args,argsid,currpage,seh,txt)
{	
	var typeDataid="";
	var personDataid="";
	var ks=a.Kinds.FindKind(args);
	typeDataid=ks.getAllOrders();
	if (ks!=null)
	{
		var ps=ks.FindAcc(argsid);
		if(ps!=null)
		{
			personDataid=ps.getTxTOrders();
		}
	}
	var post="typeid="+args+"&ord="+window.orderOrd+"&dataid="+argsid+"&seh="+seh+"&txt="+escape(txt)+"&personDataid="+personDataid+"&typeDataid="+typeDataid+"&currpage="+currpage+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	url="getData.asp"
	xmlHttp.open("POST",url,true)
	xmlHttp.setRequestHeader("Cache-Control","no-cache");
    xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded;");
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			document.getElementById('getresult').innerHTML=xmlHttp.responseText;
			document.getElementById('tempid').value=args;
			document.getElementById('dateid').value=argsid;
		}
	}
	xmlHttp.send(post);	
	setWindowTop("w");
	$('#w').window('open');
	
}
var a = new MV_All();
function chanceR(name,id)
{
	args=document.getElementById('tempid').value;
	if (args!="")
	{
		if (args==0)
		{
			document.getElementById('all').value=id;
			document.getElementById('allperson').innerHTML=name+"&nbsp;<a href=\"javascript:void(0);\" onclick=\"delPerson(this,'"+args+"','"+id+"')\"><img src=\"../images/del2.gif\" title=\"删除用户\"></a>";
		}
		else
		{
			var ks=a.Kinds.FindKind(args);
			if (ks!=null)
			{
				var ps=ks.FindAcc(id);
				if(ps==null)
				{
					ks.Accounts.Add(ks,id);
					document.getElementById('acc_cateid'+args).value=id;
					var dv=document.createElement("div");
					dv.innerHTML="<a href=\"javascript:void(0);\" onclick=\"OpenResult('"+args+"','"+id+"',1,'','')\">"+name+"</a>&nbsp;<span id='"+args+"_"+id+"'>0</span>条&nbsp;<a href=\"javascript:void(0);\" onclick=\"delPerson(this,'"+args+"','"+id+"')\"><img src=\"../images/del2.gif\" title=\"删除用户\"></a>"
					document.getElementById('acc_name'+args).appendChild(dv);
				}
			}
		}
	}
	$('#q').window('close');
}
function delPerson(obj,kd,ad)
{
	if (kd==0)
	{
		document.getElementById('allperson').innerHTML="";
		document.getElementById('all').value="";
	}
	else
	{
		var parent=obj.parentElement.parentElement;
		parent.removeChild(obj.parentElement);
		var ks=a.Kinds.FindKind(kd);
		if (ks!=null)
		{
			var ps=ks.FindAcc(ad);
			if(ps!=null)
			{
				ks.DelAcc(ad);
			}
		}
	}
}

function setWindowTop(wid){
	var h1 = 0;
	var h2 = 0;
	try{
		h1 = parent.document.documentElement.scrollTop;
		h2 = parent.document.body.scrollTop;
	}catch(e){
		h1 = document.documentElement.scrollTop;
		h2 = document.body.scrollTop;
	}
	var inttop=(55+h1+h2)+"px";
	$('#'+wid+'').window({top:inttop});
}

function getPerson(args)
{
	setWindowTop("q");
	$('#q').window('open');
	document.getElementById('tempid').value=args;
}
function addDataList(args)
{
	//var select_id=document.getElementsByName('chkchild1');
	typeid=document.getElementById('tempid').value;
	personid=document.getElementById('dateid').value;
	var ks=a.Kinds.FindKind(typeid);
	if (ks!=null)
	{
		var ps=ks.FindAcc(personid);
		if(ps!=null)
		{
			if (args.checked)
			{
				ps.Orders.Add(args.value);
			}
			else
			{
				ps.Orders.DelOrder(args.value);
			}
			numData=ps.Orders.length;
		}
	}
	document.getElementById(typeid+'_'+personid).innerHTML=numData;
	//$('#w').window('close');
}
function ask1() {

    var chk = "";
    var chkvalue = "";
    var chkall = document.getElementById('all');
    if (chkall.checked == true) {
        var id = document.getElementsByName('id');
        for (var i = 0; i < id.length; i++) {
            if (id[i].checked == true) {
                if (chk == "") {
                    chk = id[i].value;
                }
                else {
                    chk = chk + "," + id[i].value;
                }
            }
        }
        chkvalue = chkall.value;
    }
    var txt = a.getTxtData();

    if (document.getElementById("all").checked && chkvalue.length == 0) {
        alert("请选择要转移到哪个用户！");
        document.getElementById("all").focus();
        return;
    }

    if (!confirm('是否确定要执行转移操作！')) {
        return false;
    }
    var post = "chk=" + chk + "&chkvalue=" + chkvalue + "&txt=" + txt + "&ord="+window.orderOrd;
    //post = encodeURI(post);
    var url = "Save_order.asp";
    xmlHttp.open("POST", url, true);
    xmlHttp.setRequestHeader("Cache-Control", "no-cache");
    xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;");
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4) {
            //alert(xmlHttp.responseText);
            //return;
            //document.getElementById('aa').innerHTML=xmlHttp.responseText;
            alert('转移成功！');
            location.reload();
        }
    }
    xmlHttp.send(post);
}
