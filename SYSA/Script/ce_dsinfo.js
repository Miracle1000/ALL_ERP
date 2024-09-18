
function CheckForm() {
    if ($('#userId').val() == 0 || $('#dsinfo').val() == '') {
        $('#msgInfo').html('*未选择竞争对手!');
        return false;
    }
	var v = $('#dsMoney').val() ;
	if (isNaN(v) || v.length == 0)
	{	
		$('#msgprice').html('请输入正确的报价');
		return false;
	}
}
window.onunload = function() {
    window.opener.location.reload();
}
