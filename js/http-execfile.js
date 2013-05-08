// ##############################################################
// création d''un service http serveur port 8080
// fichier shell/dos execécutable au travers du service http
// 
// request        : http://127.0.0.1:8080/?file=myfile
// response JSON  : {pid, stdout, stderr, file}
// log JSON       : {pid, env, stderr/status, file}
//
// @Author: ardoise.gisement@gmail.com
// @Date: 20130508
// #############################################################
// INSTALLATION :
//   apt-get install npm
//   npm update
// MANAGE :
//   node http-execfile.js

var http = require('http');
var url = require('url');

var execFile = require('child_process').execFile,
  child;

var server = http.createServer(function(req, res) {
  var parsedUrl = url.parse(req.url, true);
  var file = parsedUrl.query['file'];
  
  // res.writeHead(200);
  res.writeHead(200, {'Content-Type': 'text/plain'});
                
  if( file ) {
    child = execFile(
      file,
      // ['-v', '*.js'],
      null,
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
        
        if (error !== null) {
          console.log('{"pid":' + child.pid + ',"env":' + JSON.stringify([param1,param2]) + ',"stdout":' + 200 + '","file":' + JSON.stringify(file) + '}');
        } else {
          console.log('{"pid":' + child.pid + ',"env":' + JSON.stringify([param1,param2]) + ',"stderr":' + JSON.stringify(error) + ',"file":' + JSON.stringify(file) + '}');
          console.log('{"pid":' + child.pid + ',"env":' + JSON.stringify([param1,param2]) + ',"stderr":' + JSON.stringify(error) + ',"file":' + JSON.stringify(file) + '}');
        }

        // return RESPONSE form JSON
        var result = '{"pid":' + child.pid + ',"stdout":' + JSON.stringify(stdout) + ',"stderr":' + JSON.stringify(stderr) + ',"file":' + JSON.stringify(file) + '}';
        res.end(result + '\n');
    });

  } else {
    // return RESPONSE form JSON
    var result = '{"pid":' + child.pid + ',"stdout":"' + '' + '","stderr":' + 'exist file is mandatory' + ',"file":"' + file + '"}';
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
// child_process.execFile(file, args, options, callback)#
// #####################################################
    // file String The filename of the program to run
    // args Array List of string arguments
    // options Object
      // cwd String Current working directory of the child process
      // stdio Array|String Child''s stdio configuration. (See above)
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
