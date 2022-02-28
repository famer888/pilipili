const fs = require('fs');
const path = require('path');

function enunicode(code) {
  code = code.replace(/[\u00FF-\uFFFF]/g, function ($0) {
    return '\\u' + $0.charCodeAt().toString(16);
  });
  return code;
};

function travel(dir, callback) {
  fs.readdir(dir, (err, files) => {
    if (err) {
      console.log(err)
    } else {
      files.forEach((file) => {
        var pathname = path.join(dir, file)
        fs.stat(pathname, (err, stats) => {
          if (err) {
            console.log(err)
          } else if (stats.isDirectory()) {
            travel(pathname, callback)
          } else {
            callback(pathname)
          }
        })
      })
    }
  })
}

travel('/Users/mac/Desktop/WorkSpace/flutter2021/youyu/lib', pathname => {
  fs.readFile(pathname, 'utf-8', function (err, data) {
    var _data = enunicode(data);
    fs.writeFile(pathname, _data, function (err) {
      if (err) {
        throw err
      }
    });
  })
});