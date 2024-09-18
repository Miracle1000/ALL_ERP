
var ColorHex=new Array('00','33','66','99','CC','FF');
var SpColorHex=new Array('FF0000','00FF00','0000FF','FFFF00','00FFFF','FF00FF');
var SignsHex=new Array(new Array(),new Array())
SignsHex[0]=new Array('○','●','△','▲','☆','★','□','■','◇','◆')
SignsHex[1]=new Array('♀','♂','@','＊','※','§','№','㊣','＃','⊙')
SignsHex[2]=new Array('①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩')
$(function(){
    initColor();
    $("#colorpanel").hide();
		  initSigns();
    $("#SignsPanel").hide();
})

function hex(x) {
	return ("0" + parseInt(x).toString(16)).slice(-2);
}
function ColorToHEX(rgb){
	if(!$.browser.msie){
		rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
		rgb= "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
	}
	return rgb;
}

function initColor(){
    $("body").append('<div id="colorpanel" style="position: absolute; display: none;"></div>');
    var colorTable='';
    for(i=0;i<2;i++){
        for(j=0;j<6;j++){
            colorTable=colorTable+'<tr height=12>'
            colorTable=colorTable+'<td width=11 style="background-color:#000000">'
        
            if (i==0){
                colorTable=colorTable+'<td width=11 style="background-color:#'+ColorHex[j]+ColorHex[j]+ColorHex[j]+'">'
            }else{
                colorTable=colorTable+'<td width=11 style="background-color:#'+SpColorHex[j]+'">'
            } 

            colorTable=colorTable+'<td width=11 style="background-color:#000000">'
            for (k=0;k<3;k++){
                   for (l=0;l<6;l++){
                    colorTable=colorTable+'<td width=11 style="background-color:#'+ColorHex[k+i*3]+ColorHex[l]+ColorHex[j]+'">'
                   }
             }
        }
    }
    
    colorTable='<table width=253 border="0" cellspacing="0" cellpadding="0" style="border:1px #000000 solid;border-bottom:none;border-collapse: collapse" bordercolor="000000">'
               +'<tr height=30><td colspan=21 bgcolor=#cccccc>'
               +'<table cellpadding="0" cellspacing="1" border="0" style="border-collapse: collapse">'
               +'<tr><td width="3"><td><input type="text" id="DisColor" size="6" disabled style="border:solid 1px #000000;background-color:#ffff00"></td>'
               +'<td width="3"><td><input type="text" id="HexColor" size="7" style="border:inset 1px;font-family:Arial;" value="#000000"><a href=### id="_cclose">关闭</a></td></tr></table></td></table>'
               +'<table id="CT" border="1" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="000000"  style="cursor:pointer;">'
               +colorTable+'</table>';          
    $("#colorpanel").html(colorTable);
}

function showColorPanel(obj,txtobj){
    $('#'+obj).click(function(){
        //定位
        var ttop  = $(this).offset().top;     //控件的定位点高
        var thei  = $(this).height();  //控件本身的高
        var tleft = $(this).offset().left;    //控件的定位点宽
        
        $("#colorpanel").css({
            top:ttop+thei+5,
            left:tleft
        })        

        $("#colorpanel").show();
        
        $("#CT tr td").unbind("click").mouseover(function(){
            var aaa=$(this).css("background-color");
			aaa = ColorToHEX(aaa);
            $("#DisColor").css("background-color",aaa);
            $("#HexColor").val(aaa);
        }).click(function(){
            var aaa=$(this).css("background-color");
			aaa = ColorToHEX(aaa);
            $('#'+txtobj).val(aaa).css("color",aaa);
            $("#colorpanel").hide();
        })

        $("#_cclose").click(function(){$("#colorpanel").hide();}).css({"font-size":"12px","padding-left":"20px"})
    })
}
function initSigns(){
    $("body").append('<div id="SignsPanel" style="position: absolute; display: none;"></div>');
    var SignsTable='';
		  for(j=0;j<3;j++)
			{
		 SignsTable=SignsTable+'<tr height=12>'
        for(i=0;i<10;i++){
         SignsTable=SignsTable+'<td width=11 style="background-color:#ffffff" title='+SignsHex[j][i]+'>'+SignsHex[j][i]
            }
			}
    SignsTable='<table width=131 border="0" cellspacing="0" cellpadding="0" style="border:1px #000000 solid;border-bottom:none;border-collapse: collapse" bordercolor="000000">'
               +'<tr height=20><td colspan=21 bgcolor=#cccccc>'
               +'<table cellpadding="0" cellspacing="1" border="0" style="border-collapse: collapse">'
               +'<tr><td width="3"><td></td>'
               +'<td width="3"><td><input type="text" id="HexSigns" size="5"  style="border:inset 1px;font-family:Arial;" value="○"><a href=### id="_sclose">关闭</a></td></tr></table></td></table>'
               +'<table id="ST" border="1" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="000000"  style="cursor:pointer;">'
               +SignsTable+'</table>';          
    $("#SignsPanel").html(SignsTable);
}

function showSignsPanel(obj,txtobj){
    $('#'+obj).click(function(){
        //定位
        var ttop  = $(this).offset().top;     //控件的定位点高
        var thei  = $(this).height();  //控件本身的高
        var tleft = $(this).offset().left;    //控件的定位点宽
        
        $("#SignsPanel").css({
            top:ttop+thei+5,
            left:tleft
        })        

        $("#SignsPanel").show();
        $("#ST tr td").unbind("click").mouseover(function(){
           var bbb=$(this).attr("title");
//            $("#DisColor").css("background-color",aaa);
           $("#HexSigns").val(bbb);
        }).click(function(){
					var bbb=$(this).attr("title");
            $('#'+txtobj).val(bbb);
            $("#SignsPanel").hide();
        })

        $("#_sclose").click(function(){$("#SignsPanel").hide();}).css({"font-size":"12px","padding-left":"20px"})
    })
}

jQuery.extend({
    showcolor:function(btnid,txtid){showColorPanel(btnid,txtid);  },
		showSigns:function(btnid,txtid){showSignsPanel(btnid,txtid);  }
})

