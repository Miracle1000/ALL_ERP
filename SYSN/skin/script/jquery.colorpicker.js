/**
 * jQuery插件：颜色拾取器
 * 
 * @author  Karson
 * @url     http://blog.iplaybus.com
 * @name    jquery.colorpicker.js
 * @since   2012-6-4 15:58:41
 */
(function($) {
    var ColorHex=new Array('00','33','66','99','CC','FF');
    var SpColorHex=new Array('FF0000','00FF00','0000FF','FFFF00','00FFFF','FF00FF');
    $.fn.colorpicker = function(options) {
        var opts = jQuery.extend({}, jQuery.fn.colorpicker.defaults, options);
        initColor();
        return this.each(function(){
            var obj = $(this);
            obj.bind(opts.event,function(){
                //定位
                var ttop  = $(this).offset().top;     //控件的定位点高
                var thei  = $(this).height();  //控件本身的高
                var tleft = $(this).offset().left;    //控件的定位点宽
                $("#colorpanel").css({
                    top:ttop+thei+5,
                    left:tleft,
                    zIndex:1000
                }).show();
                var target = opts.target ? $(opts.target) : obj;
                if(target.data("color") == null){
                    target.data("color",target.css("color"));
                }
                if(target.data("value") == null){
                    target.data("value",target.val());
                }

                $("#_creset").bind("click",function(){
                    target.val("");
					target.css("color","");
					target.css("backgroundcolor","");
					opts.success(obj,"");
					target.html("");
                    $("#colorpanel").hide();
                });

				 $("#_cclose").bind("click",function(){
                    $("#colorpanel").hide();
                    opts.reset(obj);
                });
                var htm=obj.html();
                $("#DisColor").css("background",htm||"#fff");
                $("#HexColor").val(htm);
                $("#CT tr td").unbind("click").mouseover(function(){
                    var color=$(this).css("background-color");
                    $("#DisColor").css("background",color);
                    $("#HexColor").val($(this).attr("rel"));
                }).click(function(){
                    var color=$(this).attr("rel");
                    color = opts.ishex ? color : getRGBColor(color);
                    if(opts.fillcolor) target.val(color);
                    target.css("color",color);
                    $("#colorpanel").hide();
                    $("#_creset").unbind("click");
					$("#_cclose").unbind("click");
                    opts.success(obj,color);
                });
                    $("body").bind("click",function (e) {
                        if(obj&&obj[0]){
                            if(e.target!=obj[0]){
                                $("#colorpanel").hide();
                            }else{
                                $("#colorpanel").show();
                            }
                        }
                    })
            });
        });

        function initColor(){
            $("body").append('<div id="colorpanel" style="position: absolute; display: none;padding:10px;background:#FFF;box-shadow:0px 2px 6px 0px rgba(43, 43, 43, 0.42);"></div>');
            var colorTable = '';
            var colorValue = '';
            for(i=0;i<2;i++){
                for(j=0;j<6;j++){
                    colorTable=colorTable+'<tr height=15>';
                    colorTable=colorTable+'<td width=11 rel="#000000" style="background-color:#000000">';
                    colorValue = i==0 ? ColorHex[j]+ColorHex[j]+ColorHex[j] : SpColorHex[j];
                    colorTable=colorTable+'<td width=11 rel="#'+colorValue+'" style="background-color:#'+colorValue+'">'
                    colorTable=colorTable+'<td width=11 rel="#000000" style="background-color:#000000">'
                    for (k=0;k<3;k++){
                        for (l=0;l<6;l++){
                            colorValue = ColorHex[k+i*3]+ColorHex[l]+ColorHex[j];
                            colorTable=colorTable+'<td width=11 rel="#'+colorValue+'" style="background-color:#'+colorValue+'">'
                        }
                    }
                }
            }
            colorTable='<table width=320 border="0" cellspacing="0" cellpadding="0" style="border:0px solid #000;">'
            +'<tr height=30><td colspan=21 bgcolor=#FFFFFF>'
            +'<table cellpadding="0" cellspacing="1" border="0" style="border-collapse: collapse">'
            +'<tr><td width="3"><td><input type="text" id="DisColor" size="6" disabled style="height:28px;width:28px;box-sizing:border-box;border:solid 1px #ccc;background-color:#ffff00"></td>'
            +'<td width="3"><td><input type="text" id="HexColor" readonly size="7" style="margin-left:2px;height:28px;box-sizing:border-box;border:1px solid #CCC;font-family:Arial;" value="#000000">&nbsp;&nbsp;'
			+'<a href="javascript:void(0);" style="position:relative;top:2px;left:30px;padding:4px 20px;height:28px;background:#EFEFEF;box-sizing:border-box;" id="_creset">清除</a>'
			+'<a href="javascript:void(0);" style="position:relative;top:2px;left:46px;padding:4px 20px;height:28px;background:#EFEFEF;box-sizing:border-box;" id="_cclose">关闭</a>'
			+ '</td></tr></table></td></table>'
            +'<table id="CT" style="width:320px;border-collapse:collapse;margin-top:14px;" border="1" cellspacing="0" cellpadding="0" bordercolor="000000"  style="cursor:pointer;">'
            +colorTable+'</table>';
            $("#colorpanel").html(colorTable);
            // $("#_cclose").live('click',function(){
            //     $("#colorpanel").hide();
            //     return false;
            // }).css({
            //     "font-size":"12px",
            //     "padding-left":"20px"
            // });
        }

        function getRGBColor(color) {
            var result;
            if ( color && color.constructor == Array && color.length == 3 )
                color = color;
            if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
                color = [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];
            if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
                color =[parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];
            if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
                color =[parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];
            if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
                color =[parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];
            return "rgb("+color[0]+","+color[1]+","+color[2]+")";
        }
    };
    jQuery.fn.colorpicker.defaults = {
        ishex : true, //是否使用16进制颜色值
        fillcolor:false,  //是否将颜色值填充至对象的val中
        target: null, //目标对象
        event: 'click', //颜色框显示的事件
        success:function(){}, //回调函数
        reset:function(){}
    };
})(jQuery);