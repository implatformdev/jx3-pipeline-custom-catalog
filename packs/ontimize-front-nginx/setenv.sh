if [[ ! -v $ENDPOINT ]]; then
    echo "ENDPOINT is not set"
elif [[ -z "$ENDPOINT" ]]; then
    echo "ENDPOINT is set to the empty string"
else
    echo "Generating env.js file"
    echo -e "(function (window) {\n  window.__env = window.__env || {};\n  // API url\n  window.__env.apiUrl = '$ENDPOINT';\n}(this));" > /usr/share/nginx/html/env.js
fi