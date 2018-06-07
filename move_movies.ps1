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
$movies1_holding = "/Volumes/Movies1/holding/"
$movies2_holding = "/Volumes/Movies2/holding/"
$movies3_holding = "/Volumes/Movies3/holding/"

# Process movies stored on Movies1
ForEach ($genre in $genres_movies1){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            $folder_name = $genre -replace " & ","_"
            Move-Item -path "$done/$($movie.name)" -destination "$movies1_holding"
            Move-Item -path "$movies1_holding/$($movie.name)" -destination "/Volumes/Movies1/'$folder_name'"
        }
    }
}

# Process movies stored on Movies2
ForEach ($genre in $genres_movies2){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            $folder_name = $genre -replace " & ","_"
            Move-Item -path "$done/$($movie.name)" -destination "$movies2_holding"           
            Move-Item -path "$movies2_holding/$($movie.name)" -destination "/Volumes/Movies2/'$folder_name'"
        }
    }
}

# Process movies stored on Movies3
ForEach ($genre in $genres_nas3){
    $files = Get-ChildItem -path $done
    ForEach ($movie in $files){
        $movie_genre = &exiftool "$($movie.fullname)" | grep Genre | cut -d':' -f2 | head -n 1
        If ($movie_genre -match $genre){
            $folder_name = $genre -replace " & ","_"
            Move-Item -path "$done/$($movie.name)" -destination "$movies2_holding"
            Move-Item -path "$movies3_holding/$($movie.name)" -destination "/Volumes/Movies3/'$folder_name'"
        }
    }
}