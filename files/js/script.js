window.FOS         = window.FOS         || {};
window.FOS.trigger = window.FOS.trigger || {};

FOS.trigger.action = function (daContext, config) {

    var pluginName = 'FOS - Trigger Event'
    apex.debug.info(pluginName, config);

    var afElements = daContext.affectedElements;
    var daCanceled = false;

    if (!afElements) {
        return;
    };

    let data;
    if(config.data){
        data = config.data;
    } else if(config.dataFunction){
        data = config.dataFunction.call(daContext);
    }

    for (var i = 0; i < afElements.length; i++) {
        var canceled = apex.event.trigger(afElements[i], config.event, data);
        daCanceled = daCanceled || canceled;
    }

    if(apex.da.cancel){
        // as of 20.1
        apex.da.cancel();
    } else {
        apex.event.gCancelFlag = true;
        apex.da.gCancelActions = true;
    }
};

