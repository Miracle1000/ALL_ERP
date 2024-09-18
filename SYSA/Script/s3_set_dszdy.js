
function dataTypeChange(v, id) {
    var strValue = parseInt(v);
    if (strValue == 7) {
        $('#sz_' + id + '_4').css('display', '');
        $('#dispType_' + id).css('display', 'none');
    } else {
        if (strValue == 3 || strValue == 5 || strValue == 6) {
            $('#dispType_' + id).css('display', 'none');
            $('#sz_' + id + '_4').css('display', 'none');
        } else {
            $('#dispType_' + id).css('display', '');
            $('#sz_' + id + '_4').css('display', 'none');
        }
    }
}
function ShowDiv(id) {
    if ($('#sz_' + id + '_1').css('display') == 'none') {
        $('#sz_' + id + '_1').css('display', '');
        $('#sz_' + id + '_2').css('display', '');
    } else {
        $('#sz_' + id + '_1').css('display', 'none');
        $('#sz_' + id + '_2').css('display', 'none');
    }
}
function DelSend(ids) {
    $.get('?__msgId=doDel', {
        id: ids,
        typeid:parseInt($('#fieldemun_'+ ids).val())
    },
    function(data) {
        var msg = parseInt(data);
        if (msg == 1) {
            window.location.reload();
        }
		else
		{
			app.Alert(data);
		}
    })
}
function AddSend(ids) {
	document.getElementById("addtype").value = 1;
	document.getElementById("addtype").form.submit();
	return
    $.get('?__msgId=doSave',
    function(data) {
        var msg = parseInt(data);
        if (msg == 1) {
            window.location.reload();
        }
		else
		{
			app.Alert(data);
		}
    })
}
function CheckForm() {
    var arr = new Array();
	var s = true;
    var ibox = document.getElementsByTagName("input");
    var strTemp = '';
    for (var i = 0; i < ibox.length; i++) {
        if (ibox[i].id.indexOf("fieldName_") >= 0) {
            if ($('#' + ibox[i].id).val() == '') {
                $('#msg_' + ibox[i].id).html('必须为1到100个字符!');
                return false;
            }
            arr[arr.length] = ibox[i]
        }
    }
    for (var i = 0; i < arr.length; i++) {
        for (var ii = 0; ii < arr.length; ii++) {
            if (arr[ii].value == arr[i].value && ii != i) {
                $('#msg_' + arr[ii].id).html('字段名称有重复!');
				s = false;
            }
        }
    }
	return s;
}
