
function adSearch(obj)
{
	var tobj=obj.parentElement.getElementsByTagName("input")[0];
	var bgobj=document.getElementById("bgDiv");
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=0;
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;
		y+=obj2.offsetTop;
	}
	if(tobj.name.indexOf("SlaveStore_")==0)
	{
		var sdivobj=document.getElementById("ssDiv");
		sdivobj.style.display="none";
		document.getElementById('adsDiv').style.display="none";
		sdivobj.style.left=x+33+"px";
		sdivobj.style.top=y+"px";
		var storeobj=tobj.name.replace('SlaveStore_','');
		var mainstore=tobj.name.replace('SlaveStore_','MainStore_');
		var mainobj=document.getElementsByName(mainstore)[0];
		if(mainobj.value=="")
		{
			alert("请先选择主仓库");
			return false;
		}

		window.currPreValue = "C_" + storeobj + "_" + mainobj.value
		document.getElementById("mainfrm").value= mainobj.value;  //主仓库	   sid
		document.getElementById("robjfrm").value= storeobj;	//行标识      robj
		document.getElementById("extfrm").innerText= tobj.value;	 //辅助仓库值  ext
		document.getElementById("ssIFForm").action="../Product/SlaveStoreEdit.asp";
		document.getElementById("ssIFForm").target="ssIF";
		document.getElementById("ssIFForm").submit();
		sdivobj.style.height = "486px"
		document.getElementById("ssIF").style.height = "486px"
		sdivobj.style.display="inline";
	}
	else
	{
		var sdivobj=document.getElementById("adsDiv");
		sdivobj.style.display="none";
		document.getElementById('ssDiv').style.display="none";
		sdivobj.style.left=x+33+"px";
		sdivobj.style.top=y+"px";
		var sobj=obj.parentElement.getElementsByTagName("input")[1];
		var strid=sobj.name.replace('MainStore_','');
		var storeobj=sobj.name.replace('MainStore_','SlaveStore_');
		var slaveobj=document.getElementsByName(storeobj)[0];
		//if (window.currPreValue != "M_" + strid + "_" + slaveobj.value) // 避免重复打开，重复提交
		//{
			window.currPreValue = "M_" + strid + "_" + slaveobj.valu;
			document.getElementById("mainfrm").value=sobj.value;
			document.getElementById("robjfrm").value=strid;
			document.getElementById("extfrm").innerText=slaveobj.value;
			//document.getElementById("ssIFForm").action="../product/productADStore.asp";
			document.getElementById("ssIFForm").action="../store/StoreDlg.asp?oldmodel=1";
			document.getElementById("ssIFForm").target="adsIF";
			document.getElementById("ssIFForm").submit();
		//}
		//else{
		//	sdivobj.style.height = "486px"
		//}
		sdivobj.style.display="inline";
	}
}

function adClose()
{
	document.getElementById('bgDiv').style.display="none";
	document.getElementById('adsDiv').style.display="none";
	document.getElementById("adsIF").src = "about:blank";
}

function sdClose()
{
	document.getElementById('bgDiv').style.display="none";
	document.getElementById('ssDiv').style.display="none";
	document.getElementById("ssIF").src = "about:blank";
}

var cldiv=document.getElementById("celue_div");
var idv_div=document.getElementById("idv_div");
//cldiv.style.width=parseFloat(cldiv.parentElement.offsetWidth)-50+"px";
//if(idv_div.offsetWidth<100){idv_div.style.width=100+"px";}
//cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
window.onresize=function()
{
    //cldiv.style.width=cldiv.parentElement.offsetWidth;
    if (idv_div) {
        if (idv_div.offsetWidth < 100) { idv_div.style.width = 100 + "px"; }
        cldiv.style.height = cldiv.children[0].offsetHeight + 20 + "px";
    
    }
};

