function pageResize(){
 var html=document.getElementsByTagName("html")[0],winWidth;
 if (window.innerWidth)
   winWidth = window.innerWidth;
   else if ((document.documentElement) && (document.documentElement.clientWidth))
   winWidth = document.body.clientWidth;
  if(winWidth>1440){html.style.zoom=winWidth/1440} 
}

window.onresize=function(){
  pageResize();
}
pageResize()