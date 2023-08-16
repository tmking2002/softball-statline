function isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
}

function getSeasons() {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const playerID = urlParams.get('playerID');

    fetch("players/data/all_players.csv")
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            for (let i = 1; i < lines.length; i++) {

                let curID;
                
                curID = lines[i].split(",")[1]
                console.log(curID ===  playerID)

                if (curID === playerID) {
                    const seasons = lines[i].split(",")[4].slice(1, -2).split("+").reverse();

                    const seasonDropdown = document.getElementById("seasonDropdown");

                    for (const season of seasons) {
                        console.log(season)
                        const option = document.createElement("a");
                        option.textContent = season;
                        option.onclick = "setSeason({season})";
                        option.classList.add("w3-bar-item", "w3-button");
                        seasonDropdown.appendChild(option);
                    }
                }
            }
        });
}

getSeasons();