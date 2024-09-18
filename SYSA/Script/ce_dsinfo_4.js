
function AjaxSend() {
    if ($('#userid').val() == 0) {
        alert('删除失败,关联竞争对手参数错误!');
        window.opener.location.reload();
        window.close();
        return false;
    } else {
        $.post('?', {
            __msgId: 'doDel',
            id: $('#userid').val()
        },
        function(data) {
            var msg = parseInt(data);
            if (msg == 1) {
                window.opener.location.reload();
                window.close();
            } else {
                alert('删除失败,关联竞争对手参数错误!');
                window.opener.location.reload();
                window.close();
            }
        })
    }
}

jQuery(function(){
	__ImgBigToSmall();
})