// ##############################################################
// création d'un service http serveur port 8080
// commandes shell/dos execécutables au travers du service http
// 
// request        : http://127.0.0.1:8080/?cmd=mycommand
// response JSON  : {pid, stdout, stderr, cmd}
// log JSON       : {pid, env, stderr/status, cmd}
//
// @Author: ardoise.gisement@gmail.com
// @Date: 20130508
// #############################################################
// INSTALLATION :
//   apt-get install npm
//   npm update
// MANAGE :
//   node http-shell.js

// var sys = require('sys'); // DEPRECATED ?
var http = require('http');
var url = require('url');

// 3 FORMES
// var child_process = require('child_process');
// var exec = child_process.exec;
//
// var exec = child_process.exec;
// var child;
//
var exec = require('child_process').exec,
    child;

var server = http.createServer(function(req, res) {
  var parsedUrl = url.parse(req.url, true);
  var cmd = parsedUrl.query['cmd'];
  
  // res.writeHead(200);
  res.writeHead(200, {'Content-Type': 'text/plain'});
  
  if( cmd ) {
    // var child = child_process.exec( cmd, function (error, stdout, stderr) {
    // var child = child_process.exec( cmd, {}, function (error, stdout, stderr) {
    child = exec( 
      cmd, 
      { encoding: 'utf8',
        timeout: 0,
        maxBuffer: 200*1024,
        killSignal: 'SIGTERM',
        cwd: null,
        env: null,
        env: param1='toto',
        env: param2='titi',
        env: './tpzsys.env' },
      function (error, stdout, stderr) {
        // sys.print('stdin: ' + 'dir'); # DEPRECATED
        // sys.print('stdout: ' + stdout); # DEPRECATED
        // sys.print('stderr: ' + stderr); # DEPRECATED
        // sys.print('child.pid: ' + child.pid); # DEPRECATED
        
        // console.log('stdin: ' + 'dir'); // FIXME
        // console.log('stdout: ' + stdout);
        // console.log('stderr: ' + stderr);
        // console.log('param3: ' + param3);
        // console.log('param4: ' + param4);
        
        if (error !== null) {
          console.log('{"pid":' + child.pid + ',"env":' + JSON.stringify([param1,param2]) + ',"stdout":' + 200 + '","cmd":' + JSON.stringify(cmd) + '}');
        } else {          
          console.log('{"pid":' + child.pid + ',"env":' + JSON.stringify([param1,param2]) + ',"stderr":' + JSON.stringify(error) + ',"cmd":' + JSON.stringify(cmd) + '}');
        }
        
        // return RESPONSE form JSON
        //var result = '{"pid":' + child.pid + ',"stdout":' + stdout + ',"stderr":"' + stderr + '","cmd":"' + cmd + '"}';
        var result = '{"pid":' + child.pid + ',"stdout":"' + stdout + '","stderr":"' + stderr + '","cmd":' + JSON.stringify(cmd) + '}';
        res.end(result + '\n');
      });
  } else {
    // return RESPONSE form JSON
    var result = '{"pid":' + child.pid + ',"stdout":"' + '' + '","stderr":"' + 'cmd is mandatory' + '","cmd":"' + cmd + '"}';
    res.end(result + '\n');
  }
});

// server.listen(127.0.0.1, 8080); // Démarre le serveur
server.listen(8080); // Démarre le serveur

// API : CONTROL
// http://nodejs.org/api/events.html#events_class_events_eventemitter
// http://nodejs.org/api/child_process.html
//
// #####################################################
// child_process.exec(command, [options], callback)
// #####################################################
// command String The command to run, with space-separated arguments
// options Object
    // cwd String Current working directory of the child process
    // stdio Array|String Child's stdio configuration. (See above) Only stdin is configurable, anything else will lead to unpredictable results.
    // customFds Array Deprecated File descriptors for the child to use for stdio. (See above)
    // env Object Environment key-value pairs
    // encoding String (Default: 'utf8')
    // timeout Number (Default: 0)
    // maxBuffer Number (Default: 200*1024)
    // killSignal String (Default: 'SIGTERM')
// callback Function called with the output when process terminates
    // error Error
    // stdout Buffer
    // stderr Buffer
// Return: ChildProcess object
