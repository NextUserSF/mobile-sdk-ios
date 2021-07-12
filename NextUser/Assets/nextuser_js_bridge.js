var nuBridge = {
  trackEvent: function (obj) {
      window.webkit.messageHandlers.nuBridgeTrackEventHandler.postMessage(obj);
      
  },
  triggerClose: function(obj) {
      window.webkit.messageHandlers.nuBridgeTriggerCloseHandler.postMessage(obj);
  },
  triggerReload: function(obj) {
      window.webkit.messageHandlers.nuBridgeTriggerReloadHandler.postMessage(obj);
  },
  sendData: function(obj) {
      window.webkit.messageHandlers.nuBridgeSendDataHandler.postMessage(obj);
  },
  executeUrl : function (url) { window.location = url;},
  injectCss :  function(css) {var parent = document.getElementsByTagName('head').item(0);
                               var style = document.createElement('style');
                               style.type = 'text/css';
                               style.innerHTML = window.atob(css);
                               parent.appendChild(style)}
};
window.dispatchEvent(new Event("nu.BridgeReady"));
console.log = (function(oriLogFunc){
    return function(str)
    {
    window.webkit.messageHandlers.NextUserJSLogHandler.postMessage(str);
    oriLogFunc.call(console,str);
    }
    })(console.log);
