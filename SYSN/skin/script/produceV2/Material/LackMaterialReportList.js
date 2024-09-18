function GetColHtml(Coltype)
{
    if (Coltype < 0) {
        return "<td>延误<span style='color:red'>" + (-Coltype) + "<span>天<td>";
    }
    else {
        return "<td>"+Coltype+"";
    }
}
