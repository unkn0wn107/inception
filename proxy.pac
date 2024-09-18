function FindProxyForURL(url, host) {
    if (url.startsWith("http://agaley.42.fr")) {
      return "PROXY localhost:8080";
    } else if (url.startsWith("https://agaley.42.fr")) {
      return "PROXY localhost:9443";
    } else if (shExpMatch(host, "localhost")) {
      return "PROXY localhost:9443";
    }

  return 'DIRECT';
}

