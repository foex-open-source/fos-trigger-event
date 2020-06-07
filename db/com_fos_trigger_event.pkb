CREATE OR REPLACE PACKAGE BODY COM_FOS_TRIGGER_EVENT
IS
function render
    ( p_dynamic_action apex_plugin.t_dynamic_action
    , p_plugin         apex_plugin.t_plugin
    )
return apex_plugin.t_dynamic_action_render_result
as
    l_result apex_plugin.t_dynamic_action_render_result;

    l_event_name         p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
    l_data               p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;
    l_value              p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;
    l_javascript_code    p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;
begin

    if apex_application.g_debug then
        apex_plugin_util.debug_dynamic_action
            ( p_dynamic_action => p_dynamic_action
            , p_plugin         => p_plugin
            );
    end if;

    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('event', l_event_name);

    case l_data
        when 'value' then
            apex_json.write('data', l_value);
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
    end case;

    apex_json.close_object;

    l_result.javascript_function := 'function(){FOS.trigger.action(this, ' || apex_json.get_clob_output || ');}';

    apex_json.free_output;

    return l_result;
end;
END COM_FOS_TRIGGER_EVENT;
/


