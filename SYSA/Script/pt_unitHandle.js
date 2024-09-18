//重置价格策略div高度
function ResetCelueDivHeight(){
	var cldiv=document.getElementById("celue_div");
	cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
}

function AjaxRequest(url ,fun){
	xmlHttp.open("GET", url, true);
	xmlHttp.onreadystatechange = fun;
	xmlHttp.send(null);
}

function AjaxHandleUnit(act , urlAttrs , fun){
	var url1 = "UnitHandle.asp?act="+ act + (urlAttrs.length>0 ? "&"+urlAttrs : "") + "&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
	AjaxRequest(url1 ,fun)
}
//主单选单位组触发事件 -- 加载价格策略
function ChangeUnitGroup(fromtype) {
    var fromtype=fromtype|| ""
	var unitgp = document.getElementById("unitgp").value;
	if ((unitgp == null) || (unitgp == "")) return;
	var url = "cuunit.asp?unitgp=" + escape(unitgp) + "&timestamp=" + new Date().getTime() + "&date7=" + Math.round(Math.random() * 100) + "&fromType=" + encodeURI(fromtype);
    AjaxRequest(url, function() {
        ReloadProductPriceRule(unitgp);
    });
}

function ReloadProductPriceRule(unitgp) {
	if (xmlHttp.readyState < 4) {
		trpx0.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
        trpx0.innerHTML = response;
        jQuery('.baseUnitFont').text(" "+jQuery('#unitDiv_0_' + jQuery('#baseUnitInput').val()).find('option:selected').text());
		if(jQuery("input[name='cgMainUnit']").size()>0){
			if(jQuery("input[name='cgMainUnit']:checked").size()==0){
				jQuery("input[name='cgMainUnit']:first").attr("checked",true);
			}
		}
		ResetCelueDivHeight();		
		//加载单位组属性
		//AjaxHandleUnit("GetGroupAttr" , "unitgp=" + escape(unitgp) ,ReloadProductUnitAttr);
	}
}
//加载单位组属性
function ReloadProductUnitAttr() {
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;	
		xmlHttp.abort();
	}
}
//价格策略选择单位组
function ChangeGroup(obj,mxpxcpid , productid){
	var unitgroup =obj.value;
	//价格策略中选择单位后 临时表数据变更为所选单位 (保存时,循环临时数据即可)
	AjaxHandleUnit("setunitgroupmxpxcpid" , "productid="+ productid +"&mxpxcpid=" + escape(mxpxcpid) + "&unitgroup="+escape(unitgroup) , function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			var r = response.split("@@@@@@@@@@");
			document.all["unitDiv_0_"+ mxpxcpid +""].innerHTML=r[0];
			if(document.all["unitAttr_0_"+ mxpxcpid +""])
			document.all["unitAttr_0_"+ mxpxcpid +""].innerHTML=r[1];
			if(document.all["Parameter_0_"+ mxpxcpid +""])
			document.all["Parameter_0_"+ mxpxcpid +""].innerHTML=r[2];
			xmlHttp.abort();
		}
	});
}

function ChangeUnit(obj,mxpxcpid){
	var unit =obj.value;
	//价格策略中选择单位后 临时表数据变更为所选单位 (保存时,循环临时数据即可)
	AjaxHandleUnit("setunitmxpxcpid" , "mxpxcpid=" + escape(mxpxcpid) + "&unit="+escape(unit) , function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			if(response.length>0){
				document.all["bl_"+ mxpxcpid +""].value = response;
			}
			xmlHttp.abort();
		}
	});
}
//单位是否停用
function ChangeUnitStop(obj, mxpxcpid, productid) {
	var isStop = obj.checked ? 1 : 0;
	AjaxHandleUnit("setisstopmxpx", "mxpxcpid=" + escape(mxpxcpid) + "&isStop=" + escape(isStop) + "&productid=" + escape(productid), function () {
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			if (response.length > 0) {
				document.all["bl_" + mxpxcpid + ""].value = response;
			}
			xmlHttp.abort();
		}
	});
}
//切换采购主单位
function ChangeCGMainUnit(mxpxcpid) {
	AjaxHandleUnit("setmxpxtopid", "mxpxcpid=" + escape(mxpxcpid), function () {
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			if (response.length > 0) {
				document.all["bl_" + mxpxcpid + ""].value = response;
			}
			xmlHttp.abort();
		}
	});
}
//选单位组属性 --加载属性参数
function ChangeUnitAttr(obj ,mxpxcpid , productid){
	var UnitAttr = obj.value;
	AjaxHandleUnit("GetGroupAttrFormulaParameter" , "productid="+ productid +"&mxpxcpid=" + escape(mxpxcpid) + "&UnitAttr="+escape(UnitAttr) , function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			document.all["Parameter_0_"+ mxpxcpid +""].innerHTML=response;
			xmlHttp.abort();
		}
	});
}

//新增价格策略行
function AddProductPriceRule(baseUnitName,fromtype){
    var fromtype=fromtype||""
    var url = "num_click.asp?timestamp=" + new Date().getTime() + "&date7=" + Math.round(Math.random() * 100);
	window.baseUnitName = baseUnitName;
	window.fromtype = fromtype;
    AjaxRequest(url, InsertPriceData );
}

