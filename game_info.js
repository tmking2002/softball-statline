// Get the team ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const gameID = urlParams.get('gameID');
const season = urlParams.get('season');

const hittingFileName = `teams/data/box_scores/d1_hitting_box_${season}.csv`;
const pitchingFileName = `teams/data/box_scores/d1_pitching_box_${season}.csv`;

const gameInfo = []
const homeHittingTableContainer = document.getElementById("home-hitting-table-container");
const awayHittingTableContainer = document.getElementById("away-hitting-table-container");

const homePitchingTableContainer = document.getElementById("home-pitching-table-container");
const awayPitchingTableContainer = document.getElementById("away-pitching-table-container");

function findGameInfo(csvData, gameID) {
    const lines = csvData.split("\n");

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        const gameIdColumnIndex = 3;
        const homeIndicatorIndex = 6;
        const teamColumnIndex = 5;
        const opponentColumnIndex = 7;
        const gameDateColumnIndex = 4;
        const teamRuns = 9;
        const opponentRuns = 10;

        if (currentLine[gameIdColumnIndex].slice(1, -1) === gameID) {

            let awayTeam, homeTeam, awayRuns, homeRuns, gameDate;

            if(currentLine[homeIndicatorIndex] === '"@"') {
                awayTeam = currentLine[teamColumnIndex].slice(1, -1);
                homeTeam = currentLine[opponentColumnIndex].slice(1, -1);
                awayRuns = currentLine[teamRuns];
                homeRuns = currentLine[opponentRuns];
                gameDate = currentLine[gameDateColumnIndex].slice(1, -1);

            } else{
                awayTeam = currentLine[opponentColumnIndex].slice(1, -1);
                homeTeam = currentLine[teamColumnIndex].slice(1, -1);
                awayRuns = currentLine[opponentRuns];
                homeRuns = currentLine[teamRuns];
                gameDate = currentLine[gameDateColumnIndex].slice(1, -1);
            }

            return [awayTeam, homeTeam, awayRuns, homeRuns, gameDate];
        }
    }

    return []; 
}

