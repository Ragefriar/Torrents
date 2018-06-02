# Set global variables
$done = "/mnt/nas3-archive/Downloads/done"
$genres_nas1 = @(
    "Kids"
    "RomCom"
    "Sci-Fi & Fantasy"
    "Superhero"
    "War"
)
$genres_nas2 = @(
    "Action & Adventure"
    "Christmas"
    "Drama & Thriller"
    "Family & Comedy"
    "Horror & Scary"
)

# Process movies stored on NAS1
ForEach ($genre in $genres_nas1){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2
        If ($movie_genre -match $genre){
            $folder_name = $genre -replace " & ","_"
            &rsync -P -e ssh "$done/$($movie.name)" "admin@nas1.ragefire.local:/share/MD0_DATA/nas1-movies/.staging"
            ssh admin@nas1.ragefire.local "mv /share/MD0_DATA/nas1-movies/.staging/*.m4v /share/MD0_DATA/nas1-movies/'$folder_name'"
            Remove-Item -path "$done/$($movie.name)"
        }
    }
}

# Process movies stored on NAS2
ForEach ($genre in $genres_nas2){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2
        If ($movie_genre -match $genre){
            $folder_name = $genre -replace " & ","_"
            &rsync -P -e ssh "$done/$($movie.name)" "admin@nas2.ragefire.local:/share/MD0_DATA/nas2-Movies/.staging"
            ssh admin@nas2.ragefire.local "mv /share/MD0_DATA/nas2-Movies/.staging/*.m4v /share/MD0_DATA/nas2-Movies/'$folder_name'"
            Remove-Item -path "$done/$($movie.name)"
        }
    }
}