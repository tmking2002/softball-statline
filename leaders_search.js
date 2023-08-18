const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const type = urlParams.get('type');
const timespan = urlParams.get('timespan');
const season = urlParams.get('season');

let folder;

if (timespan === "Season" && season !== "all_time") {
    folder = `leaders/${season}`;

    const pageTitle = document.querySelector('title');
    pageTitle.textContent = `Softball Statline  -  ${season} ${type} Leaders`;

    const heading = document.querySelector('h2');
    heading.textContent = `${season} ${type} Leaders`;

} else if (timespan === "Season" && season === "all_time") {
    folder = 'leaders/all_time';

    const pageTitle = document.querySelector('title');
    pageTitle.textContent = `Softball Statline  -  All Time Hitting Leaders (Single Season)`;

    const heading = document.querySelector('h2');
    heading.textContent = `All Time Hitting Leaders (Single Season)`;

} else if (timespan === "Career") {
    folder = 'leaders/career';

    const pageTitle = document.querySelector('title');
    pageTitle.textContent = `Softball Statline  -  All Time Hitting Leaders (Career)`;

    const heading = document.querySelector('h2');
    heading.textContent = `All Time Hitting Leaders (Career)`;
}

if (type === "Hitting" & timespan === "Season" & season !== "all_time") {

    tableContainer_1 = document.getElementById("table-container-1");
    tableContainer_2 = document.getElementById("table-container-2");
    tableContainer_3 = document.getElementById("table-container-3");
    tableContainer_4 = document.getElementById("table-container-4");
    tableContainer_5 = document.getElementById("table-container-5");
    tableContainer_6 = document.getElementById("table-container-6");
    tableContainer_7 = document.getElementById("table-container-7");
    tableContainer_8 = document.getElementById("table-container-8");

    fetch (`${folder}/avg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'AVG'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'AVG' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_1.appendChild(table);
        })

    fetch (`${folder}/slg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'SLG'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SLG' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_2.appendChild(table);
        })

    fetch (`${folder}/ops_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'OPS'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'OPS' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_3.appendChild(table);
        })
    
    fetch (`${folder}/rc_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'RC'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'RC' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_4.appendChild(table);
        })

    fetch (`${folder}/h_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'H'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'H' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_5.appendChild(table);
        })

    fetch (`${folder}/xbh_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'XBH'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'XBH' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_6.appendChild(table);
        })

    fetch (`${folder}/hr_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'HR'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'HR' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_7.appendChild(table);
        })

    fetch (`${folder}/sb_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'SB'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SB' & headers[j] != 'Rank' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 6)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_8.appendChild(table);
        })
} else if (type === "Hitting" & timespan === "Season" & season === "all_time") {

    tableContainer_1 = document.getElementById("table-container-1");
    tableContainer_2 = document.getElementById("table-container-2");
    tableContainer_3 = document.getElementById("table-container-3");
    tableContainer_4 = document.getElementById("table-container-4");
    tableContainer_5 = document.getElementById("table-container-5");
    tableContainer_6 = document.getElementById("table-container-6");
    tableContainer_7 = document.getElementById("table-container-7");
    tableContainer_8 = document.getElementById("table-container-8");

    fetch (`${folder}/avg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'AVG', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'AVG' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_1.appendChild(table);
        })

    fetch (`${folder}/slg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'SLG', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SLG' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_2.appendChild(table);
        })

    fetch (`${folder}/ops_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'OPS', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'OPS' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_3.appendChild(table);
        })
    
    fetch (`${folder}/rc_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'RC', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'RC' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_4.appendChild(table);
        })

    fetch (`${folder}/h_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'H', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'H' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_5.appendChild(table);
        })

    fetch (`${folder}/xbh_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'XBH', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'XBH' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_6.appendChild(table);
        })

    fetch (`${folder}/hr_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'HR', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'HR' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_7.appendChild(table);
        })

    fetch (`${folder}/sb_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Team ID', 'Player ID', 'Rank', 'Player', 'SB', 'Year'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SB' & headers[j] != 'Rank' & headers[j] != 'Year' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_8.appendChild(table);
        })

} else if (type === "Hitting" & timespan === "Career") {
    tableContainer_1 = document.getElementById("table-container-1");
    tableContainer_2 = document.getElementById("table-container-2");
    tableContainer_3 = document.getElementById("table-container-3");
    tableContainer_4 = document.getElementById("table-container-4");
    tableContainer_5 = document.getElementById("table-container-5");
    tableContainer_6 = document.getElementById("table-container-6");
    tableContainer_7 = document.getElementById("table-container-7");
    tableContainer_8 = document.getElementById("table-container-8");

    fetch (`${folder}/avg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'AVG', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'AVG' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(2, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 2; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_1.appendChild(table);
        })

    fetch (`${folder}/slg_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'SLG', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SLG' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_2.appendChild(table);
        })

    fetch (`${folder}/ops_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'OPS', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'OPS' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_3.appendChild(table);
        })
    
    fetch (`${folder}/rc_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'RC', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'RC' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_4.appendChild(table);
        })

    fetch (`${folder}/h_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'H', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'H' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_5.appendChild(table);
        })

    fetch (`${folder}/xbh_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'XBH', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'XBH' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_6.appendChild(table);
        })

    fetch (`${folder}/hr_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'HR', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'HR' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_7.appendChild(table);
        })

    fetch (`${folder}/sb_leaders.csv`)
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            const headers = ['', 'Player ID', 'Rank', 'Player', 'SB', 'Years'];
            const rows = [];
        
            for (let i = 1; i < lines.length; i++) {
                const currentLine = lines[i].split(",");
                const row = {};
                for (let j = 0; j < headers.length; j++) {
                    if(headers[j] != 'Player' & headers[j] != 'SB' & headers[j] != 'Rank' & headers[j] != 'Years' & headers[j] != 'Player ID') {
                        continue;
                    }
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
        
            // Create the table
            const table = document.createElement('table');
        
            // Create the table header row
            let thead = table.createTHead();
            let row = thead.insertRow();
            for (let key of headers.slice(3, 7)) {
                let th = document.createElement('th');
                let text = document.createTextNode(key);
                th.appendChild(text);
                row.appendChild(th);
            }
        
            // Add the data rows
            for (let i = 0; i < rows.length; i++) {
                row = table.insertRow();
                for (let j = 3; j < headers.length; j++) {
                    let cell = row.insertCell();
                    if (headers[j] === "Player") {
                        // Create a element
                        const a = document.createElement('a')
                        a.href = `player_info?playerID=${rows[i]['Player ID']}`
                        a.textContent = rows[i][headers[j]]
                        cell.appendChild(a)
                    } else{
                        cell.innerHTML = rows[i][headers[j]];
                    }
                }
            }
        
            tableContainer_8.appendChild(table);
        })
}