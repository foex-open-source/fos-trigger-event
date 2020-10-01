

/* globals apex,$s */

var FOS = window.FOS || {};
FOS.utils = FOS.utils || {};

/**
 * A dynamic action to declaratively trigger an event on all affected elements, an extra data object can be added to the event.
 * After triggering the event further processing of any following actions of this dynamic action will be optionally cancelled.
 *
 * @param {object}   daContext                      Dynamic Action context as passed in by APEX
 * @param {object}   config                         Configuration object holding the configuration settings
 * @param {string}   config.event                   Name of the event to be raised
 * @param {string}   [config.data]                  Some data that will be passed to the raised event
 * @param {function} [config.dataFunction]          JS function which will be evaluated and its return passed as data object to the event
 */
FOS.utils.trigger = function (daContext, config) {
    var pluginName = config.pluginName;
    apex.debug.info(pluginName, config);

    var afElements = daContext.affectedElements;
    var data, conditionValue, conditionPassed, eventName, eventNames, alternateEventNames, eventCancelled;

    if (!afElements) {
        apex.debug.warn(pluginName + ': there are no affected elements to trigger the event on');
        return;
    }

    // multiple event name support
    eventNames = config.eventName.split(',');

    // trigger the event on all affected elements
    for (var i = 0; i < afElements.length; i++) {
        for (var j = 0; j < eventNames.length; j++) {
            eventName = (eventNames[j] || "").trim();
            if (config.substitutions && eventName) {
                eventName = apex.util.applyTemplate(eventName, {
                    defaultEscapeFilter: null
                });
            }
            // check we have a valid event name, otherwise skip
            if (!eventName) continue;

            // optionally set a page item with the event name so the developer can have extra logic control
            if (config.setPageItem) {
                $s(config.setPageItem, eventName);
            }
            // evaluate our condition (if defined)
            if (['PAGE_IS_VALID', 'PAGE_INVALID'].includes(config.conditionType)) {
                conditionPassed = apex.page.validate();
                conditionPassed = (config.conditionType === 'PAGE_INVALID') ? !conditionPassed : conditionPassed;
            } else if (['PAGE_CHANGED', 'PAGE_NOT_CHANGED'].includes(config.conditionType)) {
                conditionPassed = apex.page.isChanged();
                conditionPassed = (config.conditionType === 'PAGE_NOT_CHANGED') ? !conditionPassed : conditionPassed;
            } else if (config.conditionType == 'JAVASCRIPT_EXPRESSION') {
                // calling the function with the original "this" and the event name in case of multiple event names in use
                conditionPassed = config.conditionFunction.call(daContext, eventName);
            } else if (config.conditionType != 'NO_CONDITION') {
                conditionValue = config.conditionValue;
                if (config.substitutions && conditionValue) {
                    conditionValue = apex.util.applyTemplate(conditionValue, {
                        defaultEscapeFilter: null
                    });
                }
                // we use the internal APEX function for all Item =, !=, >, in list, etc conditions
                daContext.eventName = eventName;
                conditionPassed = apex.da.testCondition.call(daContext, config.conditionItem, config.conditionType, conditionValue);
            } else {
                conditionPassed = true;
            }

            // if the condition has not passed, check if we need to fire an alternative event name
            if (!conditionPassed && config.alternateEventName) {
                if (config.substitutions && config.alternateEventName) {
                    alternateEventNames = apex.util.applyTemplate(config.alternateEventName, {
                        defaultEscapeFilter: null
                    });
                } else {
                    alternateEventNames = config.alternateEventName;
                }
                alternateEventNames = alternateEventNames.split(',');
                conditionPassed = true;
                eventName = alternateEventNames[j];
                // if we don't have a corresponding alternate event name we will skip firing the event
                if (!eventName) continue;
                // we need to update our page item with the correct event name
                if (config.setPageItem) {
                    $s(config.setPageItem, eventName);
                }
            }

            // fire the custom event
            if (conditionPassed) {
                // evaluate data-object out of given configuration (value or function or nothing)
                if (config.data) {
                    if (config.substitutions && config.data) {
                        data = apex.util.applyTemplate(config.data, {
                            defaultEscapeFilter: null
                        });
                    } else {
                        data = config.data;
                    }
                } else if (config.dataFunction) {
                    // we pass in the event name so it can be referenced in case of multiple event names in use
                    // and you want to evaluate the condition per event name Note: this is only useful for Javascript expressions
                    data = config.dataFunction.call(daContext, eventName);
                }
                // the developer can optionally return false from the custom event dynamic action to cancel the following actions (for advanced developers)
                eventCancelled = apex.event.trigger(afElements[i], eventName, data);
            } else {
                apex.debug.info(pluginName + ': the condition did not pass therefore the following event will not be fired: ' + eventName);
            }
        }
    }

    if (eventCancelled || config.cancelEvent) {
        // now cancel further processing of this DA (following actions will not be processed, as the other event is now taking over)
        if (apex.da.cancel) {
            // as of 20.1 method apex.da.cancel exists and will be used
            apex.da.cancel();
        } else {
            apex.event.gCancelFlag = true;
            apex.da.gCancelActions = true;
        }
    }
};



