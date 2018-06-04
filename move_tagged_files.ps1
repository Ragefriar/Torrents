# Set global variables
$done = "/Volumes/Data/Downloads/done"
$tv_adult = "/Volumes/Data/TV/TV - Adult"
$tv_kids = "/Volumes/Data/TV/TV - Kids"
$adult_tv = @(
    "American Dad!"
    "American Gods"
    "Better Call Saul"
    "Black Mirror"
    "Blindspot"
    "Britannia"
    "Brooklyn Nine-Nine"
    "Colony"
    "Dark Matter"
    "DC's Legends of Tomorrow"
    "Doctor Who (2005)"
    "Family Guy"
    "Game of Thrones"
    "Happy"
    "Impractical Jokers"
    "iZombie"
    "Legion"
    "Lost in Space (2018)"
    "Lucifer"
    "Marvel's Daredevil"
    "Marvel's Iron Fist"
    "Marvel's Jessica Jones"
    "Marvel's Luke Cage"
    "Marvel's The Defenders"
    "Marvel's The Punisher"
    "Midnight, Texas"
    "MINDHUNTER"
    "Mom"
    "Mr. Pickles"
    "Our Girl"
    "Over There"
    "Peaky Blinders"
    "Peter Kay's Car Share"
    "Plebs"
    "Preacher"
    "Rick and Morty"
    "Riverdale"
    "Scream"
    "SEAL Team"
    "SIX"
    "South Park"
    "SS-GB"
    "Star Trek Discovery"
    "Supergirl"
    "Supernatural"
    "The 100"
    "The Detour"
    "The End of the Fxxxing World"
    "The Expanse"
    "The Flash (2014)"
    "The Goldbergs (2013)"
    "The Good Doctor"
    "The Handmaid's Tale"
    "The Long Road Home"
    "The Man in the High Castle"
    "The New Legends of Monkey"
    "The Orville"
    "The Rain"
    "The Tick (2016)"
    "The Walking Dead"
    "The X-Files"
    "Timeless (2016)"
    "Westworld"
    "Wolf Creek"
    "Wynonna Earp"
)
$kids_tv = @(
    "Dragons"
    "Henry Danger"
    "My Little Pony"
    "Steven Universe"
    "Teenage Mutant Ninja Turtles (2012 )"
    "The Amazing World of Gumball"
    "The Simpsons"
    "The Thundermans"
    "Trollhunters"
)
$adult_tv = $adult_tv | Sort-Object
$kids_tv = $kids_tv | Sort-Object

# Rename & move Adult TV
ForEach ($program in $adult_tv){
    $files = Get-ChildItem -path $done
    ForEach ($tv in $files){
        If ($tv -cmatch $program){
            $short_name = $tv.Name -replace "$program - ", "" 
            Rename-Item -path $tv.FullName -NewName $short_name
            $macpath = "$tv_adult" + "/" + "$program"
            Move-Item -path "$done/$short_name" -destination "$macpath"
            # Remove-Item -path "$done/$short_name"
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
            $macpath = "$tv_kids" + "/" + "$program"
            Move-Item -path "$done/$short_name" -destination "$macpath"
            # Remove-Item -path "$done/$short_name"
        }
    }
}
