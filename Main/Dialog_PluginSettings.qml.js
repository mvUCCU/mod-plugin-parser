var ModAPI = require('modapi')
var _ = require('lodash')

var qml = ModAPI.QMLFile("Main/Dialog_PluginSettings.qml")
var node = qml.getObjectById("main").node

node.function("processCommentBlock", null)
node.function("loadScript", [
  'function loadScript() {',
  '    var name = pluginSelector.currentText;',
  '    var url = folderListModel.folder + "/" + name + ".js";',
  '    var script = TkoolAPI.readFile(url);',
  '    var data = PluginParser.parse(script);',
  '',
  '    pluginHelp = data.help || "";',
  '    pluginDesc = data.description || "";',
  '    pluginAuthor = data.author || "";',
  '    paramNames = [];',
  '    paramDescs = {};',
  '    paramDefaults = {};',
  '    if (!data.parameters) data.parameters = [];',
  '    for (var i = 0; i < data.parameters.length; i++) {',
  '        var param = data.parameters[i];',
  '        paramNames.push(param.name);',
  '        paramDescs[param.name] = param.description;',
  '        paramDefaults[param.name] = param.defaultValue;',
  '    }',
  '',
  '    buildParameterListModel();',
  '}',
].join("\n"))

qml.save()