Function Start-SimplePomodoro {

    <#
      .SYNOPSIS
      Start-SimplePomodoro is a function command to start a new Pomodoro session with additional actions. This is a simplified version of the Start-Pomodoro 
      .DESCRIPTION
      Forked from
        http://nathanhoneycutt.net/blog/a-pomodoro-timer-in-powershell/
#>

    [CmdletBinding()]
    Param (
        
        [int]$Minutes = 25, #Duration of your Pomodoro Session, default is 25 minutes
        [string]$Secret = "MySecret", #Secret for the flow trigger
        [string]$AutomateURI, #The URI used in the webrequest to your flow
        [string]$ToDoURL, #uri of your favourite spotify playlist
        [switch]$StartMusic,
        [string]$SpotifyPlayList, #uri of your favourite spotify playlist
        [string]$IFTTTMuteTrigger, #your_IFTTT_maker_mute_trigger
        [string]$IFTTTUnMuteTrigger, #your_IFTTT_maker_unmute_trigger
        [string]$IFTTTWebhookKey, #your_IFTTT_webhook_key
        [string]$StartNotificationSound = "C:\Windows\Media\Windows Proximity Connection.wav",
        [string]$EndNotificationSound = "C:\Windows\Media\Windows Proximity Notification.wav",
        [string]$Path = $env:LOCALAPPDATA + "\Microsoft\Teams\Update.exe",
        [string]$Arguments = '--processStart "Teams.exe"',
        [string]$Teamsmode = "HideBadge", #default is hide badge, set this variable to "stop" to just stop the teams client,
        [string]$Music, # spotify playlist switcher 
        [string]$Break # 


    )

    #Clear-Host ing some space to make room for the counter
    Clear-Host 
    Write-output ""
    Write-output ""
    Write-output "" 
    
    #get length of Pomodoro
    if ($Break -ne "b") {
        $minutes = Read-Host "How long is your Pomodoro?"
        Set-Clipboard -Value $minutes
    }
    else {
        $minutes = 5 
        Set-Clipboard -Value $minutes
    }
    if ($Music -eq 'y') {
        $Choice = Read-Host "nc neutral chill | le looping energetic | in introspecting neutral | lf lo-fi radio" 
        if ($Choice -eq 'nc') {
            Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
            Start-Process -FilePath "C:\Program Files\WindowsApps\SpotifyAB.SpotifyMusic_1.148.625.0_x86__zpdnekdrzrea0\Spotify.exe"
            Start-Process -FilePath "https://open.spotify.com/playlist/6AFarnHSC3tehgHPr9QLpk"
        }
        if ($Choice -eq 'le') {
            Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
            Start-Process -FilePath "C:\Program Files\WindowsApps\SpotifyAB.SpotifyMusic_1.148.625.0_x86__zpdnekdrzrea0\Spotify.exe"
            Start-Process -FilePath "https://open.spotify.com/playlist/6WK4lOFxtSnQaV1JMIydYg"
        }
        if ($Choice -eq 'in') {
            Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
            Start-Process -FilePath "C:\Program Files\WindowsApps\SpotifyAB.SpotifyMusic_1.148.625.0_x86__zpdnekdrzrea0\Spotify.exe"
            Start-Process -FilePath "https://open.spotify.com/playlist/5YbMOpWoW6nioVqgtdmuGp"
        }
        if ($Choice -eq 'lf') {
            Write-Host "Opening Lo-Fi Radio" -ForegroundColor Green;
            $url = "https://www.youtube.com/watch?v=jfKfPfyJRdk"
            Start-Process "chrome.exe" -ArgumentList "--incognito", $url
        }



    }
    #Start Spotify
    if ($SpotifyPlayList -ne '') {
        Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
        Start-Process -FilePath $SpotifyPlayList
    }
    
    #Turn off Vibration and mute Phone using IFTTT
    if ($IFTTTMuteTrigger -ne '' -and $IFTTTWebhookKey -ne '') {
        
        try {
                      
            $null = Invoke-RestMethod -Uri https://maker.IFTTT.com/trigger/$IFTTTMuteTrigger/with/key/$IFTTTWebhookKey -Method POST -ErrorAction Stop
            Write-Host -Object "IFTTT mute trigger invoked successfully" -ForegroundColor Green

        }
        catch {

            Write-Host -Object "An error occured while invoking IFTTT mute trigger: $($_.Exception.Message)" -ForegroundColor Yellow

        }   
        
    }
    #Invoking PowerAutomate to change set current time on your Focus time calendar event, either through https trigger og manually via todo
    #Go for deep work

    #Playing start sound
    if (Test-Path -Path $StartNotificationSound) {
     
        $player = New-Object System.Media.SoundPlayer $StartNotificationSound -ErrorAction SilentlyContinue
        1..2 | ForEach-Object { 
            $player.Play()
            Start-Sleep -m 3400 #invoking sleep so that the whole sound plays
        }
    }
    if ($Break -ne "b") {
        $Message = "Pomodoro Focus sessions"
    }
    else {
        $Message = "Break session"
    }
    
    #Counting down to end of Pomodoro
    $seconds = $Minutes * 60
    $delay = 1 #seconds between ticks
    for ($i = $seconds; $i -gt 0; $i = $i - $delay) {
        $percentComplete = 100 - (($i / $seconds) * 100)
        Write-Progress -SecondsRemaining $i `
            -Activity $Message `
            -Status "Time remaining:" `
            -PercentComplete $percentComplete
        if ($i -eq ($seconds / 2)) { Write-Host "Halfway mark" -ForegroundColor Blue }
        Start-Sleep -Seconds $delay
    }#Timer ended
    
    #Turn vibration on android phone back on using IFTTT
    if ($IFTTTUnMuteTrigger -ne '' -and $IFTTTWebhookKey -ne '') {

        try {
                      
            $null = Invoke-RestMethod -Uri https://maker.IFTTT.com/trigger/$IFTTTUnMuteTrigger/with/key/$IFTTTWebhookKey -Method POST -ErrorAction Stop
           
            Write-Host -Object "IFTTT unmute trigger invoked successfully" -ForegroundColor Green

        }
        catch {

            Write-Host -Object "An error occured while invoking IFTTT unmute trigger: $($_.Exception.Message)" -ForegroundColor Yellow

        }   
    }
   
    #playing end notification sound
    if (Test-Path -Path $EndNotificationSound) {

        #Playing end of focus session notification
        $player = New-Object System.Media.SoundPlayer $EndNotificationSound -ErrorAction SilentlyContinue
        1..2 | ForEach-Object {
            $player.Play()
            Start-Sleep -m 1400 
        }

    }
    Clear-Host  

}
        
$In = ""
$Count = 1
while ($In -eq "") {
    #Uncomment the one of the below lines and fill in your playlist and IFTTT to have it run as part of the shortcut
    #Start-SimplePomodoro -SpotifyPlayList spotify:playlist:XXXXXXXXXXXXXXXXXX -IFTTTMuteTrigger pomodoro_start -IFTTTUnMuteTrigger pomodoro_stop -IFTTTWebhookKey XXXXXXXXX -Secret YourFlowSecret -AutomateURI YourAutomateURI
    #Start-SimplePomodoro -Music y
    if ($Count % 2 -eq 1) {
        if ($Count -gt 1) {
            Write-Host "Starting Break"; Start-SimplePomodoro -Break "b" 
            $Count++
            continue 
        } 
    }
    Start-SimplePomodoro -Music y -IFTTTMuteTrigger Mute_Notifs -IFTTTUnMuteTrigger Unmute_notifs -IFTTTWebhookKe dGRR9guULGA_JzmOYMkM5n
    Clear-Host  
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Pomo Completed", 6, "Continue", 0x4 + 4096)
    $PomoNote = Read-Host -Prompt 'What tasks did you do?'
    Clear-Host 
    $PomoReflect = Read-Host -Prompt 'Reflect (insights, roadblocks, concerns & musings)'
    Clear-Host 
    $PomoScore = Read-Host -Prompt '?/10'
    Clear-Host 
    $directory = "C:\Users\turet\Documents\Docs\Code_Projects\Utils\Pomodoro\PomodoroNotes"
    $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $fileName = "$directory\$dateTime" + "_$count.md"
    Set-Content -Path $fileName -Value "$PomoNote`n$PomoReflect`n$PomoScore"
    Clear-Host  
    $Count++

}