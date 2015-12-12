pragma Singleton
import QtQuick 2.3
import Tkool.rpg 1.0
import UCCU 1.0 as UCCU
import ".."

Item {
    property var _pluginsCache: ({})
    property var _handlers: null

    function getPluginRoot() {
        return DataManager.projectUrl + "js/plugins" + "/";
    }

    function getPluginPath(name, ext) {
        if (ext === undefined || ext === null) ext = ".js";

        return getPluginRoot() + name + ext;
    }

    Connections {
        target: DataManager
        onProjectUrlChanged: {
            _cleanCache();
        }
    }

    function _cleanCache() {
        _pluginsCache = {};
    }

    function parsePlugin(name) {
        var cache = _pluginsCache[name];
        var path = getPluginPath(name);
        var stats = UCCU.FileSystemAPI.statSync(TkoolAPI.urlToPath(path)) || {};
        if (!stats) return {};
        if (cache && cache.mtime !== undefined && cache.mtime === stats.mtime.getTime() && cache.size !== undefined && cache.size === stats.size) {
            return cache.data;
        }
        cache = {
            mtime: stats.mtime.getTime(),
            size: stats.size,
            data: parse(TkoolAPI.readFile(path))
        };
        _pluginsCache[name] = cache;
        return cache.data;
    }

    function parse(code, locale) {
        var result = _processCommentBlock(_filterComments(code, locale)).data;
        return result;
    }

    function _filterComments(code, locale) {
        if (!locale) locale = TkoolAPI.locale();

        var defaultComments = "", localizedComments = "";
        var re = /\/\*\:([a-zA-Z_]*)([\s\S]*?)\*\//mg;

        while(true) {
            var match = re.exec(code);
            if (match) {
                var lang = match[1];
                if (!lang || lang === "en") {
                    defaultComments = match[2];
                } else if (lang.length >= 2 && locale.indexOf(lang) === 0) {
                    localizedComments = match[2];
                }
            } else {
                break;
            }
        }

        return localizedComments || defaultComments;
    }

    function _processCommentBlock(comments) {
        _initBuiltInHandlers();

        var context = {"data": {}};
        context.currentParent = context.data;
        var re = /@(\w+)([^@]*)/g;
        while (true) {
            var match = re.exec(comments);
            if (!match) {
                break;
            }
            var keyword = match[1];
            var text = match[2];
            text = text.replace(/[ ]*\n[ ]*\*?[ ]?/g, "\n");
            text = text.trim();
            var text2 = text.split("\n")[0];

            var handler = _handlers[keyword];
            if (handler) handler(context, text, text2);
        }
        return context;
    }

    function registerHandler(keyword, handler) {
        _initBuiltInHandlers();
        _handlers[keyword] = handler;
    }

    function _initBuiltInHandlers() {
        if (_handlers) return;

        _handlers = {};

        _handlers['help'] = function(context, text, text2) {
            context.data.help = text;
        };

        _handlers['plugindesc'] = function(context, text, text2) {
            context.data.description = text;
        };

        _handlers['author'] = function(context, text, text2) {
            context.data.author = text2;
        };

        _handlers['param'] = function(context, text, text2) {
            context.currentParameter = {name: text2};
            context.currentObject = context.currentParameter;

            if (!context.currentParent.parameters) context.currentParent.parameters = [];
            context.currentParent.parameters.push(context.currentObject);
        };

        _handlers['desc'] = function(context, text, text2) {
            context.currentObject.description = text;
        };

        _handlers['default'] = function(context, text, text2) {
            context.currentObject.defaultValue = text2;
        };

        _handlers['title'] = function(context, text, text2) {
            context.currentObject.title = text2;
        };

        _handlers['type'] = function(context, text, text2) {
            context.currentObject.type = text2;
        };

        _handlers['eventgroup'] = function(context, text, text2) {
            context.currentEventGroup = {name: text2};
            context.currentObject = context.currentEventGroup;
            context.currentParent = context.currentEventGroup;

            if (!context.data.eventGroups) context.data.eventGroups = [];
            context.data.eventGroups.push(context.currentObject);
        };

        _handlers['event'] = function(context, text, text2) {
            context.currentEventCommand = {name: text2};
            context.currentObject = context.currentEventCommand;
            context.currentParent = context.currentEventCommand;

            if (!context.currentEventGroup.eventCommands) context.currentEventGroup.eventCommands = [];
            context.currentEventGroup.eventCommands.push(context.currentObject);
        };

    }
}
