#!/home/danik/.dotnet/dotnet run
#:package CliWrap@3.9.0
#:package Newtonsoft.Json@13.0.3

using System;
using System.Text;
using System.Text.Json;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using CliWrap;
using CliWrap.Buffered;
using CliWrap.EventStream;
using Newtonsoft.Json;

using (var cts = new CancellationTokenSource()) {
    Console.CancelKeyPress += (sender, args) => {
        Console.WriteLine("Received stop signal, exiting.");
        cts.Cancel();
        args.Cancel = true;
    };

    string? selectedPlayer = null;
    List<string> excludedPlayers = new List<string>();

    for (int i = 0; i < args.Length; i++)
    {
        if (args[i] == "--player" && i + 1 < args.Length)
        {
            selectedPlayer = args[i + 1];
            i++;
        }
        else if (args[i] == "--exclude" && i + 1 < args.Length)
        {
            excludedPlayers.AddRange(args[i + 1].Split(','));
            i++;
        }
    }

    var playerManager = new PlayerManager(selectedPlayer, excludedPlayers.ToArray(), cts);
    await playerManager.Run();
}
public class PlayerManager
{
    private const string CAVA_EXEC = "cava";
    private static readonly string CAVA_CONFIG_PATH = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".config/cava/waybar_config");
    private static readonly string[] BARS_CHARS = { "▂", "▃", "▄", "▅", "▆", "▇", "█" }; 
    private string _cavaBars = "";
    private readonly string? _selectedPlayer;
    private readonly List<string> _excludedPlayers;
    private readonly CancellationTokenSource _cts;
    private string lastPlayerName;

    public PlayerManager(string? selectedPlayer, string[] excludedPlayers, CancellationTokenSource cts)
    {
        _selectedPlayer = selectedPlayer;
        _excludedPlayers = excludedPlayers.ToList();
        _cts = cts;
    }

    public async Task Run()
    {
        _ = Task.Run(() => StartCavaProcess(_cts.Token));
        while (!_cts.IsCancellationRequested)
        {
            try
            {

                var playingPlayerName = await GetPlayingPlayerName(_cts.Token);
                string playerStatus = "stopped";
                string trackInfo = "";
                
                if (string.IsNullOrEmpty(playingPlayerName))
                {
                   await Task.Delay(100, _cts.Token);
                   continue;
                }
                playerStatus = await GetPlaybackStatus(playingPlayerName, _cts.Token);
                var metadata = await GetMetadata(playingPlayerName, _cts.Token);
                trackInfo = FormatTrackInfo(metadata, playerStatus, playingPlayerName);
                string finalOutput = $"{trackInfo} {_cavaBars}";
                WriteOutput(finalOutput, playingPlayerName, playerStatus);
                await Task.Delay(10, _cts.Token);
            }
            catch (OperationCanceledException ex)
            {

                //Console.WriteLine($"An error occurred: {ex.Message}");
                break;
            }
            catch (Exception ex)
            {
                //Console.WriteLine($"An error occurred: {ex.Message}");
                await Task.Delay(1000, _cts.Token);
            }
        }
    }

    private async Task<string?> GetPlayingPlayerName(CancellationToken token)
    {
        var result = await Cli.Wrap("playerctl")
            .WithArguments("-l")
            .ExecuteBufferedAsync(token);

        var playerNames = result.StandardOutput.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        foreach (var playerName in playerNames)
        {
            if (_excludedPlayers.Contains(playerName))
            {
                continue;
            }
            
            if (_selectedPlayer != null && _selectedPlayer != playerName)
            {
                continue;
            }
            
            var statusResult = await Cli.Wrap("playerctl")
                .WithArguments(new[] { "--player", playerName, "status" })
                .ExecuteBufferedAsync(token);

            if (statusResult.StandardOutput.Trim() == "Playing")
            {
                lastPlayerName = playerName;
                return playerName;
            }
        }
        if (!string.IsNullOrEmpty(lastPlayerName) && 
            playerNames.Any(x => x == lastPlayerName)) 
        {
          return lastPlayerName;
        }
        

        return playerNames.FirstOrDefault();
    }

    private async Task<string> GetPlaybackStatus(string playerName, CancellationToken token)
    {
        var result = await Cli.Wrap("playerctl")
            .WithArguments(new[] { "--player", playerName, "status" })
            .ExecuteBufferedAsync(token);
        
        return result.StandardOutput.Trim();
    }
    
    private async Task<Dictionary<string, string>> GetMetadata(string playerName, CancellationToken token)
    {
        // Use a format string to get artist, title, and trackid in one call
        var result = await Cli.Wrap("playerctl")
            .WithArguments(new[] { "--player", playerName, "metadata", "--format", "{{artist}}::{{title}}::{{mpris:trackid}}" })
            .ExecuteBufferedAsync(token);
        
        var parts = result.StandardOutput.Trim().Split("::");
        var metadata = new Dictionary<string, string>();
        
        if (parts.Length >= 2)
        {
            metadata["artist"] = parts[0];
            metadata["title"] = parts[1];
        }
        if (parts.Length >= 3)
        {
            metadata["mpris:trackid"] = parts[2];
        }

        return metadata;
    }

    private string FormatTrackInfo(Dictionary<string, string> metadata, string status, string playerName)
    {
        var artist = metadata.GetValueOrDefault("artist");
        var title = metadata.GetValueOrDefault("title");
        var trackId = metadata.GetValueOrDefault("mpris:trackid");

        // Handle Spotify ads based on trackid
        if (playerName == "spotify" && trackId != null && trackId.Contains(":ad:"))
        {
            return "Advertisement";
        }
        
        string trackInfo = string.Empty;
        if (!string.IsNullOrEmpty(artist) && !string.IsNullOrEmpty(title))
        {
            trackInfo = $"{artist} - {title}";
        }
        else if (!string.IsNullOrEmpty(title))
        {
            trackInfo = title;
        }

        // Clean up empty " - " string
        if (trackInfo == " - ")
        {
            trackInfo = string.Empty;
        }

        // Add play/pause icon and truncate long titles
        if (!string.IsNullOrEmpty(trackInfo))
        {
            string icon = status == "Playing" ? "  " : "  ";
            trackInfo = $"{icon} {trackInfo}";
        }

        if (trackInfo.Length > 30)
        {
            trackInfo = trackInfo[..27] + "...";
        }
        
        return trackInfo;
    }
    
    private void WriteOutput(string text, string? playerName, string status)
    {
        // Create an anonymous object for JSON serialization
        var output = new
        {
            text = text,
            @class = $"custom-{(playerName ?? "none")}{(status == "Playing" ? " playing" : " paused")}",
            alt = playerName
        };

        Console.WriteLine(JsonConvert.SerializeObject(output));
    }
    
    private async Task StartCavaProcess(CancellationToken token)
    {
        var command = Cli.Wrap(CAVA_EXEC)
            .WithArguments(new[] { "-p", CAVA_CONFIG_PATH })
            .WithStandardOutputPipe(PipeTarget.ToDelegate(line =>
            {
                try
                {
                    var levels = line.Split(';', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(int.Parse)
                                     .ToList();

                    var bars = string.Join("", levels
                        .Select(level => 
                          BARS_CHARS[level % BARS_CHARS.Length]));
                    _cavaBars = bars;
                }
                catch (FormatException)
                {
                    Debug.WriteLine($"Invalid numeric format from cava: {line}");
                    _cavaBars = "CAVA_FORMAT_ERR";
                }
            }));

        try
        {
            await command.ExecuteAsync(token);
        }
        catch (OperationCanceledException ex)
        {
            Console.WriteLine($"Error starting Cava: {ex.Message}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error starting Cava: {ex.Message}");
            _cavaBars = "CAVA_ERR";
        }
    }
}



