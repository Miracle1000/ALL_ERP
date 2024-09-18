
var xmlHttpSP = false;
try
{
  xmlHttpSP = new ActiveXObject("Msxml2.XMLHTTP");
}
catch (e)
{
  try
  {
    xmlHttpSP = new ActiveXObject("Microsoft.XMLHTTP");
  }
  catch (e2)
  {
    xmlHttpSP = false;
  }
}
if (!xmlHttpSP && typeof XMLHttpRequest != 'undefined')
{
  xmlHttpSP = new XMLHttpRequest();
}

function check_SP(formobj,_sptype,_spid,_money1,_bz,_HLdate,_addcate,_extendcate,_ismodify)
{
	$("#cli").show();
	$("#spdiv").show();
	var extcate=_extendcate==undefined?"":_extendcate;
	var url = "../inc/CommonSPAjax.asp?app=getLastSP&sptype=" + _sptype + "&spid=" + _spid + "&money1=" + _money1 + "&bz=" + _bz + "&HLdate=" + escape(_HLdate) + "&addcate=" + _addcate + "&extcate=" + extcate + "&ismodify=" + _ismodify + "&stamp=" + Math.round(Math.random() * 100);

  xmlHttpSP.open("GET", url, false);
  xmlHttpSP.setRequestHeader("If-Modified-Since","0");
  xmlHttpSP.onreadystatechange = function () {
      if (xmlHttpSP.readyState == 4) {
          var rValue = xmlHttpSP.responseText;
          if (rValue == "0") {
              var spidobj = document.createElement("input");
              spidobj.name = "_spid";
              spidobj.type = "hidden";
              spidobj.value = _spid;
              formobj.appendChild(spidobj);

              if (typeof (sp_fSubmit) == "function") {
                  sp_fSubmit();
              }
              else {
                  formobj.submit();
              }
          }
          else {
              showSPUsers(formobj, _sptype, _spid, _money1, _bz, _HLdate, _addcate, extcate, _ismodify);
              $('#_sp_usr').dialog('open');
              var b = (document.body.offsetWidth / 2 - document.getElementById("_sp_usr").offsetWidth / 2);
              var a = { left: b, top: $(document).scrollTop() + ($(window).height() - 260) * 0.5 };
              $('#_sp_usr').dialog('move', a);
              document.getElementById("_sp_sbmit").onclick = function () { checkSPUser(formobj, rValue) };
          }
      }
  }
  xmlHttpSP.send(null);
}

function checkSPUser(fobj,_spid)
{
	if(document.getElementById("spuser").value=="")
	{
		document.getElementById("_sp_errmsg").innerHTML="请选择审批人！";
		document.getElementById("spuser").focus();
	}
	else
	{
		$('#_sp_usr').dialog('close');
		$('#_spsb').dialog('open');
		var b=(document.body.offsetWidth/2-document.getElementById("_spsb").offsetWidth/2);
		var a={left:b,top:150};
		$('#_spsb').dialog('move',a);
		var spidobj=document.createElement("input");
		spidobj.name="_spid";
		spidobj.type="hidden";
		spidobj.value=_spid;
		fobj.appendChild(spidobj);
		var spuidobj=document.createElement("input");
		spuidobj.name="_spuid";
		spuidobj.type="hidden";
		spuidobj.value=document.getElementById("spuser").value;
		fobj.appendChild(spuidobj);
		if(typeof(sp_fSubmit)=="function")
		{
			sp_fSubmit();
		}
		else
		{
			fobj.submit();
		}
	}
}

function showSPUsers(formobj,_sptype,_spid,_money1,_bz,_HLdate,_addcate,_extendcate,_ismodify)
{
	var extcate=_extendcate==undefined?"":_extendcate;
	var url = "../inc/CommonSPAjax.asp?app=ShowSPUsers&sptype=" + _sptype + "&spid=" + _spid + "&money1=" + _money1 + "&bz=" + _bz + "&HLdate=" + escape(_HLdate) + "&addcate=" + _addcate + "&extcate=" + extcate + "&ismodify="+_ismodify+"&stamp=" + Math.round(Math.random() * 100);
  xmlHttp.open("GET", url, false);
  xmlHttp.setRequestHeader("If-Modified-Since","0");
  xmlHttp.onreadystatechange = function () {
      if (xmlHttp.readyState == 4) {
          var rValue = xmlHttp.responseText;
          if (rValue != "") {
              var spobj = document.getElementById("spuser");
              RemoveAll(spobj);
              var gts = rValue.split("@*;!&");
              for (var i = 0; i < gts.length; i++) {
                  var gto = gts[i].split("#*,@~");
                  OptionAdd(spobj, gto[1], gto[0]);
              }
          }
          else {

          }
      }
  };
  xmlHttp.send(null);
}

function RemoveAll(obj){while(obj.options[0]){obj.options.remove(0);}}
function OptionAdd(obj,skey,svalue){obj.options.add(new Option(skey,svalue));}
