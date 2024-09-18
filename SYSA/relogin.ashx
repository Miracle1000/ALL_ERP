<%@  WebHandler Language="C#" Class="ZBServices.SYSA.view.ReLoginClass" %>
using System;
using System.Web;
namespace ZBServices.SYSA.view{
    public partial class ReLoginClass :  IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Redirect("../SYSN/view/init/relogin.ashx" + context.Request.Url.Query);
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}