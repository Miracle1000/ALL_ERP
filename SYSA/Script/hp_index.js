
//delect link dotted line
function $(name){
	return document.getElementById(name);
}
function Switchmenu(obj,name) {
    if (document.getElementById) {
        var el = document.getElementById(name + "_" + obj);
        var ar = document.getElementById(name).getElementsByTagName("ul");
        if (el.style.display != "block") {
            for (var i = 0; i < ar.length; i++) {
                ar[i].style.display = "none";
                document.getElementById(name + (i + 1)).className = "nav_tab"
            }
            el.style.display = "block";
            document.getElementById(name + obj).className = "navtab_hover"
        } else {
            el.style.display = "none";
            document.getElementById(name + obj).className = "nav_tab"
        }
    }
}
 function window.onload(){
 parent.document.getElementById("cFF2").style.height=document.body.scrollHeight;
 parent.parent.document.getElementById("cFF").style.height=parent.document.body.scrollHeight;
}
