
$(function(){
	var iframe = parent.document.getElementById('if1');
});
//选择人
function xzry(obj) {
    var dev_id = document.getElementsByName(obj);
    var dev_name = document.getElementsByName(obj);

    if (obj == "W3") {
        document.getElementById('executors1').innerHTML = dev_name[0].getAttribute("text").replace(/ /g, '，');
        document.getElementById('executors').value = dev_id[0].value;
        $('#w').window('close');
    }

    if (obj == "Z3") {
        document.getElementById('actors1').innerHTML = dev_name[0].getAttribute("text").replace(/ /g, '，');
        document.getElementById('actors').value = dev_id[0].value;
        $('#w1').window('close');
    }
}
function check(field) {  for (var i = 0; i < field.length; i++) {  field[i].checked = false;}  } 

var execed = false
function funxjjd(){
	//nextid196
	var win = window.opener;
	var nextid = win.document.getElementById("nextid" + dataid);
	var jh_id=document.getElementsByName("jh");
	if(nextid && execed == false) {
		execed = true
		//binary.当父页面存在设置时（如重新编辑保存，但是还未存磁盘），读父页面的数据。
		if(nextid.value!="") {
			var ids = nextid.value.split(",");
			for (var i = 0 ; i < jh_id.length; i ++ )
			{
				jh_id[i].checked = false;
				for (var ii = 0; ii < ids.length ; ii++ )
				{
					if(jh_id[i].value == ids[ii]) {
						jh_id[i].checked =  true;
						break;
					}
				}
			}
		}
 	}
	var jh_name=document.getElementsByName("jhname");
	var jh_id_list="",jh_name_list=""
	for (i=0;i<jh_id.length;i++)
	{
		if (jh_id[i].checked)
		{
			if (jh_id_list=="")
			{
				jh_id_list=jh_id[i].value;
				jh_name_list=jh_name[i].value;
			}
			else
			{
				jh_id_list=jh_id_list+","+jh_id[i].value;
				jh_name_list=jh_name_list+"，"+jh_name[i].value;
			}
		}
	}
	document.getElementById('nextid1').innerHTML=jh_name_list;
	document.getElementById('nextid').value=jh_id_list;
$('#xjjd').window('close');
}

function fnbtnr(){
	var cf_id=document.getElementsByName("commFields");
	var cf_name=document.getElementsByName("commFieldsnm");
	var cf_id_list="",cf_name_list="";
	for (i=0;i<cf_id.length;i++)
	{
		if (cf_id[i].checked)
		{
			if (cf_id_list=="")
			{
				cf_id_list=cf_id[i].value;
				cf_name_list=cf_name[i].value;
			}
			else
			{
				cf_id_list=cf_id_list+";"+cf_id[i].value;
				cf_name_list=cf_name_list+"，"+cf_name[i].value;
			}
		}
	}
	document.getElementById('vcommFields1').innerHTML=cf_name_list;
	document.getElementById('vcommFields').value=cf_id_list;
	
	var lf_id=document.getElementsByName("linkFields");
	var lf_name=document.getElementsByName("linkFieldsnm");
	var lf_id_list="",lf_name_list="";
	for (ii=0;ii<lf_id.length;ii++)
	{
		if (lf_id[ii].checked)
		{
			if (lf_id_list=="")
			{
				lf_id_list=lf_id[ii].value;
				lf_name_list=lf_name[ii].value;
			}
			else
			{
				lf_id_list=lf_id_list+";"+lf_id[ii].value;
				lf_name_list=lf_name_list+"，"+lf_name[ii].value;
			}
		}
	}	
	document.getElementById('vlinkFields1').innerHTML=lf_name_list;
	document.getElementById('vlinkFields').value=lf_id_list;	

	//自定义字段
	var strq=document.getElementsByName("count");
	var objarrayq=strq.length;
	var q="";
	var optin = "";
	var descnm="";
	var zdyFields="";
	var ll_id="";ll_name="";
	for (i=0;i<objarrayq;i++)
	{
	  if(strq[i].checked == true)
	  {
	   q="zdymc"+strq[i].value;

var sel=document.getElementsByName("zdyys"+strq[i].value)[0];
var selvalue= sel.options[sel.options.selectedIndex].value//你要的值


	   //alert(selvalue);
		   if(selvalue==7){
		   	descnm="";
					optin = document.getElementsByName("desc"+strq[i].value);
						for (ii=0;ii<optin.length;ii++)
						{
							if(optin[ii].value != ""){
							descnm=descnm+"\3"+optin[ii].value;
							}
						}
						if(ii==0){
							 descnm=descnm+"\3";
						}
		 }else{
		 descnm=descnm+"\3";
		 }
		zdyFields = document.getElementById(q).value+"\2"+document.getElementById("zdyys"+strq[i].value).value+"\2"+descnm;

			if (ll_id=="")
			{
				ll_id=zdyFields;
				ll_name=document.getElementById(q).value;
			}
			else
			{
				ll_id=ll_id+"\1"+zdyFields;
				ll_name=ll_name+"，"+document.getElementById(q).value;
			}



	  }
	}
	document.getElementById('vzdyzd1').innerHTML=ll_name;
	document.getElementById('vzdyzd').value=ll_id;	

$('#btnr').window('close');
}



