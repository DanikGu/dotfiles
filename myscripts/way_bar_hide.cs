#!/home/danik/.dotnet/dotnet run
#:package CliWrap@3.9.0

using System;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.Threading.Tasks;
using CliWrap;

string homeDirectory = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
string myScriptsDirectory = Path.Combine(homeDirectory, "myscripts");
string toggleFile = Path.Combine(myScriptsDirectory, "zenison");
var isOpen = true;
var fromTopOpen = 3;
var fromTopClose = 50;
var counter = 0;
async Task ShowHide(bool show) {
    Console.WriteLine($"show: {show}, isOpen: {isOpen} {counter++}");
    if (isOpen == show) {
      return;
    }

    await Cli
        .Wrap("pkill")
        .WithArguments(["-SIGUSR1", "waybar", "-x"])
        .ExecuteAsync();
    isOpen = show;
}
while (true)
{
  try {
    if (!File.Exists(toggleFile)) {
      if (!isOpen) {
        await ShowHide(true);
      }
      await Task.Delay(300);
      continue;
    }
    var stdOutBuffer = new StringBuilder();
    var hyperctl = await Cli
        .Wrap("hyprctl")
        .WithArguments(["cursorpos"])
        .WithStandardOutputPipe(PipeTarget.ToStringBuilder(stdOutBuffer))
        .ExecuteAsync();
    var stdOut = stdOutBuffer.ToString();
    var outputArray = stdOut.Split(",");
    var x = int.Parse(outputArray[0].Trim());
    var y = int.Parse(outputArray[1].Trim());
    
    if (y < fromTopOpen  && !isOpen) 
    {
       await ShowHide(true);
    } 
    if (y > fromTopClose && isOpen) 
    {
       await ShowHide(false);
    }
    
    await Task.Delay(100);
  }
  catch (Exception ex) 
  {
    Console.WriteLine(ex.Message);
  }
}

