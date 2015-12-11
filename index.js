var ModAPI = require('modapi')
var Essentials = require('mod')('essentials')
var _ = require('lodash')
var fs = require('fs')
var path = require('path')

var readLocalFile = function(name) {
  return fs.readFileSync(path.join(__dirname, name))
}

;[
  "Singletons/plugin-parser/qmldir",
  "Singletons/plugin-parser/PluginParser.qml",
  "Main/Dialog_PluginSettings.qml.js",
].forEach(function(i) {
  if (path.extname(i) == ".js" && path.extname(path.basename(i, ".js")) == ".qml") {
    require("./" + i)
  } else {
    ModAPI.add(i, readLocalFile(i))
  }
})
