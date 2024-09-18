function UrlEncode(data){
    //return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
	var ascCodev = "& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ · ˉ ¨ 々 ～ ‖ 」 「 『 』 ． 〖 〗 【 】 � ‰ ◆ ◎ ★ ☆ § ā á ǎ à ō ó ǒ ò ê ē é ě è ī í ǐ ì ū ú ǔ ù ǖ ǘ ǚ ǜ ü μ μ ˊ ﹫ ＿ ﹌ ﹋ ′ ˋ ― ︴ ˉ ￣ θ ε ‥ ☉ ⊕ Θ ◎ の ⊿ … ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ⌒ ￠ ℡ ㈱ ㊣ ▏ ▕ ▁ ▔  ↑  → ←  ↓  卍 ◤ ◥ ◢ ◣ 卐 ∷ № § Ψ ￥ ￡ ≡ ￢ ＊ Ю ㎡ ±".split(" ");
	var ascCodec = "%26+%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5+%a1%a4+%a1%a5+%a1%a7+%a1%a9+%a1%ab+%a1%ac+%a1%b9+%a1%b8+%a1%ba+%a1%bb+%a3%ae+%a1%bc+%a1%bd+%a1%be+%a1%bf+%80+%a1%eb+%a1%f4+%a1%f2+%a1%ef+%a1%ee+%a1%ec+%a8%a1+%a8%a2+%a8%a3+%a8%a4+%a8%ad+%a8%ae+%a8%af+%a8%b0+%a8%ba+%a8%a5+%a8%a6+%a8%a7+%a8%a8+%a8%a9+%a8%aa+%a8%ab+%a8%ac+%a8%b1+%a8%b2+%a8%b3+%a8%b4+%a8%b5+%a8%b6+%a8%b7+%a8%b8+%a8%b9+%u03bc+%a6%cc+%a8%40+%a9%88+%a3%df+%a9k+%a9j+%a1%e4+%a8A+%a8D+%a6%f5+%a1%a5+%a3%fe+%a6%c8+%a6%c5+%a8E+%a8%91+%a8%92+%a6%a8+%a1%f2+%a4%ce+%a8S+%a1%ad+%a8x+%a8y+%a8z+%a8%7b+%a8%7c+%a8%7d+%a8%7e+%a8%80+%a8%81+%a8%82+%a8%83+%a8%84+%a8%85+%a8%86+%a8%87+%a1%d0+%a1%e9+%a9Y+%a9Z+%a9I+%a8%87+%a8%8a+%a8x+%a8%89+%a8I+%a1%fc+%a8J+%a1%fa+%a1%fb+%a8L+%a1%fd+%a8K+%85d+%a8%8f+%a8%90+%a8%8d+%a8%8e+%85e+%a1%cb+%a1%ed+%a1%ec+%a6%b7+%a3%a4+%a1%ea+%a1%d4+%a9V+%a3%aa+%a7%c0+%a9O+%u00b1".split("+");
	data = data + '';
	data = data.replace(/\s/g, "kglllskjdfsfdsdwerr");
	data = data.replace(/\+/g, "abekdalfdajlkfdajfda");
	data = escape(data);
	if(data.indexOf("%B5")>-1){
		data = data.replace("%B5","%u03BC")
	}
	data = unescape(data);
	if (!isNaN(data) || !data) { return data; }
	for (var i = 0; i < ascCodev.length; i++) {
		if(data.indexOf(ascCodev[i])>-1 && ascCodev[i].length >0){
			var re = new RegExp(ascCodev[i], "g")
			data = data.replace(re, "ajaxsrpchari" + i + "endbyjohnny");
			re = null;
		}
	}

	data = escape(data);
	
	for (var i = ascCodev.length - 1; i > -1; i--) {
		if(data.indexOf("ajaxsrpchari" + i + "endbyjohnny")>=0) {
			if (ascCodec[i].length == 0)
			{
				var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
				data = data.replace(re, " ");
				re = null;
			}else{
				var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
				data = data.replace(re, ascCodec[i]);
				re = null;
			}
		}
	}
	data = data.replace(/\*/g, "%2A"); 	//置换*		
	data = data.replace(/\-/g, "%2D"); 	//置换-
	data = data.replace(/\@/g, "%40"); 	//置换@
	data = data.replace(/\_/g, "%5F"); 	//置换_
	data = data.replace(/\//g, "%2F"); 	//置换/
	data = data.replace(/kglllskjdfsfdsdwerr/g, "%20")
	data = data.replace(/abekdalfdajlkfdajfda/g,"%2B");
	data = data.replace(/abekdalfdajlkfdajfda/g,"%2B");
	data = data.replace(/\%23/g,"#"); //还原#号
	data = data.replace(/\%B2/g,"&#178;"); //平方
	data = data.replace(/\%B3/g,"&#179;"); //立方
	data = data.replace(/\%a9O/g,"&#13217;"); //平方米
	return data;
}