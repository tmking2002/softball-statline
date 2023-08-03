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

        function parseCSV(csvData) {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'K', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];
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

        // Construct the CSV file name for the selected season
        const csvFileName = `teams/data/rosters/d1_hitting_stats_${season}.csv`;
        const tableContainer = document.getElementById("stats-container");

        // Function to display the stats for the selected season
        function displaySeasonStats(csvData) {
            const table = document.createElement("table");
            const headers = Object.keys(csvData[0]).slice(2);

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
                if (curTeamID === teamID && curSeason === season) {
                    const row = document.createElement("tr");
                for (const header of headers) {
                    const td = document.createElement("td");
                    td.textContent = currentLine[header];
                    row.appendChild(td);
                }
                table.appendChild(row);
                }
            }

            tableContainer.appendChild(table);
 
        }

        // Fetch the CSV data for the selected season
        fetch(csvFileName)
            .then(response => response.text())
            .then(csvData => {
                const parsedData = parseCSV(csvData);
                displaySeasonStats(parsedData);
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));