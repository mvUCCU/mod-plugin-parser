pragma Singleton
import QtQuick 2.3
import Tkool.rpg 1.0
import UCCU 1.0 as UCCU
import ".."

Item {
    property var _pluginsCache: null
    property var _handlers: null

    function parse(code, locale) {
        return _processCommentBlock(_filterComments(code, locale)).data;
    }

    function registerHandler(keyword, handler) {
        _initBuiltInHandlers();
        _handlers[keyword] = handler;
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

            if (!context.data.parameters) context.data.parameters = [];
            context.data.parameters.push(context.currentParameter);
        };

        _handlers['desc'] = function(context, text, text2) {
            context.currentParameter.description = text;
        };

        _handlers['default'] = function(context, text, text2) {
            context.currentParameter.defaultValue = text2;
        };
    }
}
