#! "netcoreapp2.0"
#r "nuget: NetStandard.Library, 2.0.0"

public static void WaitForDebugger()
{
    Console.WriteLine("Attach Debugger (VS Code)");
    while (!Debugger.IsAttached)
    {
    }
}

//WaitForDebugger();
using (var streamReader = new StreamReader(Console.OpenStandardInput()))
{
    Write(streamReader.ReadToEnd().ToUpper()); // <- SET BREAKPOINT HERE
}