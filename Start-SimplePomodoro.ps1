Function Start-SimplePomodoro {

<#
      .SYNOPSIS
      Start-SimplePomodoro is a function command to start a new Pomodoro session with additional actions. This is a simplified version of the Start-Pomodoro 
      .DESCRIPTION

        By MVP Ståle Hansen (http://msunified.net) with modifications by Jan Egil Ring (https://github.com/janegilring)
        Pomodoro function by Nathan.Run() http://nathanhoneycutt.net/blog/a-pomodoro-timer-in-powershell/
        Note: for desktops you need to enable presentation settings in order to suppress email alerts, by MVP Robert Sparnaaij: https://msunified.net/2013/11/25/lock-down-your-lync-status-and-pc-notifications-using-powershell/
        Start-Pomodoro also controls your Skype client presence, this is removed in Start-SimplePomodoro
        Get the old version here: https://github.com/janegilring/PSProductivityTools
        This function either closes Teams and starts it again or hides taskbar badges and unhides them after the session has ended for full focus on deep work
        Latest version blogged about here: https://msunified.net/2019/10/22/my-current-powershell-pomodoro-timer/
        Latest version to be found here: https://github.com/StaleHansen/Public/tree/master/Start-SimplePomodoro

        Required version: Windows PowerShell 3.0 or later 

        If you end the script prematurely, you can run the script with a 10 second lenght to reset your IFTTT and 

        It is recommended to add your Start-SimplePomodoro runline at the end of this script for easy startup

     .EXAMPLE
      Start-SimplePomodoro
     .EXAMPLE
      Start-SimplePomodoro -Minutes 15 -SpotifyPlayList spotify:playlist:XXXXXXXXXXXXXXXXXX
     .EXAMPLE
      Start-SimplePomodoro -Minutes 20 -IFTTTMuteTrigger pomodoro_start -IFTTTUnMuteTrigger pomodoro_stop -IFTTTWebhookKey XXXXXXXXX
     .EXAMPLE
      Start-SimplePomodoro -Minutes 0.1 -SpotifyPlayList spotify:playlist:XXXXXXXXXXXXXXXXXX -IFTTTMuteTrigger pomodoro_start -IFTTTUnMuteTrigger pomodoro_stop -IFTTTWebhookKey XXXXXXXXX
     .EXAMPLE
      Start-SimplePomodoro -Teamsmode Stop
     .EXAMPLE
      Start-SimplePomodoro -Secret YourFlowSecret -AutomateURI YourAutomateURI





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
        [string]$Path = $env:LOCALAPPDATA+"\Microsoft\Teams\Update.exe",
        [string]$Arguments = '--processStart "Teams.exe"',
        [string]$Teamsmode = "HideBadge", #default is hide badge, set this variable to "stop" to just stop the teams client,
        [string]$Music # spotify playlist switcher 

    )

    #Clearing some space to make room for the counter

    Write-output ""
    Write-output ""
    Write-output "" 
    
    #get lenght of Pomodoro
    $minutes = Read-Host "How long is your Pomodoro?"
    Set-Clipboard -Value $minutes
    if ($Music -eq 'y'){
		$Choice = Read-Host "nc neutral chill | le looping energetic" 
		if ($Choice -eq 'nc'){
			Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
			Start-Process -FilePath "https://open.spotify.com/playlist/6AFarnHSC3tehgHPr9QLpk"
		}
		if ($Choice -eq 'le'){
			Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
			Start-Process -FilePath "https://open.spotify.com/playlist/6WK4lOFxtSnQaV1JMIydYg"
		}
	}
    #Start Spotify
    if ($SpotifyPlayList -ne ''){
		Write-Host "Opening your specified Spotify playlist" -ForegroundColor Green;
		Start-Process -FilePath $SpotifyPlayList
	}
    
    #Turn off Vibration and mute Phone using IFTTT
    if ($IFTTTMuteTrigger -ne '' -and $IFTTTWebhookKey -ne ''){
        
             try {
                      
                    $null = Invoke-RestMethod -Uri https://maker.IFTTT.com/trigger/$IFTTTMuteTrigger/with/key/$IFTTTWebhookKey -Method POST -ErrorAction Stop
                    Write-Host -Object "IFTTT mute trigger invoked successfully" -ForegroundColor Green

            }
            catch  {

                    Write-Host -Object "An error occured while invoking IFTTT mute trigger: $($_.Exception.Message)" -ForegroundColor Yellow

            }   
        
        }
    #Invoking PowerAutomate to change set current time on your Focus time calendar event, either through https trigger og manually via todo
    if ($AutomateURI -ne ''){
        $body = @()
        $body = @"
            { 
               "Duration":$Minutes,
               "Secret":"$Secret"
            }
"@
        #Write-Host "Processing Focus time in your calendar and setting Teams to Focusing status" -ForegroundColor Green
        #Invoke-RestMethod -Method Post -Body $Body -Uri $AutomateURI -ContentType "application/json"
    }
   #elseif ($ToDoURL -ne ''){Write-Host "Opening your ToDo Pomodoro list in web, may take up to three minutes before calendar focus time update" -ForegroundColor Green; Start-Process -FilePath $ToDoURL}
   #else{Write-Host "No calendar focus time specified" -ForegroundColor Green}




    #Go for deep work

    Write-Host "Pomodoro session number $Count"
    Write-Host
    
    #Playing start sound
    if (Test-Path -Path $StartNotificationSound) {
     
        $player = New-Object System.Media.SoundPlayer $StartNotificationSound -ErrorAction SilentlyContinue
         1..2 | ForEach-Object { 
             $player.Play()
            Start-Sleep -m 3400 #invoking sleep so that the whole sound plays
        }
    }

    #Counting down to end of Pomodoro
    $seconds = $Minutes * 60
    $delay = 1 #seconds between ticks
    for ($i = $seconds; $i -gt 0; $i = $i - $delay) {
        $percentComplete = 100 - (($i / $seconds) * 100)
        Write-Progress -SecondsRemaining $i `
            -Activity "Pomodoro Focus sessions" `
            -Status "Time remaining:" `
            -PercentComplete $percentComplete
        if ($i -eq ($seconds / 2)){Write-Host "Halfway mark" -ForegroundColor Blue}
        Start-Sleep -Seconds $delay
    }#Timer ended
    
    #Turn vibration on android phone back on using IFTTT
    if ($IFTTTUnMuteTrigger -ne '' -and $IFTTTWebhookKey -ne ''){

            try {
                      
                        $null = Invoke-RestMethod -Uri https://maker.IFTTT.com/trigger/$IFTTTUnMuteTrigger/with/key/$IFTTTWebhookKey -Method POST -ErrorAction Stop
           
                        Write-Host -Object "IFTTT unmute trigger invoked successfully" -ForegroundColor Green

            }
            catch  {

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


}

$Input = ""
$Count = 1
while ($Input -eq ""){

#Uncomment the one of the below lines and fill in your playlist and IFTTT to have it run as part of the shortcut
#Start-SimplePomodoro -SpotifyPlayList spotify:playlist:XXXXXXXXXXXXXXXXXX -IFTTTMuteTrigger pomodoro_start -IFTTTUnMuteTrigger pomodoro_stop -IFTTTWebhookKey XXXXXXXXX -Secret YourFlowSecret -AutomateURI YourAutomateURI
#Start-SimplePomodoro -Music y
Start-SimplePomodoro -Music y -IFTTTMuteTrigger Mute_Notifs -IFTTTUnMuteTrigger Unmute_notifs -IFTTTWebhookKe dGRR9guULGA_JzmOYMkM5n

#Start-SimplePomodoro 

$Input = Read-Host -Prompt 'Exit Pomodoro (n)'
$PomoNote = Read-Host -Prompt 'What did you accomplish during this pomodoro?'
$PomoScore = Read-Host -Prompt '?/10'
$directory = ".\PomodoroNotes"
$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$fileName = "$directory\$dateTime" + "_$count.md"
Set-Content -Path $fileName -Value "$PomoNote`n$PomoScore"

$Count++
Write-Host $Count 
Write-Host ($Count % 4 -eq 0)  
if ($Count % 4 -eq 0) {Write-Host "Consider taking a longer break"}

}