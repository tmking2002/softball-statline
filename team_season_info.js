function isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
}

function setSeason(selectedSeason) {
    const urlParams = new URLSearchParams(window.location.search);
    urlParams.set('season', selectedSeason);

    // Replace the current URL with the updated URL including the new 'season' parameter
    const newUrl = window.location.pathname + '?' + urlParams.toString();
    history.replaceState({}, '', newUrl);
}
        // Get the team ID and season from the URL query parameters
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const teamID = urlParams.get('teamID');
        const season = urlParams.get('season');

        function findTeam(csvData, teamID) {
            const lines = csvData.split("\n");

            let teamName = "a";

            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                let cur_ID = currentLine[2];
                if (cur_ID.startsWith('"') && cur_ID.endsWith('"')) {
                    cur_ID = cur_ID.slice(1, -1);
                }

                if(cur_ID == teamID) {
                    teamName = currentLine[1].slice(1, -1)
                    break;
                }
            }
            
            return teamName;
        }

        fetch("teams/data/all_teams.csv")
            .then(response => response.text())
            .then(csvData => {
                const teamName = findTeam(csvData, teamID);

                const pageTitle = document.querySelector('title');
                const pageTitleText = pageTitle.textContent;
                pageTitle.textContent = `Softball Statline  - ${teamName} (${season})`;

                const heading = document.querySelector('h1');
                const headingText = heading.textContent;
                heading.textContent = `${teamName} (${season})`
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));

        function parseCSV(csvData, type) {
            const lines = csvData.split("\n");
            if (type === "hitting") {
                headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'K', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];
              } else if (type === "gamelog") {
                headers = ['', 'Team ID', 'Opponent ID', 'Game ID', 'Game Date', 'Team', '', 'Opponent', 'Result', 'R', 'RA', 'Record']; // Replace with actual headers for game log
              } else if (type === "pitching") {
                headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];
              }

            const rows = [];

            for (let i = 1; i < lines.length; i++) {
                try {
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
                } catch (error) {
                    console.log('Error parsing line ${i}: ', error);
                }
            }

            return rows;
        }

        // Game Logs

        // Construct the CSV file name for the selected season
        const csvFileName_gamelog = `teams/data/game_logs/game_logs_${season}.csv`;
        const tableContainer_gamelog = document.getElementById("gamelog-container");

        // Function to display the stats for the selected season
        function displaySeasonStats_gamelog(csvData) {
            const table = document.createElement("table");
            let headers;
            if(isMobile()) {
                headers = ['Game Date', 'Home Indicator', 'Opponent', 'Result', 'Record']
            } else {
                headers = ['Game Date', 'Home Indicator', 'Opponent', 'Result', 'R', 'RA', 'Record']
            }

            const headerRow = document.createElement("tr");

            for (const header of headers) {
                const th = document.createElement("th");
                if(header === "Home Indicator") {
                    th.textContent = "";
                } else {
                    th.textContent = header;
                }
                headerRow.appendChild(th);
            }
            
            table.appendChild(headerRow);
            // Find the indices of the columns containing team ID and season

            for (const currentLine of csvData) {
                let curTeamID = currentLine["Team ID"];
                if (curTeamID === teamID) {

                    const row = document.createElement("tr");

                    for (const header of headers) {
                        if (header === "Opponent") {
                            const a = document.createElement("a");
                            a.textContent = currentLine[header];
                            a.href = "team_season_info?teamID=" + currentLine["Opponent ID"] + "&season=" + season;
            
                            const td = document.createElement("td");
                            td.appendChild(a); // Append the link to the table cell
                            row.appendChild(td);
                        } else if (header === "Home Indicator") {
                            const td = document.createElement("td");
                            td.textContent = currentLine[""];
                            row.appendChild(td);
                        } else if (header === "Game Date") {
                            const a = document.createElement("a");
                            a.textContent = currentLine[header];
                            a.href = "game_info?gameID=" + currentLine["Game ID"] + "&season=" + season;
                            const td = document.createElement("td");
                            td.appendChild(a);
                            row.appendChild(td);
                        } else {
                            const td = document.createElement("td");
                            td.textContent = currentLine[header];
                            if ((header === "Team" || header === "R" || header === "RA") && isMobile()) {
                                td.classList.add("mobile-hide"); // Add the mobile-hide class
                            }
                            row.appendChild(td);
                        }
                    }
                table.appendChild(row);
                }
            }

            tableContainer_gamelog.appendChild(table);
 
        }

        // Fetch the CSV data for the selected season
        fetch(csvFileName_gamelog)
            .then(response => response.text())
            .then(csvData => {
                const parsedData = parseCSV(csvData, "gamelog");
                displaySeasonStats_gamelog(parsedData);
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));
        
        // Hitting Stats

        // Construct the CSV file name for the selected season
        const csvFileName_hitting = `teams/data/hitting_stats/hitting_stats_${season}.csv`;
        const tableContainer_hitting = document.getElementById("hitting-stats-container");

        // Function to display the stats for the selected season
        function displaySeasonStats_hitting(csvData) {
            const table = document.createElement("table");
            const headers = ['Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'K', 'SB', 'CS', 'AVG', 'OBP', 'OPS']

            const headerRow = document.createElement("tr");

            for (const header of headers) {
                const th = document.createElement("th");
                th.textContent = header;
                headerRow.appendChild(th);
            }
            
            table.appendChild(headerRow);
            // Find the indices of the columns containing team ID and season

            for (const currentLine of csvData) {
                let curTeamID = currentLine["Team ID"];
                const curSeason = currentLine["Season"].trim();
                let curAB = currentLine["AB"];
                if (curTeamID === teamID && curSeason === season && curAB >= 20) {
                    const row = document.createElement("tr");
                for (const header of headers) {
                    const td = document.createElement("td");
                    if (header === "Player") {
                        const a = document.createElement("a");
                        a.textContent = currentLine[header];
                        a.href = "player_info?playerID=" + currentLine["Player ID"];

                        td.appendChild(a);
                        row.appendChild(td);
                    } else {
                        td.textContent = currentLine[header];
                    }
                    row.appendChild(td);
                }
                table.appendChild(row);
                }
            }

            tableContainer_hitting.appendChild(table);
 
        }

        // Fetch the CSV data for the selected season
        fetch(csvFileName_hitting)
            .then(response => response.text())
            .then(csvData => {
                const parsedData = parseCSV(csvData, "hitting");
                displaySeasonStats_hitting(parsedData);
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));


        // Hitting Stats

        // Construct the CSV file name for the selected season
        const csvFileName_pitching = `teams/data/pitching_stats/pitching_stats_${season}.csv`;
        const tableContainer_pitching = document.getElementById("pitching-stats-container");

        // Function to display the stats for the selected season
        function displaySeasonStats_pitching(csvData) {
            const table = document.createElement("table");
            const headers = ['Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP']

            const headerRow = document.createElement("tr");

            for (const header of headers) {
                const th = document.createElement("th");
                th.textContent = header;
                headerRow.appendChild(th);
            }
            
            table.appendChild(headerRow);
            // Find the indices of the columns containing team ID and season

            for (const currentLine of csvData) {
                let curTeamID = currentLine["Team ID"];
                const curSeason = currentLine["Season"].trim();
                let curIP = currentLine["IP"];
                if (curTeamID === teamID && curSeason === season && curIP >= 10) {
                    const row = document.createElement("tr");
                    for (const header of headers) {
                        const td = document.createElement("td");
                        if (header === "Player") {
                            const a = document.createElement("a");
                            a.textContent = currentLine[header];
                            a.href = "player_info?playerID=" + currentLine["Player ID"];
    
                            td.appendChild(a);
                            row.appendChild(td);
                        } else {
                            td.textContent = currentLine[header];
                        }
                        row.appendChild(td);
                    }
                table.appendChild(row);
                }
            }

            tableContainer_pitching.appendChild(table);
 
        }

        // Fetch the CSV data for the selected season
        fetch(csvFileName_pitching)
            .then(response => response.text())
            .then(csvData => {
                const parsedData = parseCSV(csvData, "pitching");
                displaySeasonStats_pitching(parsedData);
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));