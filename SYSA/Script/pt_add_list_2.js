
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
		document.getElementById("mainfrm").value=mainobj.value;
		document.getElementById("robjfrm").value=storeobj;
		document.getElementById("extfrm").innerText=tobj.value;
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
		document.getElementById("mainfrm").value=sobj.value;
		document.getElementById("robjfrm").value=strid;
		document.getElementById("extfrm").innerText=slaveobj.value;
		document.getElementById("ssIFForm").action="../store/StoreDlg.asp?oldmodel=1";
		document.getElementById("ssIFForm").target="adsIF";
		document.getElementById("ssIFForm").submit();
		sdivobj.style.display="inline";
	}
}

function adClose()
{
	document.getElementById('bgDiv').style.display="none";
	document.getElementById('adsDiv').style.display="none";
}

function sdClose()
{
	document.getElementById('bgDiv').style.display="none";
	document.getElementById('ssDiv').style.display="none";
}

var cldiv=document.getElementById("celue_div");//内层
var idv_div=document.getElementById("idv_div");//外层
try{
	reSetSize(20,false);
}catch(e){}
var isadd= false;
function reSetSize(height,isOnResize){
	var Nwidth = cldiv.offsetWidth;
	var Wwidth = cldiv.parentElement.offsetWidth;
	if (Wwidth>Nwidth+20)
	{
		Nwidth = Wwidth-6;
	}
	else
	{
		Nwidth = (document.body.offsetWidth-cldiv.parentElement.parentElement.cells[0].offsetWidth-30)	
	}
	cldiv.style.width =Nwidth +"px";
	if (!isOnResize && idv_div.offsetHeight<100){idv_div.style.width = 100+"px";}
	cldiv.style.height = cldiv.scrollHeight + (cldiv.scrollWidth > cldiv.offsetWidth ? 20:0) + "px";
}

window.onresize=function()
{
	try{
		reSetSize(20,false);
	}catch(e){}
};

