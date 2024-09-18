function LinkSelf()
{
    var value = $('[name=\"ReportType\"]:checked').val();
    window.location.href = "?ReportType="+value+"";
}


function SetMachineForWP(ID) {
    var win = app.createWindow("__sys_machine_clientDiv", "设备设置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='machineDlgDiv' style='height:99%'>"
		+ "<iframe name='machineifr' id='machineifr' src='SetMachineForWP.ashx?ord=" + ID + "&viewtype=1'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

function SetPersonForWP(ID) {
    var win = app.createWindow("__sys_person_clientDiv", "人员设置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='personDlgDiv' style='height:99%'>"
		+ "<iframe name='personifr' id='personifr' src='SetMachineForWP.ashx?ord=" + ID + "&viewtype=2'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

//设备一览表设备安置页面
function SetMachine(MacLId,StationId){
    var win = app.createWindow("__sys_setmachine_clientDiv", "设备安置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setmachineifr' id='Setmachineifr' src='SetMachineForWP.ashx?viewtype=3&ord="+StationId+"&MacLId="+MacLId+"'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

//设备一览表点"+"号设备安置页面
function SetMachineJia(MacLId, StationId) {
    var win = app.createWindow("__sys_setmachine_clientDiv", "设备安置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setmachineifr' id='Setmachineifr' src='SetMachineForWP.ashx?viewtype=3&ord=" + 0 + "&MacLId=" + MacLId + "'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

//人员一览表人员安置页面
function SetPerson(personId, StationId) {
    var win = app.createWindow("__sys_setperson_clientDiv", "人员安排", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setpersonifr' id='Setpersonifr' src='SetMachineForWP.ashx?ord=" + StationId + "&viewtype=4&personId=" + personId + "'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

//人员一览表重排
function NewSetPerson(personId, StationId) {
    var win = app.createWindow("__sys_setperson_clientDiv", "人员安排", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setpersonifr' id='Setpersonifr' src='SetMachineForWP.ashx?ord=" + StationId + "&viewtype=8&personId=" + personId + "'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

//设备一览表设备重置页面
function NewSetMachine(MacLId, StationId) {
    var win = app.createWindow("__sys_setmachine_clientDiv", "设备安置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setmachineifr' id='Setmachineifr' src='SetMachineForWP.ashx?viewtype=9&ord=" + StationId + "&MacLId=" + MacLId + "'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

function SetMachineForWPByReportType(ID) {
    var win = app.createWindow("__sys_machine_clientDiv", "设备设置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='machineDlgDiv' style='height:99%'>"
		+ "<iframe name='machineifr' id='machineifr' src='SetMachineForWP.ashx?ord=" + ID + "&viewtype=1'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

function SetPersonForWPByReportType(ID) {
    var win = app.createWindow("__sys_person_clientDiv", "人员设置", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='personDlgDiv' style='height:99%'>"
		+ "<iframe name='personifr' id='personifr' src='SetMachineForWP.ashx?ord=" + ID + "&viewtype=6'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}

////人员一览表"+"号安排页面
function APSetPerson(personId, StationId) {
    var win = app.createWindow("__sys_setperson_clientDiv", "人员安排", {
        width: 800,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true
    });

    win.innerHTML = "<div id='SetmachineDlgDiv' style='height:99%'>"
		+ "<iframe name='Setpersonifr' id='Setpersonifr' src='SetMachineForWP.ashx?ord=" + StationId + "&viewtype=14&personId=" + personId + "'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
		+ "</div>";
}