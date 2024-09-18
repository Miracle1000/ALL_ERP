

function DoCF(ord,unit,unit2,ck,ck2,idx,obj,kcid)
{
	//var numobj=obj.parentElement.parentElement.parentElement.cells[5].getElementsByTagName("input")[0];
	//if(numobj.value==""){alert("请输入拆分的数量");return;}
	//if(isNaN(numobj.value)){alert("拆分的数量不合法，请输入数字");return;}
	//if(parseFloat(numobj.value)>parseFloat(numobj.max.replace(/\,/g,''))){alert("输入的数量超过了库存数量，最大值为"+numobj.max);return;}
    var url = "../../SYSA/store/ku_unit_cf.asp?ord=" + escape(ord) + "&unit=" + escape(unit) + "&unit2=" + escape(unit2) + "&ckjb=" + escape(ck) + "&ck=" + escape(ck2) + "&num1=" + escape(0) + "&kcid=" + escape(kcid) + "&stamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange=function()
  {
  	if(xmlHttp.readyState == 4)
  	{
		  var s=xmlHttp.responseText;
		  if(s.indexOf("拆分没有成功！")!=-1)
		  {
		  	alert(s);
		  }
		  else
		  {
		      try {
		          var date5 = $("#ret3").val();
		          if (date5.length >= 10) {
		              date5 = date5.substring(0, 10) + " " + ((new Date()).toTimeString()).substring(0, 8);
		              $("#ret3").val(date5);
		          }
		      } catch (e) { }
			  if(parent.OnKuSplitComplete) { 
				return OnKuSplitComplete(idx);
			  }
		  	  UnitCustomFun(lv.Rows[idx].Cells[5],"unit");
		  }
		}
	}
  xmlHttp.send(null);
}

function showSort(obj,ckid)
{
	var dvobj=obj.children[1];
	if(dvobj.innerHTML=="")
	{
		var url="../store/CommonReturn.asp?act=getStoreSort&ckid="+ckid+"&stamp=" + Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.send(null);
		var s=xmlHttp.responseText;
		dvobj.innerHTML="<div class='top' style='font-weight:bolder;background-color:#ecf5ff'>所属分类："+s+"</div>";
	}
	dvobj.style.display="block";
}

function closeSort(obj)
{
	var dvobj=obj.children[1];
	dvobj.style.display="none";
}

//拆分页面跳转
function Kuinfoopenurltocf(productid, moreunit, unit, Ismode, id, ck, obj) {
    var num1 = $(obj).parents("td").parents("td").prevAll().find("input[name='rknum']").attr('value');
    if(typeof (num1) == "undefined")
    {
        num1 = $(obj).parents("td").parents("td").prevAll().eq(2).text();
    }
    window.open('../../sysn/view/store/kuout/KuAppointSplit.ashx?productid=' + productid + '&unit=' + unit + '&ck=' + ck + '&attr1=0&attr2=0&moreunit=' + moreunit + '&Ismode=2&id=' + id + '&cfnum1=' + num1 + '', 'newwin23', 'width=' + 800 + ',height=' + 400 + ',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');

}