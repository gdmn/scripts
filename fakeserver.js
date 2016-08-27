#! /usr/bin/env node

//Lets require/import the HTTP module
var http = require('http');
/*
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
*/
//Lets define a port we want to listen to
const PORT=8086; 

//We need a function which handles requests and send response
function handleRequest(request, response){
    response.writeHead(200, {'Content-Type': 'text/plain', 'Etag': '"100100100"', 'Cache-Control': 'max-age=86400', 'Server' : 'node.js fake http server'});
    response.end('');
}

//Create a server
var server = http.createServer(handleRequest);

//Lets start our server
server.listen(PORT, function(){
    //Callback triggered when server is successfully listening. Hurray!
    console.log("Server listening on: http://localhost:%s", PORT);
    console.log("Do not forget to run: ");
    console.log("sudo sysctl net.ipv4.ip_forward=1");
    console.log("sudo iptables -t nat -A OUTPUT -p tcp -d [IP] --dport  80 -j REDIRECT --to-port %s", PORT);
    console.log("sudo iptables -t nat -A OUTPUT -p tcp -d [IP] --dport 443 -j REDIRECT --to-port %s", PORT);
});