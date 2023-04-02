using Serilog;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .CreateLogger();

while (true)
{
    Log.Debug("Hello, world! {Now}", DateTime.Now);
    await Task.Delay(1000);
}


// On application exit, flush and close the log
// Log.CloseAndFlush();