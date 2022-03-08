create or replace package body com_fos_trigger_event
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This plug-in lets you trigger a custom event via dynamic action. You can
--  additionally add a condition and fire an alternative event name. You can also
--  decide whether or not to contine the following actions or cancel them.
--
--  License: MIT
--
--  GitHub: https://github.com/foex-open-source/fos-trigger-event
--
-- =============================================================================

function render
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_render_result
as
    -- l_result is necessary for the plugin infrastructure
    l_result             apex_plugin.t_dynamic_action_render_result;

    -- read plugin parameters and store in local variables
    l_client_substitutions  boolean                            := nvl(p_dynamic_action.attribute_11, 'N') = 'Y';
    l_event_name            p_dynamic_action.attribute_01%type := case when l_client_substitutions then p_dynamic_action.attribute_01 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_01) end;
    l_data                  p_dynamic_action.attribute_02%type := nvl(p_dynamic_action.attribute_02, 'none');
    l_value                 p_dynamic_action.attribute_03%type := case when l_client_substitutions then p_dynamic_action.attribute_03 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_03) end;
    l_javascript_code       p_dynamic_action.attribute_04%type := apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_04);

    l_condition_type        p_dynamic_action.attribute_05%type := nvl(p_dynamic_action.attribute_05, 'NO_CONDITION');
    l_condition_item        p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;
    l_condition_value       p_dynamic_action.attribute_07%type := case when l_client_substitutions then p_dynamic_action.attribute_07 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_07) end;
    l_condition_js_expr     p_dynamic_action.attribute_08%type := apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_08);

    l_cancel_event          boolean                            := nvl(p_dynamic_action.attribute_09, 'N') = 'Y';
    l_set_page_item         p_dynamic_action.attribute_10%type := trim(p_dynamic_action.attribute_10);
    l_alternate_event_name  p_dynamic_action.attribute_13%type := case when l_client_substitutions then p_dynamic_action.attribute_13 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_13) end;

begin
    -- standard debugging intro, but only if necessary
    if apex_application.g_debug and substr(:DEBUG,6) >= 6
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    -- create a JS function call passing all settings as a JSON object
    -- note: instead of a "dataFunction" also static "data" can be passed
    --
    -- FOS.trigger.action(this, {
    --     "event": "MY_CUSTOM_EVENT",
    --     "dataFunction": function() {
    --         <your JS code>
    --     }
    -- });
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('pluginName', p_plugin.name);
    apex_json.write('eventName' , trim(both ',' from trim(l_event_name)));

    case l_data
        when 'value' then
            apex_json.write('data', l_value);
        when 'use-current' then
            apex_json.write_raw
                ( p_name  => 'dataFunction'
                , p_value => 'function(){return this.data;}'
                );
        when 'javascript-expression' then
            apex_json.write_raw
                ( p_name  => 'dataFunction'
                , p_value => 'function(){return ('|| l_javascript_code ||');}'
                );
        when 'javascript-function-body' then
            apex_json.write_raw
                ( p_name  => 'dataFunction'
                , p_value => 'function(){' || l_javascript_code || '}'
                );
        else null;
    end case;

    apex_json.write('conditionType'     , l_condition_type);

    if l_condition_type = 'JAVASCRIPT_EXPRESSION'
    then
        apex_json.write_raw
          ( p_name  => 'conditionFunction'
          , p_value => 'function(){return (' || l_condition_js_expr || ');}'
          );
    else
        apex_json.write('conditionItem' , l_condition_item);
        apex_json.write('conditionValue', l_condition_value);
    end if;

    apex_json.write('cancelEvent'       , l_cancel_event);
    apex_json.write('setPageItem'       , l_set_page_item);
    apex_json.write('substitutions'     , l_client_substitutions);
    apex_json.write('alternateEventName', trim(l_alternate_event_name)); -- we won't trim commas as they might be included for a reason to skip some event names

    apex_json.close_object;

    l_result.javascript_function := 'function(){FOS.utils.trigger(this, ' || apex_json.get_clob_output || ');}';

    apex_json.free_output;

    -- all done, return l_result now containing the javascript function
    return l_result;
end render;

end;
/


