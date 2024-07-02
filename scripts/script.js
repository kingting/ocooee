function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function fetchAndDisplayScript(containerId, scriptUrl, button) {
  var container = document.getElementById(containerId);

  if (container.style.display === "none" || container.style.display === "") {
    fetch(scriptUrl)
      .then(response => {
        console.log('Fetching script from:', scriptUrl);
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text();
      })
      .then(data => {
        console.log('Script fetched successfully:', data);
        container.innerHTML = '<pre><code>' + escapeHtml(data) + '</code></pre>';
        container.style.display = "block";
        button.textContent = "Hide " + button.getAttribute('data-script-name');
      })
      .catch(error => {
        console.error('Error fetching the script:', error);
        container.innerHTML = '<pre><code>Error fetching the script.</code></pre>';
        container.style.display = "block";
        button.textContent = "Hide " + button.getAttribute('data-script-name');
      });
  } else {
    container.style.display = "none";
    button.textContent = "Show " + button.getAttribute('data-script-name');
  }
}