fetch(`teams/data/game_logs/game_logs_${season}.csv`)
    .then(response => response.text())
    .then(csvData => {
        const gameInfo = findGameInfo(csvData, gameID);

        const pageTitle = document.querySelector('title');
        pageTitle.textContent = `Softball Statline  - ${gameInfo[0]} at ${gameInfo[1]} (${gameInfo[4]})`;

        const date_split = gameInfo[4].split("/");
        const date_fmtd = `${date_split[2]}-${date_split[0]}-${date_split[1]}`;
        
        const subheading = document.querySelector('h3');
        subheading.innerHTML = `${gameInfo[4]}`

        fetch(`schedule/schedule_data/d1/${date_fmtd}.csv`)
            .then(response => response.text())
            .then(csvData => {
                const lines = csvData.split("\n");
                const headers = ['', 'Away Name', 'Away ID', 'Away Logo', 'Away Runs', 'Home Name', 'Home ID', 'Home Logo', 'Home Runs', 'Game Date', 'Game ID', 'Status'];
                const rows = [];
                for (let i = 1; i < lines.length; i++) {
                    const currentLine = lines[i].split(",");
                    const row = {};
                    for (let j = 1; j < headers.length; j++) {
                        const header = headers[j];
                        let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

                        // Remove quotes around the value if present
                        if (value.startsWith('"') && value.endsWith('"')) {
                            value = value.slice(1, -1);
                        }

                        row[header] = value;
                    }
                    if (row["Game ID"] === gameID) {
                        const heading = document.querySelector('h1');
                        heading.style.whiteSpace = 'pre';
                        if (gameInfo[2] > gameInfo[3]) {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<b><a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a></b>\t<b>${gameInfo[2]}</b>\t\t${gameInfo[3]}\t<a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        } else {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a>\t${gameInfo[2]}\t\t<b>${gameInfo[3]}</b>\t<b><a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a></b>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        }
                    }
                }
            }
            )
            .catch(error => console.error("Error fetching or parsing CSV:", error));
            fetch(`schedule/schedule_data/d2/${date_fmtd}.csv`)
            .then(response => response.text())
            .then(csvData => {
                const lines = csvData.split("\n");
                const headers = ['', 'Away Name', 'Away ID', 'Away Logo', 'Away Runs', 'Home Name', 'Home ID', 'Home Logo', 'Home Runs', 'Game Date', 'Game ID', 'Status'];
                const rows = [];
                for (let i = 1; i < lines.length; i++) {
                    const currentLine = lines[i].split(",");
                    const row = {};
                    for (let j = 1; j < headers.length; j++) {
                        const header = headers[j];
                        let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

                        // Remove quotes around the value if present
                        if (value.startsWith('"') && value.endsWith('"')) {
                            value = value.slice(1, -1);
                        }

                        row[header] = value;
                    }
                    if (row["Game ID"] === gameID) {
                        const heading = document.querySelector('h1');
                        heading.style.whiteSpace = 'pre';
                        if (gameInfo[2] > gameInfo[3]) {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<b><a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a></b>\t<b>${gameInfo[2]}</b>\t\t${gameInfo[3]}\t<a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        } else {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a>\t${gameInfo[2]}\t\t<b>${gameInfo[3]}</b>\t<b><a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a></b>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        }
                    }
                }
            }
            )
            .catch(error => console.error("Error fetching or parsing CSV:", error));
            fetch(`schedule/schedule_data/d3/${date_fmtd}.csv`)
            .then(response => response.text())
            .then(csvData => {
                const lines = csvData.split("\n");
                const headers = ['', 'Away Name', 'Away ID', 'Away Logo', 'Away Runs', 'Home Name', 'Home ID', 'Home Logo', 'Home Runs', 'Game Date', 'Game ID', 'Status'];
                const rows = [];
                for (let i = 1; i < lines.length; i++) {
                    const currentLine = lines[i].split(",");
                    const row = {};
                    for (let j = 1; j < headers.length; j++) {
                        const header = headers[j];
                        let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

                        // Remove quotes around the value if present
                        if (value.startsWith('"') && value.endsWith('"')) {
                            value = value.slice(1, -1);
                        }

                        row[header] = value;
                    }
                    if (row["Game ID"] === gameID) {
                        const heading = document.querySelector('h1');
                        heading.style.whiteSpace = 'pre';
                        if (gameInfo[2] > gameInfo[3]) {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<b><a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a></b>\t<b>${gameInfo[2]}</b>\t\t${gameInfo[3]}\t<a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        } else {
                            heading.innerHTML = `<img src=${row['Away Logo']} width="50px"></img>\t<a href='team_info?teamID=${row["Away ID"]}'>${gameInfo[0]}</a>\t${gameInfo[2]}\t\t<b>${gameInfo[3]}</b>\t<b><a href='team_info?teamID=${row["Home ID"]}'>${gameInfo[1]}</a></b>\t<img src=${row['Home Logo']} width="50px"></img>`;
                        }
                    }
                }
            }
            )
            .catch(error => console.error("Error fetching or parsing CSV:", error));
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

function parseCSV(csvData, type) {
    const lines = csvData.split("\n");

    let headers;

    if (type === "hitting"){
        headers = ['', 'Game ID', 'Team', 'Opponent', 'Player ID', 'Player', 'Pos', 'AB', 'R', 'H', 'RBI', 'HR', 'K', 'BB'];
    } else {
        headers = ['', 'Game ID', 'Team', 'Opponent', 'Player ID', 'Player', 'IP', 'H', 'ER', 'BB', 'HB', 'SO', 'BF', 'HR', 'GO', 'FO']
    }

    const rows = [];

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        const row = {};
        for (let j = 1; j < headers.length; j++) {
            const header = headers[j];
            let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

            // Remove quotes around the value if present
            if (value.startsWith('"') && value.endsWith('"')) {
                value = value.slice(1, -1);
            }

            row[header] = value;
        }
        rows.push(row);
    }

    return rows;
}

function displayHitting(gameInfo) {
    fetch(`teams/data/game_logs/game_logs_${season}.csv`)
        .then(response => response.text())
        .then(csvData => {
            const teamInfo = findGameInfo(csvData, gameID);

            const homeTable = document.createElement("table");
            const awayTable = document.createElement("table");
            const headers = Object.keys(gameInfo[0]);

            const homeHeaderRow = document.createElement("tr");
            const awayHeaderRow = document.createElement("tr");

            // Set the team name as the label for the first column
            const homeFirstColumnHeader = document.createElement("th");
            homeFirstColumnHeader.textContent = teamInfo[1];
            homeHeaderRow.appendChild(homeFirstColumnHeader);

            const awayFirstColumnHeader = document.createElement("th");
            awayFirstColumnHeader.textContent = teamInfo[0];
            awayHeaderRow.appendChild(awayFirstColumnHeader);

            for (const header of headers) {
                if (header === "Game ID" || header === "Opponent" || header === "Team" || header === 'Player ID' || header === 'Pos' || header === 'Player') {
                    continue;
                }
                const thHome = document.createElement("th");
                thHome.textContent = header;
                homeHeaderRow.appendChild(thHome);

                const thAway = document.createElement("th");
                thAway.textContent = header;
                awayHeaderRow.appendChild(thAway);
            }

            homeTable.appendChild(homeHeaderRow);
            awayTable.appendChild(awayHeaderRow);

        for (const playerData of gameInfo) {
            const row = document.createElement("tr");
            
            if (playerData["Game ID"] != gameID | (parseInt(playerData["AB"]) + parseInt(playerData["BB"]) === 0)) {
                continue;
            }

            for (const header of headers) {
                if (header === "Game ID" || header === "Opponent" || header === "Team" || header === 'Player ID' || header === 'Pos') {
                    continue;
                }

                const cell = document.createElement("td");

                if (header === "Player") {
                    const cell = document.createElement("td");
                    const playerLink = document.createElement("a");
                    playerLink.textContent = playerData[header];
                    playerLink.href = `player_info?playerID=${playerData["Player ID"]}&season=${season}`;
                    
                    // Apply underline style to the player name
                    playerLink.style.textDecoration = "underline";
                    
                    // Create a span for the position text
                    const positionSpan = document.createElement("span");
                    positionSpan.textContent = ` ${playerData['Pos']}`;
                    
                    // Apply italic style to the position text
                    positionSpan.style.fontStyle = "italic";
                    positionSpan.style.fontSize = "10px";
                    
                    // Append both elements to the cell
                    cell.appendChild(playerLink);
                    cell.appendChild(positionSpan);
                    
                    // Append the cell to the row
                    row.appendChild(cell);
                } else{

                    cell.textContent = playerData[header];
                    row.appendChild(cell);

                }


            }
            
            if(playerData["Opponent"] === teamInfo[0]) {
                homeTable.appendChild(row);
            } else {
                awayTable.appendChild(row);
            }
        }

        homeHittingTableContainer.appendChild(homeTable);
        awayHittingTableContainer.appendChild(awayTable);
    })

}

function displayPitching(gameInfo) {
    fetch(`teams/data/game_logs/game_logs_${season}.csv`)
        .then(response => response.text())
        .then(csvData => {
            const teamInfo = findGameInfo(csvData, gameID);

            const homeTable = document.createElement("table");
            const awayTable = document.createElement("table");
            const headers = Object.keys(gameInfo[0]);

            const homeHeaderRow = document.createElement("tr");
            const awayHeaderRow = document.createElement("tr");

            // Set the team name as the label for the first column
            const homeFirstColumnHeader = document.createElement("th");
            homeFirstColumnHeader.textContent = teamInfo[1];
            homeHeaderRow.appendChild(homeFirstColumnHeader);

            const awayFirstColumnHeader = document.createElement("th");
            awayFirstColumnHeader.textContent = teamInfo[0];
            awayHeaderRow.appendChild(awayFirstColumnHeader);

            for (const header of headers) {
                if (header === "Game ID" || header === "Opponent" || header === "Team" || header === 'Player ID' || header === 'FO' || header == 'GO' || header === 'Player') {
                    continue;
                }
                const thHome = document.createElement("th");
                thHome.textContent = header;
                homeHeaderRow.appendChild(thHome);

                const thAway = document.createElement("th");
                thAway.textContent = header;
                awayHeaderRow.appendChild(thAway);
            }

            homeTable.appendChild(homeHeaderRow);
            awayTable.appendChild(awayHeaderRow);

        for (const playerData of gameInfo) {
            const row = document.createElement("tr");
            
            if (playerData["Game ID"] != gameID | parseInt(playerData["BF"]) === 0) {
                continue;
            }

            for (const header of headers) {

                if (header === "Game ID" || header === "Opponent" || header === "Team" || header === 'Player ID' || header === 'FO' || header == 'GO') {
                    continue;
                }

                const cell = document.createElement("td");

                if (header === "Player") {

                    const playerLink = document.createElement("a");
                    playerLink.textContent = playerData[header];
                    playerLink.href = `player_info?playerID=${playerData["Player ID"]}&season=${season}`;
                    cell.appendChild(playerLink);
                    row.appendChild(cell);

                } else{

                    cell.textContent = playerData[header];
                    row.appendChild(cell);

                }


            }
            
            if(playerData["Opponent"] === teamInfo[0]) {
                homeTable.appendChild(row);
            } else {
                awayTable.appendChild(row);
            }
        }

        homePitchingTableContainer.appendChild(homeTable);
        awayPitchingTableContainer.appendChild(awayTable);
    })
}


 fetch(hittingFileName)
    .then(response => response.text())
    .then(csvData => {
        const parsedHitting = parseCSV(csvData, 'hitting');
        displayHitting(parsedHitting);
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

fetch(pitchingFileName)
    .then(response => response.text())
    .then(csvData => {
        const parsedPitching = parseCSV(csvData, 'pitching');
        displayPitching(parsedPitching);
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

    





