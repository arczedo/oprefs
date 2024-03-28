 (function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.markdownItSourceMap = f()}})(function(){var define,module,exports;return (function(){function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s}return e})()({1:[function(require,module,exports){
     
     
     module.exports = function(md) {
         const temp = md.renderer.renderToken.bind(md.renderer)
         md.renderer.renderToken = function (tokens, idx, options) {
             let token = tokens[idx]
             if (token.level === 0 && token.map !== null && token.type.endsWith('_open')) {
                 token.attrPush(['data-source-line', token.map[0] + 1])
             }
             return temp(tokens, idx, options)
         }
     };
 },{}]},{},[1])(1)
 });
