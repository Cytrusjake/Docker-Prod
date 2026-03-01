vcl 4.1;

backend default {
    .host = "nginx";
    .port = "80";
}

sub vcl_recv {
    # Preserve original client IP
    if (req.restarts == 0) {
        if (req.http.X-Forwarded-For) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    # Only cache GET and HEAD
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Do not cache logged-in sessions (PHP)
    if (req.http.Cookie) {
        return (pass);
    }

    return (hash);
}

sub vcl_backend_response {
    # Do not cache private responses
    if (beresp.http.Set-Cookie) {
        set beresp.ttl = 0s;
        return (deliver);
    }

    # Default cache time
    if (beresp.ttl <= 0s) {
        set beresp.ttl = 5m;
    }

    return (deliver);
}

sub vcl_deliver {
    # Debug header (optional)
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}