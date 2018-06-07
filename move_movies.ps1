# Set global variables
$done = "/Volumes/Data/Downloads/done"
$genres_movies1 = @(
    "Kids"
    "RomCom"
    "Sci-Fi & Fantasy"
    "War"
)
$genres_movies2 = @(
    "Christmas"
    "Drama & Thriller"
    "Family & Comedy"
)
$genres_movies2 = @(
    "Action & Adventure"
    "Horror & Scary"
    "Superhero"
)
$movies1_holding = "/Volumes/Movies1/.holding/"
$movies2_holding = "/Volumes/Movies2/.holding/"
$movies3_holding = "/Volumes/Movies3/.holding/"

# Process movies stored on Movies1
Clear-Host
ForEach ($genre in $genres_movies1){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        # Get movie genre and compare to hastable to see if it belongs on Movie1
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            Write-Host "Processing $($movie.name)" -foregroundcolor yellow
            Write-Host "$($movie.name) is a $movie_genre movie" -foregroundcolor green
            $folder_name = $genre -replace " & ","_"
            # Move movie to holding folder, then move to correct genre folder
            Write-Host "Moving $($movie.name) to holding folder $movies1_holding" -foregroundcolor green
            Move-Item -path "$done/$($movie.name)" -destination "$movies1_holding"
            Write-Host "Moving $($movie.name) from holding folder /Volumes/Movies1/'$folder_name'" -foregroundcolor green
            Move-Item -path "$movies1_holding/$($movie.name)" -destination "/Volumes/Movies1/'$folder_name'"
            Write-Host ""
        }
    }
}

# Process movies stored on Movies2
ForEach ($genre in $genres_movies2){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        # Get movie genre and compare to hastable to see if it belongs on Movie2
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            Write-Host "Processing $($movie.name)" -foregroundcolor yellow
            Write-Host "$($movie.name) is a $movie_genre movie" -foregroundcolor green
            $folder_name = $genre -replace " & ","_"
            # Move movie to holding folder, then move to correct genre folder
            Write-Host "Moving $($movie.name) to holding folder $movies2_holding" -foregroundcolor green
            Move-Item -path "$done/$($movie.name)" -destination "$movies2_holding"
            Write-Host "Moving $($movie.name) from holding folder /Volumes/Movies2/'$folder_name'" -foregroundcolor green           
            Move-Item -path "$movies2_holding/$($movie.name)" -destination "/Volumes/Movies2/'$folder_name'"
            Write-Host ""
        }
    }
}

# Process movies stored on Movies3
ForEach ($genre in $genres_nas3){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        # Get movie genre and compare to hastable to see if it belongs on Movie3
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            Write-Host "Processing $($movie.name)" -foregroundcolor yellow
            Write-Host "$($movie.name) is a $movie_genre movie" -foregroundcolor green
            $folder_name = $genre -replace " & ","_"
            # Move movie to holding folder, then move to correct genre folder
            Write-Host "Moving $($movie.name) to holding folder $movies3_holding" -foregroundcolor green
            Move-Item -path "$done/$($movie.name)" -destination "$movies3_holding"
            Write-Host "Moving $($movie.name) from holding folder /Volumes/Movies3/'$folder_name'" -foregroundcolor green
            Move-Item -path "$movies3_holding/$($movie.name)" -destination "/Volumes/Movies3/'$folder_name'"
            Write-Host ""
        }
    }
}