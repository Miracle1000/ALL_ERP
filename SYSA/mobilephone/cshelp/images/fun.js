var sysWidth = 100;
var sysHeight = 100;
$(function(){
	sysWidth = document.body.offsetWidth;
	sysHeight =document.body.offsetHeight;
	var currUrl = window.location.href;		
	if (currUrl.slice(-7) == "cshelp/" || currUrl.indexOf("cshelp/index.html")>-1){
		var menu = $(".menu");
		menu.css("width",sysWidth);
		//menu.css("height",sysHeight);

		$("ul li div").click(function(){
			var li = $(this).parent();
			var liul = $(this).parent().children("ul");
			var licls = li.attr("class");
			li.toggleClass("show1");
			if(licls == "show1" || licls == "show"){
				liul.css("display","none");
			}else{
				liul.css("display","block");
			}
		});

		$("ul li ul li a").click(function(e){		
			var href = $(this).attr("href");
			var atxt = $(this).text();
			showWin(atxt, href);
			return false;
		});
	}else{
		try{
			$("#content p a").click(function(){		
				var href = $(this).attr("href");
				var atxt = $(this).text();
				showWin(atxt, href);
				return false;
			});
		}catch(e){}
	}

});	
	
function showWin(atxt, href){
	event.stopPropagation();
	var headiv = $("#tophead");
	headiv.html(atxt);
	var  htmlobj=$.ajax({url:href,async:false});
	document.getElementById("Ifrmv").innerHTML = htmlobj.responseText;
	document.getElementById("divFrm").style.display = "block";
}

function closeWin(){
	document.getElementById("divFrm").style.display = "none";
	document.getElementById("Ifrmv").innerHTML = "";
	return false;
}