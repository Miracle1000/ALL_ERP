
function SetCookie(name, value)
{
var expdate = new Date();
var argv = SetCookie.arguments;
var argc = SetCookie.arguments.length;
var expires = (argc > 2) ? argv[2] : null;
var path = (argc > 3) ? argv[3] : null;
var domain = (argc > 4) ? argv[4] : null;
var secure = (argc > 5) ? argv[5] : false;
if(expires!=null) expdate.setTime(expdate.getTime() + ( expires * 1000 ));
document.cookie = name + "=" + escape (value) +((expires == null) ? "" : ("; expires="+ expdate.toGMTString()))
+((path == null) ? "" : ("; path=" + path)) +((domain == null) ? "" : ("; domain=" + domain))
+((secure == true) ? "; secure" : "");
}

function adDoSearch(result)
{
	
	parent.advance(result);
	if(!document.getElementById("sflg").checked){parent.Left_adClose();}
}

function adsUnClose(obj)
{
	SetCookie("EmailAddressADS_"+window.currUse,obj.checked?"1":"0");
}

function adDoReset()
{
	window.location.reload();	
}

$(function(){
	$("#searchBtn").live("click",function(){
		var groupArr = new Array();
		$("input[name=group]:checked").each(function(index, ele) {
            var v = $(ele).val();
			groupArr.push(v);
        });
		
		var group = groupArr.join(",");
		var pName = $("input[name=pName]").val();
		var gender = $("input[name=gender]:checked").val();
		var position = $("input[name=position]").val();
		var mobile = $("input[name=mobile]").val();
		if(gender==undefined){
			gender = '';	
		}
		
		$.post("search_person.asp",{"C":"0","sort":"0","ftype":"3","group":group,"pName":escape(pName),"gender":escape(gender),"position":escape(position),"mobile":escape(mobile)},function(data){
			adDoSearch(data);	
		});
		
	});
	
});
