async function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (!uri.includes('.')) {
        if (!uri.endsWith('/')) {
            request.uri += '/index.html';
        } else {
            request.uri += 'index.html';
        }
    } 
    else if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }

    return request;
}