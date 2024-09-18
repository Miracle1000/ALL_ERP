//--处理备注中尺寸过大的图片
function __ImgFormat(){
	var imgs = document.getElementsByTagName("img");
	for (var i = 0; i < imgs.length; i++)
	{
		if (imgs[i].src.indexOf('/edit/upimages/') >= 0)
		{
			var w = imgs[i].offsetWidth;
			if (w > 300)
			{
				imgs[i].style.width = "100px";
				imgs[i].style.cursor = "pointer";
				imgs[i].onclick = function(){
					window.open(this.src);
				}
			}
		}
	}
}
$(document).ready(function(){
	try
	{
		__ImgFormat();
	}
	catch (err)
	{
	}
});