# Set global variables
$completed = "/mnt/torrents/completed"
$extracted = "/mnt/torrents/extracted"
$converted = "/mnt/torrents/converted"
$extracted_history = "/mnt/torrents/logs/extracted.txt"
$converted_history = "/mnt/torrents/logs/converted.txt"
$transferred_history = "/mnt/torrents/logs/transferred.txt"
$ffmpeg_errors = "/mnt/torrents/logs/ffmpeg_errors.txt"
$ffmpeg_logs = "/mnt/torrents/logs/ffmpeg_logs"
$transcriptpath = "/mnt/torrents/logs/transcripts/"
$transcriptfilename = "$(get-date -f dd-MM-yyyy).log"
$transcript = $transcriptpath + $transcriptfilename

# Clear screen and start transcript
Clear-Host
Start-Transcript -path $transcript -append
Write-Host ""

# Extract completed files
$rarfiles = Get-ChildItem -path $completed -recurse -include "*.rar"
ForEach ($rar in $rarfiles){
    $done = Get-Content $extracted_history
    $search = $done | ForEach-Object {$_ -match $rar.Name}
    # Make sure file is Movie or TV episode
    If ($rar.Name -match "1080p" -or $rar.Name -match "720p"){
        If (!($search -match $true)){
            Write-Host "Extracting $($rar.Name)" -foregroundcolor green
            &unrar e -o- $rar.FullName $extracted  > /dev/null 2>&1
            Add-Content -path $extracted_history -value $rar.Name
            Get-ChildItem -path $extracted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}  
        }
    }    
}

# Convert extracted files
Write-Host ""
$mkvfiles = Get-ChildItem -path $extracted -recurse -include "*.mkv"
ForEach ($mkv in $mkvfiles){
    $done = Get-Content $converted_history
    $search = $done | ForEach-Object {$_ -match $mkv.FullName}
    If (!($search -match $true)){
        $mp4name = $mkv.Name
        Write-Host "Processing $($mkv.Name)" -foregroundcolor yellow
        # Get codec info
        $audio_codecs = &mediainfo "--Inform=Audio;%Format%\n" "$($mkv)"
        $subtitle_codec = &mediainfo "--Inform=Text;%Format%\n" "$($mkv)"
        # If file contains DTS, convert it
        If ($audio_codecs -match "DTS"){
            Write-Host "AppleTV imcompatible streams. Contains DTS - keeping DTS stream, adding AC3 stream " -foregroundcolor green -nonewline
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "and has incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -map 0:1 -c:v copy -c:a:0 ac3 -b:a 640k -c:a:1 copy $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "and has good subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -map 0:1 -c:v copy -c:a:0 ac3 -b:a 640k -c:a:1 copy -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Remove-Item -path $mkv.FullName
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($mkv.Name).log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $mkv.Name
                Write-Host ""
            }    
        }
        # If file contains TrueHD or Dolby Digital Plus, convert it
        ElseIf ($audio_codecs -match "TrueHD" -or $audio_codecs -match "EAC3"){
            Write-Host "AppleTV imcompatible streams. Contains TrueHD or Dolby Digital Plus - coverting to AC3 " -foregroundcolor green -nonewline
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "and has incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a ac3 -b:a 640k $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "and has good subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a ac3 -b:a 640k -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Remove-Item -path $mkv.FullName
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($mkv.Name).log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $mkv.Name
                Write-Host ""
            }
        }
        # If Apple compatible file, just copy streams
        Else {
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "AppleTV compatible streams and incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a copy $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "AppleTV compatibe stream and has good subtitle" -foregroundcolor green
                &ffmpeg -i $mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a copy -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Remove-Item -path $mkv.FullName
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($mkv.Name).log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $mkv.Name
                Write-Host ""
            }
        }
    }
}

