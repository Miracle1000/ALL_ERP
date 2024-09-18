
function AjaxSend() {
    if ($('#userId').val() == 0 || $('#dsinfo').val() == '') {
        $('#msgInfo').html('＊未选择竞争对手!');
        return false
    }
	return true 
}