function InsertPriceData(){
    if (xmlHttp.readyState == 4) {
        var unitgp = document.getElementById("unitgp").value;
		var res = xmlHttp.responseText;
		var url = "cuunit.asp?timestamp=" + new Date().getTime() + "&date7=" + Math.round(Math.random() * 100) + "&baseUnitName=" + encodeURI(window.baseUnitName) + "&fromType=" + encodeURI(window.fromtype);	
        AjaxRequest(url, function () { getPriceData(res);
            if (unitgp == 0) {
                jQuery("#newInsert").attr("onclick");
            }
        } );		
	}
}
function getPriceData(res) {
	var w  = "trpx"+(res-1);
	var test3=document.all[w]
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		ResetCelueDivHeight();
		xmlHttp.abort();

		if(jQuery("input[name='cgMainUnit']").size()>0){
			if(jQuery("input[name='cgMainUnit']:checked").size()==0){
				jQuery("input[name='cgMainUnit']:first").attr("checked",true);
			}
		}
	}
}

//删除价格策略行
function DelProductPriceRule(spanid,mxpxcpid){
	AjaxHandleUnit("DelProductPriceRule" , "mxpxcpid=" + escape(mxpxcpid), function(){
		if (xmlHttp.readyState == 4) {
			document.getElementById(spanid).innerHTML="";
			ResetCelueDivHeight();
			xmlHttp.abort();
		}
	} );
}

//1 实体  0 非实体
function CheckOutStore(outStore){
	var Roles = document.getElementsByName("Roles");
	if(outStore==1){
		for(var i =0 ; i<Roles.length ; i++){
			Roles[i].checked = true;
			Roles[i].disabled = false;
		}
	}else{
		for(var i =0 ; i<Roles.length ; i++){
			Roles[i].checked = false;
			Roles[i].disabled = true;
		}
	}
}

//页面提交 检查页面字段值
function CheckPageFieldValue() {
    var bl = false;
    jQuery("input[name^='bl']").each(function () {
        if (parseFloat(jQuery(this).val()) <= 0)
        {
            bl=true;
        }
    });
    if (bl)
    {
        alert("产品单位换算比例不能为0!");
        return false;
    }
    var canOutStore = document.getElementById("cpjs");
    if (canOutStore && canOutStore.style.display != "none") {
        //BUG:40225    （【优化】委外、自制和工序模块号独立控制）该任务控制了产品添加/修改时的产品角色
        //当没有生产派工或委外模块时这里获取的Role1、Role2为null  所以保存时会报错
        var Role1 = document.getElementById("Role1"); 
        var Role1Checked = Role1 == null ? false : Role1.checked;
        var Role2 = document.getElementById("Role2");
        var Role2Checked = Role2 == null ? false : Role2.checked;
		var Role3 = document.getElementById("Role3");
		if (!Role1Checked && !Role2Checked && !Role3.checked) {
			alert("请选择产品角色!");
			return false;	
		}
	}
	//检查多单位celue_div
	var hasUnValue = false;
	var celue_div = document.getElementById("celue_div");
	if(celue_div){
		var inputs = celue_div.getElementsByTagName("select");
		if(inputs && inputs.length>0){
			var us = "" ;
			for(var i=0 ; i<inputs.length;i++){
				if(inputs[i].className=="UnitCelue"){
					var v = inputs[i].value;
					if(v=="") v = 0;
					if((us+",").indexOf(","+v+",")>=0){
						hasUnValue =true;
						break;
					}
					us+="," + v;
				}
			}
			if(us.length==0){
				alert("请选择产品单位!");
				return false;
			}
		}
	}
	if(hasUnValue){
		alert("产品单位不允许重复!");
		return false;
	}
	//检查多单位属性值 必须有 一个留白或未0
	if(celue_div){
		var divs =  document.getElementsByTagName("div");
		if(divs && divs.length>0){
			for(var i=0 ; i<divs.length;i++){
				if (divs[i].className =="UnitFormulaClass")
				{
					var hasUnValue = false;
					var unitinputs = divs[i].getElementsByTagName("input");
					if(unitinputs && unitinputs.length>0){
						for(var ii=0 ; ii<unitinputs.length;ii++){
							var v = unitinputs[ii].value;
							if(v=="") v = 0;
							if(parseFloat(v)==0){
								hasUnValue =true;
								break;
							}
						}
						if (hasUnValue==false)
						{
							
							var unitName = divs[i].id.replace("Parameter_0_","unit_0_");
							var unitObj = document.getElementsByName(unitName)[0];
							var unitV = unitObj.options[unitObj.selectedIndex].text;
							alert("价格策略中的"+ unitV +"的属性项至少一个为空或者为0!");
							return false;
						}
					}
				}
			}
		}
	}
	//检查采购主单位是否有没有勾选的
	if(jQuery("#isOpenCGMainUnit").size()>0){
		var isOpenCGMainUnit = jQuery("#isOpenCGMainUnit").val();
		if(isOpenCGMainUnit=="1"){
			var CGMainUnitSelected = 0;
			if (jQuery("input[name='cgMainUnit']:checked").size() < 1) {
				alert("请选择采购主单位！");
				return false;
			} else {
				var id = jQuery("input[name='cgMainUnit']:checked")[0].value;
				if (jQuery("input[id='isUnitStop_" + id + "']:checked").size() > 0) {
					alert("采购主单位不能停用！");
					return false;
                }
            }
		}
	}
	return true;
}