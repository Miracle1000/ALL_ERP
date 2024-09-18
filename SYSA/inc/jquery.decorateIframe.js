/*
*Author:karry
*Version:1.0
*Time:2008-11-19
*jquery1.2.6
*涓篒E6鎴栦箣鍓嶇殑鐗堟湰瑙ｅ喅Select妗嗕細瑕嗙洊浣廌IV鍥惧眰鐨凚UG
*鍙湁鍦↖E鐗堟湰灏忎簬7鐨勬椂鍊欐墠浼氭墽琛屼互涓嬩唬鐮?
*/
;(function($) {
    $.fn.decorateIframe = function(options) {
        if ($.browser.msie && $.browser.version < 7) {
            var opts = $.extend({}, $.fn.decorateIframe.defaults, options);
            $(this).each(function() {
                var $myThis = $(this);
                //鍒涘缓涓€涓狪FRAME
                var divIframe = $("<iframe />");
                divIframe.attr("id", opts.iframeId);
                divIframe.css("position", "absolute");
                divIframe.css("display", "none");
                divIframe.css("display", "block");
                divIframe.css("z-index", opts.iframeZIndex);
                divIframe.css("border");
                divIframe.css("top", "0");
                divIframe.css("left", "0");
                if (opts.width == 0) {
                    divIframe.css("width", $myThis.width() + parseInt($myThis.css("padding")) * 2 + "px");
                }
                if (opts.height == 0) {
                    divIframe.css("height", $myThis.height() + parseInt($myThis.css("padding")) * 2 + "px");
                }
                divIframe.css("filter", "mask(color=#fff)");
                $myThis.append(divIframe);
            });
        }
    }
    $.fn.decorateIframe.defaults = {
        iframeId:"decorateIframe1",
        iframeZIndex:-1,
        width:0,
        height:0
    }
})(jQuery);