# Convert non-rar'd mkv's
$non_rar_mkv = Get-ChildItem -path $completed -recurse -include "*.mkv" -exclude "*sample*","*Sample*"
ForEach ($whole_mkv in $non_rar_mkv){
    $done = Get-Content $converted_history
    $search = $done | ForEach-Object {$_ -match $whole_mkv.Name}
    If (!($search -match $true)){
        $mp4name = $whole_mkv.Name
        Write-Host "Processing $($whole_mkv.Name)" -foregroundcolor yellow
        # Get codec info
        $audio_codecs = &mediainfo "--Inform=Audio;%Format%\n" "$($whole_mkv)"
        $subtitle_codec = &mediainfo "--Inform=Text;%Format%\n" "$($whole_mkv)"
        # If file contains DTS, convert it
        If ($audio_codecs -match "DTS"){
            Write-Host "AppleTV imcompatible streams. Contains DTS - keeping DTS stream, adding AC3 stream " -foregroundcolor green -nonewline
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "and has incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -map 0:1 -c:v copy -c:a:0 ac3 -b:a 640k -c:a:1 copy $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "and has good subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -map 0:1 -c:v copy -c:a:0 ac3 -b:a 640k -c:a:1 copy -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $whole_mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($whole_mkv.Name)log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $whole_mkv.Name
                Write-Host ""
            }
        }
        # If file contains TrueHD or Dolby Digital Plus, convert it
        ElseIf ($audio_codecs -match "TrueHD" -or $audio_codecs -match "EAC3"){
            Write-Host "AppleTV imcompatible streams. Contains TrueHD or Dolby Digital Plus - coverting to AC3 " -foregroundcolor green -nonewline
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "and has incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a ac3 -b:a 640k $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "and has good subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a ac3 -b:a 640k -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $whole_mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($whole_mkv.Name).log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $whole_mkv.Name
                Write-Host ""
            }
        }
        # If Apple compatible file, just copy streams
        Else {
            # Ignore crappy subtitles
            If ($subtitle_codec -match "PGS"){
                Write-Host "AppleTV compatible stream and has incompatible subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a copy $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # Include good subtitles
            Else {
                Write-Host "AppleTV compatible stream and has good subtitle" -foregroundcolor green
                &ffmpeg -i $whole_mkv.FullName -map 0:0 -map 0:1 -c:v copy -c:a copy -c:s mov_text $converted/$mp4name.mp4 2> $ffmpeg_logs/$($whole_mkv.Name).log
            }
            # If no errors, write to log & delete MKV
            If ($lastexitcode -eq 0){
                Write-Host "No errors detected during FFmpeg conversion" -foregroundcolor green
                Add-Content -path $converted_history -value $whole_mkv.Name
                Get-ChildItem -path $converted -recurse | Rename-Item -newname {$_.Name -replace ' ','.'}
                Write-Host ""
            }
            # If errors, log filename for investigaion
            Else {
                Write-Host "Errors detected during FFmpeg conversion - check $($ffmpeg_logs)/$($whole_mkv.Name).log" -foregroundcolor red
                Add-Content -path $ffmpeg_errors -value $whole_mkv.Name
                Write-Host ""
            }
        }
    }      
}

# Transfer files if MacPro is available
If (Test-Connection macpro.ragefire.local -BufferSize 16 -Count 1 -ea 0 -quiet -informationaction ignore){
    # Transfer converted files
    $mp4files = Get-ChildItem -path $converted -recurse -include "*.mp4"
    ForEach ($mp4 in $mp4files){
        $done = Get-Content $transferred_history
        $search = $done | ForEach-Object {$_ -match $mp4.Name}
        If (!($search -match $true)){
            Do {
                Write-Host "MacPro available. Transfering $($mp4.Name)" -foregroundcolor green
                &rsync -P -e ssh $mp4.FullName "chris@macpro.ragefire.local:/Volumes/Data/Downloads/untagged" > /dev/null 2>&1
                Start-Sleep -s 10    
            }
            Until ($lastexitcode -eq 0)
            Add-Content -path $transferred_history -value $mp4.Name
            Remove-Item -path $mp4.FullName
        }
    }
    # Transfer converted, non-rar'd mp4's
    $converted_mp4 = Get-ChildItem -path $converted -recurse -include "*.mp4"
    ForEach ($new_mp4 in $converted_mp4){
        $done = Get-Content $transferred_history
        $search = $done | ForEach-Object {$_ -match $new_mp4.Name}
        If (!($search -match $true)){
            Do {
                Write-Host "MacPro available. Transfering $($new_mp4.Name)" -foregroundcolor green
                &rsync -P -e ssh $new_mp4.FullName "chris@macpro.ragefire.local:/Volumes/Data/Downloads/untagged" > /dev/null 2>&1
                Start-Sleep -s 10   
            }
            Until ($lastexitcode -eq 0)
            Add-Content -path $transferred_history -value $new_mp4.Name
            Remove-Item -path $new_mp4.FullName
        }
    }
    # Transfer non-rar'd mp4's
    $non_rar_mp4 = Get-ChildItem -path $completed -recurse -include "*.mp4" -exclude "*sample*","*Sample*"
    ForEach ($whole_mp4 in $non_rar_mp4){
        $done = Get-Content $transferred_history
        $search = $done | ForEach-Object {$_ -match $whole_mp4.Name}
        If (!($search -match $true)){
            Do {
                Write-Host "MacPro available. Transfering $($whole_mp4.Name)" -foregroundcolor green
                &rsync -P -e ssh $whole_mp4.FullName "chris@macpro.ragefire.local:/Volumes/Data/Downloads/untagged" > /dev/null 2>&1
                Start-Sleep -s 10   
            }
            Until ($lastexitcode -eq 0)
            Add-Content -path $transferred_history -value $whole_mp4.Name
        }
    }
}
# MacPro not available, leave files for next pass
Else {
    Write-Host "MacPro not available.  Files will be transfered on next pass if MacPro is available." -foregroundcolor red
}

# Move files on MacPro info folders for tagging
Write-Host ""
Write-Host "Transfers complete.  Moving files about on MacPro for tagging" -foregroundcolor green
ssh chris@macpro.ragefire.local "mv /Volumes/Data/Downloads/untagged/*.mp4 /Volumes/Data/Downloads/untagged/mp4" > /dev/null 2>&1
ssh chris@macpro.ragefire.local "mv /Volumes/Data/Downloads/untagged/*.m4v /Volumes/Data/Downloads/untagged/m4v" > /dev/null 2>&1
Write-Host "Kicking off remote script to move fies and ass to iTunes"
ssh chris@macpro.ragefire.local "nohup /Volumes/Data/Downloads/scripts/start_processing.sh"
Write-Host "All Done!!" -foregroundcolor blue
Stop-Transcript