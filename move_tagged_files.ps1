# Set global variables
$done = "/mnt/nas3-archive/Downloads/done"
$staging = "/mnt/nas4-tv/staging"
$nas4tv_adult = "/mnt/nas4-tv/TV/TV - Adult"
$nas4tv_kids = "/mnt/nas4-tv/TV/TV - Kids"
$adult_tv = @(
    "American Dad!"
    "American Gods"
    "Better Call Saul"
    "Black Mirror"
    "Blindspot"
    "Britannia"
    "Colony"
    "Dark Matter"
    "DC\'s Legends of Tomorrow"
    "Doctor Who \(2005\)"
    "Family Guy"
    "Game of Thrones"
    "Happy"
    "Impractical Jokers"
    "iZombie"
    "Legion"
    "Lost in Space \(2018\)"
    "Lucifer"
    "Marvel\'s Daredevil"
    "Marvel\'s Iron Fist"
    "Marvel\'s Jessica Jones"
    "Marvel\'s Luke Cage"
    "Marvel\'s The Defenders"
    "Marvel\'s The Punisher"
    "Midnight, Texas"
    "MINDHUNTER"
    "Mom"
    "Mr. Pickles"
    "New Girl"
    "Our Girl"
    "Over There"
    "Peaky Blinders"
    "Peter Kay\'s Car Share"
    "Plebs"
    "Preacher"
    "Rick and Morty"
    "Riverdale"
    "Scream"
    "SEAL Team"
    "Six"
    "South Park"
    "SS-GB"
    "Star Trek Discovery"
    "Supergirl"
    "Supernatural"
    "The 100"
    "The Detour"
    "The End of the Fxxxing World"
    "The Expanse"
    "The Flash \(2014\)"
    "The Goldbergs \(2013\)"
    "The Good Doctor"
    "The Handmaid's Tale"
    "The Long Road Home"
    "The Man in the High Castle"
    "The New Legends of Monkey"
    "The Orville"
    "The Rain"
    "The Tick \(2016\)"
    "The Walking Dead"
    "The X-Files"
    "Timeless \(2016\)"
    "Westworld"
    "Wolf Creek"
    "Wynonna Earp"
)
$kids_tv = @(
    "Danger Mouse \(2015\)"
    "Dragons"
    "Henry Danger"
    "Lab Rats \(2012\)"
    "My Little Pony"
    "Steven Universe"
    "Teenage Mutant Ninja Turtles \(2012\)"
    "The Amazing World of Gumball"
    "The Simpsons"
    "The Thundermans"
)
$adult_tv = $adult_tv | Sort-Object
$kids_tv = $kids_tv | Sort-Object

# Set permissions on files
&chmod 777 $done/*

# Rename & move Adult TV
ForEach ($program in $adult_tv){
    $files = Get-ChildItem -path $done
    ForEach ($tv in $files){
        If ($tv -cmatch $program){
            $short_name = $tv.Name -replace "$program - ", "" 
            Rename-Item -path $tv.FullName -NewName $short_name
            $program_name = $program -replace [regex]::Escape('\'),""
            $naspath = "$nas4tv_adult" + "/" + "$program_name"
            &rsync -P -e ssh "$done/$short_name" "root@nas4.ragefire.local:'$staging'"
            ssh root@nas4.ragefire.local "mv /mnt/nas4-tv/staging/*.m4v '$naspath'"
#            Remove-Item -path "$done/$short_name"
        }
    }
}

# Rename & move Kids TV
ForEach ($program in $kids_tv){
    $files = Get-ChildItem -path $done
    ForEach ($tv in $files){
        If ($tv -cmatch $program){
            $short_name = $tv.Name -replace "$program - ", "" 
            Rename-Item -path $tv.FullName -NewName $short_name
            $program_name = $program -replace [regex]::Escape('\'),""
            $naspath = "$nas4tv_kids" + "/" + "$program_name" 
            &rsync -P -e ssh "$done/$short_name" "root@nas4.ragefire.local:'$staging'"
            ssh root@nas4.ragefire.local "mv /mnt/nas4-tv/staging/*.m4v '$naspath'"
#            Remove-Item -path "$done/$short_name"
        }
    }
}
