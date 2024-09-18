$(document).ready(function () {
    var listtext = $("input[name='serchkeyTxt']");
    listtext[0].style.cssText = "background:#ffffff; border: 1px solid #b6c0c9; cursor:pointer; padding-left: 2px; margin: 0;height: 16px;line-height: 16px;"

    //与css中样式对应,控制input获取焦点后立马失去焦点,以达到隐藏input样式的目的(注:input获取焦点会显示边框和背景)
    $("body").on("click", "#lvw_dbtable_MainList input.billfieldbox", function () {
        $(this).blur();
    });

});