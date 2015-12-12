var ModAPI = require('modapi')
var _ = require('lodash')

var qml = ModAPI.QMLFile("Main/Dialog_PluginSettings.qml")
qml.addImportPath("../Singletons/plugin-parser")
qml.getObjectById("folderListModel").node.object("folder", "PluginParser.getPluginRoot()")

var node = qml.getObjectById("main").node
node.function("processCommentBlock", null)
node.function("loadScript", [
  'function loadScript() {',
  '    var name = pluginSelector.currentText;',
  '    var data = PluginParser.parsePlugin(name);',
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
