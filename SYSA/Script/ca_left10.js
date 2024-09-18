
<!--
function show_tab(n)
{ 
  if ((n<1) || (n>3)) return;
  var obj1 = document.getElementById('tab1');
  var obj11 = document.getElementById('tab11');
  var obj2 = document.getElementById('tab2');
  var obj21 = document.getElementById('tab21');
  var obj3 = document.getElementById('tab3');
  var obj31 = document.getElementById('tab31');
  var img1 = document.getElementById('Image42');
  var img2 = document.getElementById('Image43');
  var img3 = document.getElementById('Image44');
if (n==1)
  {
    obj1.style.display = "";
	obj11.style.display = "";
    img1.background='../images/tag_bg5.gif';
    obj2.style.display = "none";
	obj21.style.display = "none";
    img2.background='../images/tag_bg4.gif';
    obj3.style.display = "none";
	obj31.style.display = "none";
    img3.background='../images/tag_bg4.gif';
  }
  else if (n==2)
  {
    obj1.style.display = "none";
	obj11.style.display = "none";
    img1.background='../images/tag_bg4.gif';
    obj2.style.display = "";
	obj21.style.display = "";
    img2.background='../images/tag_bg5.gif';
    obj3.style.display = "none";
	obj31.style.display = "none";
    img3.background='../images/tag_bg4.gif';
 }
 else if (n==3)
  { 
    obj1.style.display = "none";
	obj11.style.display = "none";
    img1.background='../images/tag_bg4.gif';
    obj2.style.display = "none";
	obj21.style.display = "none";
    img2.background='../images/tag_bg4.gif';
    obj3.style.display = "";
	obj31.style.display = "";
    img3.background='../images/tag_bg5.gif';
   
 }

  else return;
}
//-->
