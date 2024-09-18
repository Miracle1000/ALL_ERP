// lvwdbname 操作的list
// referdbname 参照列的DBname
// setdbname  要设置列的DBname
function ReComputeShareMoney() {
    var lvwdbname = 'CostsShareListLvw';
    var allsharemoney = $('#ShareMoney_0').val().replace(/\,/g, "") * 1.0;
    var setdbname = 'ShareNum';
    var referdbname=0;
    var types = document.getElementsByName("ShareType");
    for (var i = 0; i < types.length; i++) {

        if (types[i].checked) {

            referdbname = types[i].value*1;

        }
    }
   
    switch(referdbname)
    {
        case 0:
            referdbname = 'KuinNum';
            break;
        case 1:
            referdbname = 'ProcessHour';
            break;
        case 2:
            referdbname = 'DirectMaterial';
            break;
        case 3:
            referdbname = 'LabourWage';
            break;
        case 4:
            referdbname = 'DirectCost';
            break;
        case 5:
            referdbname = 'CompleteNum';
            break;
        default:
            referdbname = 'KuinNum';
    }
    var lvw = ListView.GetListViewById(lvwdbname);
    var arr = lvw.rows;
    var inputarrlength=arr.length;
    var inputarr = new Array(inputarrlength);
    var sum = 0;
    var h = ListView.GetHeaderByDBName(lvw, referdbname).index;
    var sindex = ListView.GetHeaderByDBName(lvw, setdbname).index;
    //计算参照列总额
    for (var i = 0; i < arr.length; i++) {	

            sum=sum+arr[i][h];
    }
    //执行分摊逻辑
    var inputsum = 0;
    for (var i = 0; i < arr.length; i++) {
        if (sum == 0)
        {
            inputarr[i] = (allsharemoney / inputarrlength).toFixed(window.SysConfig.MoneyBit);
            inputsum = (inputsum + 1.0*inputarr[i]);
        }
        else {
            inputarr[i] = (allsharemoney*(arr[i][h] / sum)).toFixed(window.SysConfig.MoneyBit);
            inputsum = inputsum + 1.0*inputarr[i];
        }
    }
    //调整分摊后的差异部分，如果少了，补在最后一行，否则从第一行开始逐行扣减
    if (inputsum <= allsharemoney)
    {
        inputarr[inputarrlength - 1] = inputarr[inputarrlength - 1]*1.0 + allsharemoney * 1.0 - inputsum;
    }
    else
    {
        var left = inputsum-allsharemoney*1.0 ;
        for (var i = 0; i < inputarr.length; i++)
        {
            if (inputarr[i] >= left)
            {
                inputarr[i] = inputarr[i]*1.0 - left;
                break;
            }
           else
            {
                left = left - inputarr[i]*1.0;
                inputarr[i] = 0;
            }

        }
    }
    //更新lvw
    for (var i = 0; i < inputarr.length; i++)
    {
        __lvw_je_setcelldatav(lvw, i, sindex, inputarr[i], false);
    }
    ___RefreshListViewByJson(lvw);
    ListView.AutoExecLvwFormula(lvw, sindex);
}