function trnb(str){
	if(str == "1"){
	document.getElementById("gqysje").style.display="";
	document.getElementById("sxjgl").style.display="none";
	document.getElementById("sxjgl1").style.display="none";
	document.getElementById("xzr").style.display="";
	document.getElementById("xzr1").style.display="";
	document.getElementById("btnn").style.display="";
	
	}
	if(str == "0"){
	document.getElementById("gqysje").style.display="none";
	document.getElementById("sxjgl").style.display="";
	document.getElementById("sxjgl1").style.display="";
	document.getElementById("xzr").style.display="none";
	document.getElementById("xzr1").style.display="none";
	document.getElementById("btnn").style.display="none";
	}
}


function save() {
	var jdtypes, mustat, allOKModel;
	//重要指数	
	var execorder=document.getElementById("execorder").value;
	//节点类型
	if (document.getElementById("jdtype").checked==true){
			jdtypes = 1;
		}else{
			jdtypes = 0;			
		}
	//工期timeproject				
	var timeproject=document.getElementById("timeproject").value;
	//预算金额budgetmoney
	var budgetmoney=document.getElementById("budgetmoney").value;
	//执行人
	var executors=document.getElementById("executors").value;
	//协作人
	var actors=document.getElementById("actors").value;
	//节点描述
	var intro = document.getElementById("eWebEditor1").contentWindow.document.getElementById("ueditor_0").contentWindow.document.body.innerHTML; //document.getElementById("intro").value;
	//下级节点
	var nextid=document.getElementById('nextid').value;
		//intro =intro.replace(";","；");
		intro =intro.replace("'","’");
	//本机阶段
	if (document.getElementById("mustat").checked==true){
			mustat = 1;
		}else{
			mustat = 0;			
		}
	//上级节点
	if (document.getElementById("allOKModel").checked==true){
			allOKModel = 1;
		}else{
			allOKModel = 0;			
		}

		//上下级
	var splinktype = document.getElementsByName('splinktype');
	var itemvalue='';
	for(i=0;i<splinktype.length;i++){
	 if(splinktype[i].checked){
	 	itemvalue = splinktype[i].value;
		}
	}		
	splinktype = itemvalue;
	//自定义
	var vcommFields=document.getElementById("vcommFields").value;
	var vlinkFields=document.getElementById("vlinkFields").value;
	//扩展自定义
	var fvlinkFields = document.getElementById('vzdyzd').value;

	//回传数据^分来
	parent.opener.document.getElementById("jdtype" + dataid).value =jdtypes;
	parent.opener.document.getElementById("execorder" + dataid).value =execorder;
	parent.opener.document.getElementById("timeproject" + dataid).value =timeproject;
	parent.opener.document.getElementById("budgetmoney" + dataid).value =budgetmoney;
	parent.opener.document.getElementById("executors" + dataid).value =executors;
	parent.opener.document.getElementById("actors" + dataid).value =actors;
	parent.opener.document.getElementById("intro" + dataid).value =intro;
	parent.opener.document.getElementById("nextid" + dataid).value =nextid;
	parent.opener.document.getElementById("mustat" + dataid).value =mustat;
	parent.opener.document.getElementById("allOKModel" + dataid).value =allOKModel;
	parent.opener.document.getElementById("commFields" + dataid).value =vcommFields;
	parent.opener.document.getElementById("linkFields" + dataid).value =vlinkFields;
	parent.opener.document.getElementById("zdyFields" + dataid).value =fvlinkFields;
	parent.opener.document.getElementById("splinktype" + dataid).value =splinktype;
	parent.opener.document.getElementById("NodeType_" + dataid).innerHTML = (jdtypes == 0 ? "审核" : "执行");
	parent.opener.document.getElementById("NodeMEX_" + dataid).innerHTML = document.getElementById("executors1").innerText;
	parent.window.close();

}


//用于数据呈现修改xx+dataid		

function formSave(){
		if(Validator.Validate(document.all.date,2)==true){
					save();
		}
}

function clearDiv()
{
field1=document.getElementsByName("linkFields");
for (i = 0; i < field1.length; i++) {  field1[i].checked = false;}
field2=document.getElementsByName("commFields");
for (q = 0; q < field2.length; q++) {  field2[q].checked = false;}
field3=document.getElementsByName("count");
for (n = 0; n < field3.length; n++) {
	field3[n].checked = false;
		document.getElementById("zdymc"+n).value="";
		if(document.getElementById("zdyys"+n).value ==7){
			var mc = document.getElementsByName("desc"+n);
		for (var v = 0;v < mc.length; v++) {
			mc[v].value="";
		}
		}
		document.getElementById("zdyys"+n)[0].selected = true
	}
}

//雨果执行人中存在那么协作人中就不能存在，反之相同
function Treatment(str,dataids){
	var fexe=","+document.getElementById("executors").value+",";
	var fact=","+document.getElementById("actors").value+",";
	//alert(fact);
	var strdata=document.getElementsByName(str);
	for(sk=0; sk < strdata.length; sk++){
			if(fexe.indexOf(","+strdata[sk].value+",") > -1){
				//alert(strdata[sk].value);
				strdata[sk].disabled=true;
				}else{strdata[sk].disabled=false;
				}
		} 
}
function Treatment1(str,dataids){
	var fexe=","+document.getElementById("executors").value+",";
	var fact=","+document.getElementById("actors").value+",";
	//alert(fact);
	var strdata=document.getElementsByName(str);
	for(sk=0; sk < strdata.length; sk++){
			if(fact.indexOf(","+strdata[sk].value+",") > -1){
			strdata[sk].disabled=true;
			}else{strdata[sk].disabled=false;
				}	
		} 
}