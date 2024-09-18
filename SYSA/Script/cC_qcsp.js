
window.onload=function(){
	var grayImg = document.getElementsByTagName("img");
	if(grayImg.length>0){
		for(i=0; i<grayImg.length; i++){
			if(grayImg[i].width>550){
				grayImg[i].width = 550;
			}
			if(grayImg[i].height>150){
				grayImg[i].height = 150;
			}
		}
	}
}
