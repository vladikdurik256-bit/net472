using System;
using System.Drawing;
using System.Numerics;
using System.Windows.Forms;
using System.Xml.Linq;
using System.Data;
using System.Net.Http;
using System.IO;
using System.IO.Compression;

static class FrameworkProbe
{
    static void Check(bool ok, string name) {
        if (!ok) throw new Exception("FAIL " + name);
        Console.WriteLine("PASS " + name);
    }
    [STAThread]
    static void Main() {
        Vector3 v = Vector3.Transform(new Vector3(1,2,3), Matrix4x4.CreateTranslation(4,5,6));
        Check(v == new Vector3(5,7,9) && BigInteger.Pow(2, 100).ToString() == "1267650600228229401496703205376", "System.Numerics");
        using (var bitmap = new Bitmap(16,16)) {
            using (var g = Graphics.FromImage(bitmap)) g.Clear(Color.Red);
            Check(bitmap.GetPixel(0,0).ToArgb() == Color.Red.ToArgb(), "System.Drawing/libgdiplus");
        }
        using (var f = new Form()) {
            f.Text = "Offline smoke test";
            using (var label = new Label()) {
                f.Controls.Add(label);
                Check(f.Handle != IntPtr.Zero && label.Parent == f, "System.Windows.Forms/Xvfb");
            }
        }
        Check(XElement.Parse("<a>42</a>").Value == "42", "System.Xml.Linq");
        using (var table = new DataTable()) {
            table.Columns.Add("Id", typeof(int)); table.Rows.Add(42);
            Check(System.Data.DataRowExtensions.Field<int>(table.Rows[0], "Id") == 42, "System.Data/DataSetExtensions");
        }
        using (var client = new HttpClient()) Check(client.Timeout > TimeSpan.Zero, "System.Net.Http (no network)");
        using (var ms = new MemoryStream()) {
            using (var zip = new ZipArchive(ms, ZipArchiveMode.Create, true)) zip.CreateEntry("hello");
            ms.Position = 0;
            using (var zip = new ZipArchive(ms, ZipArchiveMode.Read, true)) Check(zip.GetEntry("hello") != null, "System.IO.Compression");
        }
        Console.WriteLine("FRAMEWORK PROBE PASS");
    }
}
