var nuBridge = {
trackEvent: function (eventString) {nu_ios.trackEvent(eventString); },
    executeUrl : function (url) { window.location = url;},
    injectCss :  function(css) {var style = document.createElement('style');
        style.innerHTML = css;
        document.head.appendChild(style);}
};
window.dispatchEvent(new Event("nu.BridgeReady"));
(function() {
 nuBridge.injectCss('%@');
 }())
