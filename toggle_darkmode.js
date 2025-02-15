function toggleDarkMode() {
    var element = document.body;
    var logo = document.getElementById('logo');
    var button = document.getElementById('dark-mode-button');

    element.classList.toggle("dark-mode");

    if (element.classList.contains('dark-mode')) {
        logo.src = 'logo_darkmode.png';
        button.innerHTML = '<i class="fas fa-sun"></i> Light Mode';
    } else {
        logo.src = 'logo.png';
        button.innerHTML = '<i class="fas fa-moon"></i> Dark Mode';
    }
}