using System;
static class CSharp73 {
    static unsafe int Size<T>() where T : unmanaged { return sizeof(T); }
    static void Main() {
        if (Size<int>() != 4) throw new Exception("unexpected sizeof");
        Console.WriteLine("C# 7.3 unmanaged constraint PASS");
    }
}
