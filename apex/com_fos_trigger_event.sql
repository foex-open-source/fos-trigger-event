

prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 49755158803875939
--     PLUGIN: 13235263798301758
--     PLUGIN: 34615171094372499
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 34175298479606152
--     PLUGIN: 35822631205839510
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_trigger_event
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(2657630155025963)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.TRIGGER_EVENT'
,p_display_name=>'FOS - Trigger Event(s)'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This plug-in lets you trigger a custom event via dynamic action. You can',
'--  additionally add a condition and fire an alternative event name. You can also',
'--  decide whether or not to contine the following actions or cancel them.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-trigger-event',
'--',
'-- =============================================================================',
'',
'function render',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    -- l_result is necessary for the plugin infrastructure',
'    l_result             apex_plugin.t_dynamic_action_render_result;',
'',
'    -- read plugin parameters and store in local variables',
'    l_client_substitutions  boolean                            := nvl(p_dynamic_action.attribute_11, ''N'') = ''Y'';',
'    l_event_name            p_dynamic_action.attribute_01%type := case when l_client_substitutions then p_dynamic_action.attribute_01 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_01) end;',
'    l_data                  p_dynamic_action.attribute_02%type := nvl(p_dynamic_action.attribute_02, ''none'');',
'    l_value                 p_dynamic_action.attribute_03%type := case when l_client_substitutions then p_dynamic_action.attribute_03 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_03) end;',
'    l_javascript_code       p_dynamic_action.attribute_04%type := apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_04);',
'',
'    l_condition_type        p_dynamic_action.attribute_05%type := nvl(p_dynamic_action.attribute_05, ''NO_CONDITION'');',
'    l_condition_item        p_dynamic_action.attribute_06%type := p_dynamic_action.attribute_06;',
'    l_condition_value       p_dynamic_action.attribute_07%type := case when l_client_substitutions then p_dynamic_action.attribute_07 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_07) end;',
'    l_condition_js_expr     p_dynamic_action.attribute_08%type := apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_08);',
'    ',
'    l_cancel_event          boolean                            := nvl(p_dynamic_action.attribute_09, ''N'') = ''Y'';',
'    l_set_page_item         p_dynamic_action.attribute_10%type := trim(p_dynamic_action.attribute_10);',
'    l_alternate_event_name  p_dynamic_action.attribute_13%type := case when l_client_substitutions then p_dynamic_action.attribute_13 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_13) end;',
'    ',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'',
'    -- create a JS function call passing all settings as a JSON object',
'    -- note: instead of a "dataFunction" also static "data" can be passed',
'    --',
'    -- FOS.trigger.action(this, {',
'    --     "event": "MY_CUSTOM_EVENT",',
'    --     "dataFunction": function() {',
'    --         <your JS code>',
'    --     }',
'    -- });',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    apex_json.write(''pluginName'', p_plugin.name);',
'    apex_json.write(''eventName'' , trim(both '','' from trim(l_event_name)));',
'    ',
'    case l_data',
'        when ''value'' then',
'            apex_json.write(''data'', l_value);',
'        when ''use-current'' then',
'            apex_json.write_raw',
'                ( p_name  => ''dataFunction''',
'                , p_value => ''function(){return this.data;}''',
'                );',
'        when ''javascript-expression'' then',
'            apex_json.write_raw',
'                ( p_name  => ''dataFunction''',
'                , p_value => ''function(){return (''|| l_javascript_code ||'');}''',
'                );',
'        when ''javascript-function-body'' then',
'            apex_json.write_raw',
'                ( p_name  => ''dataFunction''',
'                , p_value => ''function(){'' || l_javascript_code || ''}''',
'                );',
'        else null;',
'    end case;',
' ',
'    apex_json.write(''conditionType''     , l_condition_type);',
'    ',
'    if l_condition_type = ''JAVASCRIPT_EXPRESSION'' ',
'    then',
'        apex_json.write_raw',
'          ( p_name  => ''conditionFunction''',
'          , p_value => ''function(){return ('' || l_condition_js_expr || '');}''',
'          );',
'    else',
'        apex_json.write(''conditionItem'' , l_condition_item);',
'        apex_json.write(''conditionValue'', l_condition_value);',
'    end if;',
'',
'    apex_json.write(''cancelEvent''       , l_cancel_event);',
'    apex_json.write(''setPageItem''       , l_set_page_item);',
'    apex_json.write(''substitutions''     , l_client_substitutions);',
'    apex_json.write(''alternateEventName'', trim(l_alternate_event_name)); -- we won''t trim commas as they might be included for a reason to skip some event names',
'',
'    apex_json.close_object;',
'',
'    l_result.javascript_function := ''function(){FOS.util.trigger(this, '' || apex_json.get_clob_output || '');}'';',
'',
'    apex_json.free_output;',
'',
'    -- all done, return l_result now containing the javascript function',
'    return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'ITEM:BUTTON:REGION:JQUERY_SELECTOR:JAVASCRIPT_EXPRESSION:TRIGGERING_ELEMENT:EVENT_SOURCE:REQUIRED'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Trigger Event</strong> dynamic action plug-in is used for controlling the branching logic (if/then/else) within a dynamic action. It gives you/developers the declarative ability to fire custom event(s) which other dynamic actions'
||' can listen to, whilst giving you the option to cancel the following actions in the current dynamic action. Hence why we use the term branching.</p>',
'<h3>Conditional Event Firing</h3>',
'<p>The plug-in has the added flexibility of allowing you to define a client-side condition as to whether you fire the event. It is somewhat similar to our "FOS - Client-side Condition" dynamic action, but provides more focus on branching of logic thr'
||'ough the firing of events.</p>',
'<h3>Multiple Events</h3>',
'<p>You can also fire multiple events by comma separating them, as well as defining the "data" object that is passed into the event in case you need to transfer extra information. Why wouldn''t I just use multiple actions instead? Our goal is to focus '
||'on efficiency and reduce the overall number of actions that developers create. Since we''re firing an event already, we thought we should give you the ability to fire multiple events.</p>'))
,p_version_identifier=>'20.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// Settings for the FOS browser extension',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>267
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(2657831289025979)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Event Name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The event name to be triggered. You can trigger multiple event names by separating them with a comma i.e. ",". We suggest you define your event names in lowercase as this is the industry standard.</p>',
'<h3>Trigger a Single Event</h3>',
'<pre>',
'my-custom-event',
'</pre>',
'<h3>Trigger Multiple Events</h3>',
'<pre>',
'my-custom-first-event,my-custom-second-event,my-custom-third-event',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8572200220611966)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Data'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'none'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Optional additional parameters to pass along to the event handler.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(8572957943612931)
,p_plugin_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_display_sequence=>10
,p_display_value=>'None'
,p_return_value=>'none'
,p_help_text=>'<p>Don''t pass any extra data</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(8573310800613894)
,p_plugin_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_display_sequence=>20
,p_display_value=>'Value'
,p_return_value=>'value'
,p_help_text=>'<p>Pass a simple static value</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(8573798044616192)
,p_plugin_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_display_sequence=>30
,p_display_value=>'JavaScript Expression'
,p_return_value=>'javascript-expression'
,p_help_text=>'<p>Pass the result of a JavaScript expression</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(9277314033526707)
,p_plugin_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_display_sequence=>40
,p_display_value=>'JavaScript Function Body'
,p_return_value=>'javascript-function-body'
,p_help_text=>'<p>Pass the return value of a JavaScript function body</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(36332281405802238)
,p_plugin_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_display_sequence=>50
,p_display_value=>'Use the Current Data Object'
,p_return_value=>'use-current'
,p_help_text=>'<p>Choosing this setting will mean that we will pass in the same data object that was available within this current action i.e. "this.data"</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8574432108622337)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Value'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'value'
,p_help_text=>'<p>The static value to be passed with the event. The listener can access this value via <code>this.data</code>.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8575189053644800)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'JavaScript Code'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(8572200220611966)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'javascript-expression,javascript-function-body'
,p_help_text=>'<p>The value to be passed with the event. The listener can access this value via <code>this.data</code>.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19961136004985023)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Event Condition'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'NO_CONDITION'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(20377531625517532)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
,p_help_text=>'<p>You can add a client-side condition to determine whether you trigger the event or not. If you have defined multiple event names the condition will be applied to all the event names.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19962693466987618)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>10
,p_display_value=>'No Condition'
,p_return_value=>'NO_CONDITION'
,p_help_text=>'<p>There is no condition for triggering the event, it will be fired always.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19964170310989571)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>20
,p_display_value=>'Item = Value'
,p_return_value=>'EQUALS'
,p_help_text=>'<p>Checks if the value of the selected Item is equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19964570792991143)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>30
,p_display_value=>'Item != Value'
,p_return_value=>'NOT_EQUALS'
,p_help_text=>'<p>Checks if the value of the selected Item is not equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19964953696993940)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>40
,p_display_value=>'Item > Value'
,p_return_value=>'GREATER_THAN'
,p_help_text=>'<p>Checks if the value of the selected Item is greater than the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19965384951995991)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>50
,p_display_value=>'Item >= Value'
,p_return_value=>'GREATER_THAN_OR_EQUAL'
,p_help_text=>'<p>Checks if the value of the selected Item is greater than or equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19965743605997910)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>60
,p_display_value=>'Item < Value'
,p_return_value=>'LESS_THAN'
,p_help_text=>'<p>Checks if the value of the selected Item is less than the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19966156036999803)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>70
,p_display_value=>'Item <= Value'
,p_return_value=>'LESS_THAN_OR_EQUAL'
,p_help_text=>'<p>Checks if the value of the selected Item is less than or equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19966591278002375)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>80
,p_display_value=>'Item is null'
,p_return_value=>'NULL'
,p_help_text=>'<p>Checks if the selected Item is empty.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19966953294004419)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>90
,p_display_value=>'Item is not null'
,p_return_value=>'NOT_NULL'
,p_help_text=>'<p>Checks if the selected Item is not empty.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19967350607006449)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>100
,p_display_value=>'Item is in list'
,p_return_value=>'IN_LIST'
,p_help_text=>'<p>Checks if the value of the selected Item is in the List specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19967710584008694)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>110
,p_display_value=>'Item is not in list'
,p_return_value=>'NOT_IN_LIST'
,p_help_text=>'<p>Checks if the value of the selected Item is not in the List specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19968153325010280)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>120
,p_display_value=>'JavaScript Expression'
,p_return_value=>'JAVASCRIPT_EXPRESSION'
,p_help_text=>'<p>Evaluates the JavaScript Expression specified for a true/false result.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25731131953806219)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>130
,p_display_value=>'Page is Valid'
,p_return_value=>'PAGE_IS_VALID'
,p_help_text=>'<p>Checks if the page is valid, by calling the <b>apex.page.validate()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25731588636807501)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>140
,p_display_value=>'Page is Invalid'
,p_return_value=>'PAGE_INVALID'
,p_help_text=>'<p>Checks if the page is not valid, by calling the <b>!apex.page.validate()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25731900713808852)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>150
,p_display_value=>'Page has Changed'
,p_return_value=>'PAGE_CHANGED'
,p_help_text=>'<p>Checks if the page has changed, by calling the <b>apex.page.isChanged()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25732360043810245)
,p_plugin_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_display_sequence=>160
,p_display_value=>'Page has not Changed'
,p_return_value=>'PAGE_NOT_CHANGED'
,p_help_text=>'<p>Checks if the page has not changed, by calling the <b>!apex.page.isChanged()</b> API</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19968587325071557)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'NO_CONDITION,JAVASCRIPT_EXPRESSION,PAGE_IS_VALID,PAGE_INVALID,PAGE_CHANGED,PAGE_NOT_CHANGED'
,p_help_text=>'<p>Enter the name of the page item whose value you will use to check whether it matches the condition value.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19970057140088281)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Value'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_IN_LIST'
,p_depending_on_expression=>'NO_CONDITION,JAVASCRIPT_EXPRESSION,PAGE_IS_VALID,PAGE_INVALID,PAGE_CHANGED,PAGE_NOT_CHANGED,NULL,NOT_NULL'
,p_help_text=>'<p>Enter the value you wish to check against the page item value. You can use page item substitutions here to make this a dynamic condition check.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19971673456102403)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Javascript Expression'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'JAVASCRIPT_EXPRESSION'
,p_help_text=>'<p>Enter the javascript expression that will be evaluated to true/false to determine if the condition is met.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19974574575116848)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Cancel Following Actions'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(20377531625517532)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>Enable this option to cancel following actions within this dynamic action. You may want to do this in the case that your custom event takes over the flow of actions.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(20219125450871813)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Set Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(20377531625517532)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>Optionally enter a page item name that the plug-in will set with the custom event name. This can give you extra flexibility in your logic by knowing which custom event is firing.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(20295290087053230)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>47
,p_prompt=>'Client-side Substitutions'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(20377531625517532)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>Enable this option to perform substitution of values on the client side in your event names or data object value.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(20377531625517532)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>45
,p_prompt=>'Advanced Configuration'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'<p>Enable this setting to be able to define conditions etc. on whether you fire the custom event.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(20857203082938816)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>85
,p_prompt=>'Alternate Event Name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19961136004985023)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'NO_CONDITION'
,p_help_text=>'<p>When the condition evaluates to FALSE you can optionally trigger an alternative event name. If you do not specify an alternate event name then no event will be fired.</p>'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C7320617065782C2473202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E7574696C203D20464F532E7574696C207C7C207B7D3B0A0A2F2A2A0A202A20412064796E616D69632061637469';
wwv_flow_api.g_varchar2_table(2) := '6F6E20746F206465636C617261746976656C79207472696767657220616E206576656E74206F6E20616C6C20616666656374656420656C656D656E74732C20616E2065787472612064617461206F626A6563742063616E20626520616464656420746F20';
wwv_flow_api.g_varchar2_table(3) := '746865206576656E742E0A202A2041667465722074726967676572696E6720746865206576656E7420667572746865722070726F63657373696E67206F6620616E7920666F6C6C6F77696E6720616374696F6E73206F6620746869732064796E616D6963';
wwv_flow_api.g_varchar2_table(4) := '20616374696F6E2077696C6C206265206F7074696F6E616C6C792063616E63656C6C65642E0A202A0A202A2040706172616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020202020202020202020202044796E616D6963';
wwv_flow_api.g_varchar2_table(5) := '20416374696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D207B6F626A6563747D202020636F6E66696720202020202020202020202020202020202020202020202020436F6E6669677572617469';
wwv_flow_api.g_varchar2_table(6) := '6F6E206F626A65637420686F6C64696E672074686520636F6E66696775726174696F6E2073657474696E67730A202A2040706172616D207B737472696E677D202020636F6E6669672E6576656E74202020202020202020202020202020202020204E616D';
wwv_flow_api.g_varchar2_table(7) := '65206F6620746865206576656E7420746F206265207261697365640A202A2040706172616D207B737472696E677D2020205B636F6E6669672E646174615D202020202020202020202020202020202020536F6D65206461746120746861742077696C6C20';
wwv_flow_api.g_varchar2_table(8) := '62652070617373656420746F2074686520726169736564206576656E740A202A2040706172616D207B66756E6374696F6E7D205B636F6E6669672E6461746146756E6374696F6E5D202020202020202020204A532066756E6374696F6E20776869636820';
wwv_flow_api.g_varchar2_table(9) := '77696C6C206265206576616C756174656420616E64206974732072657475726E207061737365642061732064617461206F626A65637420746F20746865206576656E740A202A2F0A464F532E7574696C2E74726967676572203D2066756E6374696F6E20';
wwv_flow_api.g_varchar2_table(10) := '286461436F6E746578742C20636F6E66696729207B0A2020202076617220706C7567696E4E616D65203D20636F6E6669672E706C7567696E4E616D653B0A20202020617065782E64656275672E696E666F28706C7567696E4E616D652C20636F6E666967';
wwv_flow_api.g_varchar2_table(11) := '293B0A0A20202020766172206166456C656D656E7473203D206461436F6E746578742E6166666563746564456C656D656E74733B0A2020202076617220646174612C20636F6E646974696F6E56616C75652C20636F6E646974696F6E5061737365642C20';
wwv_flow_api.g_varchar2_table(12) := '6576656E744E616D652C206576656E744E616D65732C20616C7465726E6174654576656E744E616D65732C206576656E7443616E63656C6C65643B0A0A2020202069662028216166456C656D656E747329207B0A2020202020202020617065782E646562';
wwv_flow_api.g_varchar2_table(13) := '75672E7761726E28706C7567696E4E616D65202B20273A20746865726520617265206E6F20616666656374656420656C656D656E747320746F207472696767657220746865206576656E74206F6E27293B0A202020202020202072657475726E3B0A2020';
wwv_flow_api.g_varchar2_table(14) := '20207D0A0A202020202F2F206D756C7469706C65206576656E74206E616D6520737570706F72740A202020206576656E744E616D6573203D20636F6E6669672E6576656E744E616D652E73706C697428272C27293B0A0A202020202F2F20747269676765';
wwv_flow_api.g_varchar2_table(15) := '7220746865206576656E74206F6E20616C6C20616666656374656420656C656D656E74730A20202020666F7220287661722069203D20303B2069203C206166456C656D656E74732E6C656E6774683B20692B2B29207B0A2020202020202020666F722028';
wwv_flow_api.g_varchar2_table(16) := '766172206A203D20303B206A203C206576656E744E616D65732E6C656E6774683B206A2B2B29207B0A2020202020202020202020206576656E744E616D65203D20286576656E744E616D65735B6A5D207C7C202222292E7472696D28293B0A2020202020';
wwv_flow_api.g_varchar2_table(17) := '2020202020202069662028636F6E6669672E737562737469747574696F6E73202626206576656E744E616D6529207B0A202020202020202020202020202020206576656E744E616D65203D20617065782E7574696C2E6170706C7954656D706C61746528';
wwv_flow_api.g_varchar2_table(18) := '6576656E744E616D652C207B0A202020202020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A20202020202020';
wwv_flow_api.g_varchar2_table(19) := '20202020202F2F20636865636B207765206861766520612076616C6964206576656E74206E616D652C206F746865727769736520736B69700A20202020202020202020202069662028216576656E744E616D652920636F6E74696E75653B0A0A20202020';
wwv_flow_api.g_varchar2_table(20) := '20202020202020202F2F206F7074696F6E616C6C792073657420612070616765206974656D207769746820746865206576656E74206E616D6520736F2074686520646576656C6F7065722063616E2068617665206578747261206C6F67696320636F6E74';
wwv_flow_api.g_varchar2_table(21) := '726F6C0A20202020202020202020202069662028636F6E6669672E736574506167654974656D29207B0A20202020202020202020202020202020247328636F6E6669672E736574506167654974656D2C206576656E744E616D65293B0A20202020202020';
wwv_flow_api.g_varchar2_table(22) := '20202020207D0A2020202020202020202020202F2F206576616C75617465206F757220636F6E646974696F6E2028696620646566696E6564290A202020202020202020202020696620285B27504147455F49535F56414C4944272C2027504147455F494E';
wwv_flow_api.g_varchar2_table(23) := '56414C4944275D2E696E636C7564657328636F6E6669672E636F6E646974696F6E547970652929207B0A20202020202020202020202020202020636F6E646974696F6E506173736564203D20617065782E706167652E76616C696461746528293B0A2020';
wwv_flow_api.g_varchar2_table(24) := '2020202020202020202020202020636F6E646974696F6E506173736564203D2028636F6E6669672E636F6E646974696F6E54797065203D3D3D2027504147455F494E56414C49442729203F2021636F6E646974696F6E506173736564203A20636F6E6469';
wwv_flow_api.g_varchar2_table(25) := '74696F6E5061737365643B0A2020202020202020202020207D20656C736520696620285B27504147455F4348414E474544272C2027504147455F4E4F545F4348414E474544275D2E696E636C7564657328636F6E6669672E636F6E646974696F6E547970';
wwv_flow_api.g_varchar2_table(26) := '652929207B0A20202020202020202020202020202020636F6E646974696F6E506173736564203D20617065782E706167652E69734368616E67656428293B0A20202020202020202020202020202020636F6E646974696F6E506173736564203D2028636F';
wwv_flow_api.g_varchar2_table(27) := '6E6669672E636F6E646974696F6E54797065203D3D3D2027504147455F4E4F545F4348414E4745442729203F2021636F6E646974696F6E506173736564203A20636F6E646974696F6E5061737365643B0A2020202020202020202020207D20656C736520';
wwv_flow_api.g_varchar2_table(28) := '69662028636F6E6669672E636F6E646974696F6E54797065203D3D20274A4156415343524950545F45585052455353494F4E2729207B0A202020202020202020202020202020202F2F2063616C6C696E67207468652066756E6374696F6E207769746820';
wwv_flow_api.g_varchar2_table(29) := '746865206F726967696E616C2022746869732220616E6420746865206576656E74206E616D6520696E2063617365206F66206D756C7469706C652
06576656E74206E616D657320696E207573650A20202020202020202020202020202020636F6E646974';
wwv_flow_api.g_varchar2_table(30) := '696F6E506173736564203D20636F6E6669672E636F6E646974696F6E46756E6374696F6E2E63616C6C286461436F6E746578742C206576656E744E616D65293B0A2020202020202020202020207D20656C73652069662028636F6E6669672E636F6E6469';
wwv_flow_api.g_varchar2_table(31) := '74696F6E5479706520213D20274E4F5F434F4E444954494F4E2729207B0A20202020202020202020202020202020636F6E646974696F6E56616C7565203D20636F6E6669672E636F6E646974696F6E56616C75653B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(32) := '202069662028636F6E6669672E737562737469747574696F6E7320262620636F6E646974696F6E56616C756529207B0A2020202020202020202020202020202020202020636F6E646974696F6E56616C7565203D20617065782E7574696C2E6170706C79';
wwv_flow_api.g_varchar2_table(33) := '54656D706C61746528636F6E646974696F6E56616C75652C207B0A20202020202020202020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A20202020202020202020202020202020202020207D293B';
wwv_flow_api.g_varchar2_table(34) := '0A202020202020202020202020202020207D0A202020202020202020202020202020202F2F207765207573652074686520696E7465726E616C20415045582066756E6374696F6E20666F7220616C6C204974656D203D2C20213D2C203E2C20696E206C69';
wwv_flow_api.g_varchar2_table(35) := '73742C2065746320636F6E646974696F6E730A202020202020202020202020202020206461436F6E746578742E6576656E744E616D65203D206576656E744E616D653B0A20202020202020202020202020202020636F6E646974696F6E50617373656420';
wwv_flow_api.g_varchar2_table(36) := '3D20617065782E64612E74657374436F6E646974696F6E2E63616C6C286461436F6E746578742C20636F6E6669672E636F6E646974696F6E4974656D2C20636F6E6669672E636F6E646974696F6E547970652C20636F6E646974696F6E56616C7565293B';
wwv_flow_api.g_varchar2_table(37) := '0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020636F6E646974696F6E506173736564203D20747275653B0A2020202020202020202020207D0A0A2020202020202020202020202F2F206966207468652063';
wwv_flow_api.g_varchar2_table(38) := '6F6E646974696F6E20686173206E6F74207061737365642C20636865636B206966207765206E65656420746F206669726520616E20616C7465726E6174697665206576656E74206E616D650A2020202020202020202020206966202821636F6E64697469';
wwv_flow_api.g_varchar2_table(39) := '6F6E50617373656420262620636F6E6669672E616C7465726E6174654576656E744E616D6529207B0A2020202020202020202020202020202069662028636F6E6669672E737562737469747574696F6E7320262620636F6E6669672E616C7465726E6174';
wwv_flow_api.g_varchar2_table(40) := '654576656E744E616D6529207B0A2020202020202020202020202020202020202020616C7465726E6174654576656E744E616D6573203D20617065782E7574696C2E6170706C7954656D706C61746528636F6E6669672E616C7465726E6174654576656E';
wwv_flow_api.g_varchar2_table(41) := '744E616D652C207B0A20202020202020202020202020202020202020202020202064656661756C7445736361706546696C7465723A206E756C6C0A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(42) := '20656C7365207B0A2020202020202020202020202020202020202020616C7465726E6174654576656E744E616D6573203D20636F6E6669672E616C7465726E6174654576656E744E616D653B0A202020202020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(43) := '2020202020202020202020616C7465726E6174654576656E744E616D6573203D20616C7465726E6174654576656E744E616D65732E73706C697428272C27293B0A20202020202020202020202020202020636F6E646974696F6E506173736564203D2074';
wwv_flow_api.g_varchar2_table(44) := '7275653B0A202020202020202020202020202020206576656E744E616D65203D20616C7465726E6174654576656E744E616D65735B6A5D3B0A202020202020202020202020202020202F2F20696620776520646F6E27742068617665206120636F727265';
wwv_flow_api.g_varchar2_table(45) := '73706F6E64696E6720616C7465726E617465206576656E74206E616D652077652077696C6C20736B697020666972696E6720746865206576656E740A2020202020202020202020202020202069662028216576656E744E616D652920636F6E74696E7565';
wwv_flow_api.g_varchar2_table(46) := '3B0A202020202020202020202020202020202F2F207765206E65656420746F20757064617465206F75722070616765206974656D20776974682074686520636F7272656374206576656E74206E616D650A20202020202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(47) := '28636F6E6669672E736574506167654974656D29207B0A2020202020202020202020202020202020202020247328636F6E6669672E736574506167654974656D2C206576656E744E616D65293B0A202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(48) := '20202020202020207D0A0A2020202020202020202020202F2F20666972652074686520637573746F6D206576656E740A20202020202020202020202069662028636F6E646974696F6E50617373656429207B0A202020202020202020202020202020202F';
wwv_flow_api.g_varchar2_table(49) := '2F206576616C7561746520646174612D6F626A656374206F7574206F6620676976656E20636F6E66696775726174696F6E202876616C7565206F722066756E6374696F6E206F72206E6F7468696E67290A20202020202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(50) := '28636F6E6669672E6461746129207B0A202020202020202020202020202020202020202069662028636F6E6669672E737562737469747574696F6E7320262620636F6E6669672E6461746129207B0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(51) := '20202064617461203D20617065782E7574696C2E6170706C7954656D706C61746528636F6E6669672E646174612C207B0A2020202020202020202020202020202020202020202020202020202064656661756C7445736361706546696C7465723A206E75';
wwv_flow_api.g_varchar2_table(52) := '6C6C0A2020202020202020202020202020202020202020202020207D293B0A20202020202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020202020202064617461203D20636F6E6669672E6461';
wwv_flow_api.g_varchar2_table(53) := '74613B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D20656C73652069662028636F6E6669672E6461746146756E6374696F6E29207B0A20202020202020202020202020202020202020202F2F2077';
wwv_flow_api.g_varchar2_table(54) := '65207061737320696E20746865206576656E74206E616D6520736F2069742063616E206265207265666572656E63656420696E2063617365206F66206D756C7469706C65206576656E74206E616D657320696E20757365200A2020202020202020202020';
wwv_flow_api.g_varchar2_table(55) := '2020202020202020202F2F20616E6420796F752077616E7420746F206576616C756174652074686520636F6E646974696F6E20706572206576656E74206E616D65204E6F74653A2074686973206973206F6E6C792075736566756C20666F72204A617661';
wwv_flow_api.g_varchar2_table(56) := '7363726970742065787072657373696F6E730A202020202020202020202020202020202020202064617461203D20636F6E6669672E6461746146756E6374696F6E2E63616C6C286461436F6E746578742C206576656E744E616D65293B0A202020202020';
wwv_flow_api.g_varchar2_table(57) := '202020202020202020207D0A202020202020202020202020202020202F2F2074686520646576656C6F7065722063616E206F7074696F6E616C6C792072657475726E2066616C73652066726F6D2074686520637573746F6D206576656E742064796E616D';
wwv_flow_api.g_varchar2_table(58) := '696320616374696F6E20746F2063616E63656C2074686520666F6C6C6F77696E6720616374696F6E732028666F7220616476616E63656420646576656C6F70657273290A202020202020202020202020202020206576656E7443616E63656C6C6564203D';
wwv_flow_api.g_varchar2_table(59) := '20617065782E6576656E742E74726967676572286166456C656D656E74735B695D2C206576656E744E616D652C2064617461293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020617065782E6465627567';
wwv_flow_api.g_varchar2_table(60) := '2E696E666F28706C7567696E4E616D65202B20273A2074686520636F6E646974696F6E20646964206E6F742070617373207468657265666F72652074686520666F6C6C6F77696E67206576656E742077696C6C206E6F742062652066697265643A202720';
wwv_flow_api.g_varchar2_table(61) := '2B206576656E744E616D65293B0A2020202020202020202020207D0A20202020202020207D0A202020207D0A0A20202020696620286576656E7443616E63656C6C6564207C7C20636F6E6669672E63616E63656C4576656E7429207B0A20202020202020';
wwv_flow_api.g_varchar2_table(62) := '202F2F206E6F772063616E63656C20667572746865722070726F63657373696E67206F6620746869732044412028666F6C6C6F77696E6720616374696F6E732077696C6C206E6F742062652070726F6365737365642C20617320746865206F7468657220';
wwv_flow_api.g_varchar2_table(63) := '6576656E74206973206E6F772074616B696E67206F766572290A202020202020202069662028617065782E64612E63616E63656C29207B0A2020202020202020202020202F2F206173206F662032302E31206D6574686F6420617065782E64612E63616E';
wwv_flow_api.g_varchar2_table(64) := '63656C2065786973747320616E642077696C6C20626520757365640A202020202020202020202020617065782E64612E63616E63656C28293B0A20202020202020207D20656C7365207B0A202020202020202020202020617065782E6576656E742E6743';
wwv_flow_api.g_varchar2_table(65) := '616E63656C466C6167203D20747275653B0A202020202020202020202020617065782E64612E6743616E63656C416374696F6E73203D20747275653B0A20202020202020207D0A202020207D0A7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8480839872607786)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E7574696C3D464F532E7574696C7C7C7B7D2C464F532E7574696C2E747269676765723D66756E6374696F6E28652C74297B76617220613D742E706C7567696E4E616D653B617065782E';
wwv_flow_api.g_varchar2_table(2) := '64656275672E696E666F28612C74293B766172206E2C692C6C2C6F2C702C642C633D652E6166666563746564456C656D656E74733B69662863297B703D742E6576656E744E616D652E73706C697428222C22293B666F722876617220753D303B753C632E';
wwv_flow_api.g_varchar2_table(3) := '6C656E6774683B752B2B29666F722876617220733D303B733C702E6C656E6774683B732B2B296966286F3D28705B735D7C7C2222292E7472696D28292C742E737562737469747574696F6E7326266F2626286F3D617065782E7574696C2E6170706C7954';
wwv_flow_api.g_varchar2_table(4) := '656D706C617465286F2C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C6F297B696628742E736574506167654974656D2626247328742E736574506167654974656D2C6F292C5B22504147455F49535F56414C4944222C225041';
wwv_flow_api.g_varchar2_table(5) := '47455F494E56414C4944225D2E696E636C7564657328742E636F6E646974696F6E54797065293F286C3D617065782E706167652E76616C696461746528292C6C3D22504147455F494E56414C4944223D3D3D742E636F6E646974696F6E547970653F216C';
wwv_flow_api.g_varchar2_table(6) := '3A6C293A5B22504147455F4348414E474544222C22504147455F4E4F545F4348414E474544225D2E696E636C7564657328742E636F6E646974696F6E54797065293F286C3D617065782E706167652E69734368616E67656428292C6C3D22504147455F4E';
wwv_flow_api.g_varchar2_table(7) := '4F545F4348414E474544223D3D3D742E636F6E646974696F6E547970653F216C3A6C293A224A4156415343524950545F45585052455353494F4E223D3D742E636F6E646974696F6E547970653F6C3D742E636F6E646974696F6E46756E6374696F6E2E63';
wwv_flow_api.g_varchar2_table(8) := '616C6C28652C6F293A224E4F5F434F4E444954494F4E22213D742E636F6E646974696F6E547970653F28693D742E636F6E646974696F6E56616C75652C742E737562737469747574696F6E73262669262628693D617065782E7574696C2E6170706C7954';
wwv_flow_api.g_varchar2_table(9) := '656D706C61746528692C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C652E6576656E744E616D653D6F2C6C3D617065782E64612E74657374436F6E646974696F6E2E63616C6C28652C742E636F6E646974696F6E4974656D2C';
wwv_flow_api.g_varchar2_table(10) := '742E636F6E646974696F6E547970652C6929293A6C3D21302C216C2626742E616C7465726E6174654576656E744E616D65297B6966286C3D21302C21286F3D28742E737562737469747574696F6E732626742E616C7465726E6174654576656E744E616D';
wwv_flow_api.g_varchar2_table(11) := '653F617065782E7574696C2E6170706C7954656D706C61746528742E616C7465726E6174654576656E744E616D652C7B64656661756C7445736361706546696C7465723A6E756C6C7D293A742E616C7465726E6174654576656E744E616D65292E73706C';
wwv_flow_api.g_varchar2_table(12) := '697428222C22295B735D2929636F6E74696E75653B742E736574506167654974656D2626247328742E736574506167654974656D2C6F297D6C3F28742E646174613F6E3D742E737562737469747574696F6E732626742E646174613F617065782E757469';
wwv_flow_api.g_varchar2_table(13) := '6C2E6170706C7954656D706C61746528742E646174612C7B64656661756C7445736361706546696C7465723A6E756C6C7D293A742E646174613A742E6461746146756E6374696F6E2626286E3D742E6461746146756E6374696F6E2E63616C6C28652C6F';
wwv_flow_api.g_varchar2_table(14) := '29292C643D617065782E6576656E742E7472696767657228635B755D2C6F2C6E29293A617065782E64656275672E696E666F28612B223A2074686520636F6E646974696F6E20646964206E6F742070617373207468657265666F72652074686520666F6C';
wwv_flow_api.g_varchar2_table(15) := '6C6F77696E67206576656E742077696C6C206E6F742062652066697265643A20222B6F297D28647C7C742E63616E63656C4576656E7429262628617065782E64612E63616E63656C3F617065782E64612E63616E63656C28293A28617065782E6576656E';
wwv_flow_api.g_varchar2_table(16) := '742E6743616E63656C466C61673D21302C617065782E64612E6743616E63656C416374696F6E733D213029297D656C736520617065782E64656275672E7761726E28612B223A20746865726520617265206E6F20616666656374656420656C656D656E74';
wwv_flow_api.g_varchar2_table(17) := '7320746F207472696767657220746865206576656E74206F6E22297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8482588807132749)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C227574696C222C2274726967676572222C226461436F6E74657874222C22636F6E666967222C22';
wwv_flow_api.g_varchar2_table(2) := '706C7567696E4E616D65222C2261706578222C226465627567222C22696E666F222C2264617461222C22636F6E646974696F6E56616C7565222C22636F6E646974696F6E506173736564222C226576656E744E616D65222C226576656E744E616D657322';
wwv_flow_api.g_varchar2_table(3) := '2C226576656E7443616E63656C6C6564222C226166456C656D656E7473222C226166666563746564456C656D656E7473222C2273706C6974222C2269222C226C656E677468222C226A222C227472696D222C22737562737469747574696F6E73222C2261';
wwv_flow_api.g_varchar2_table(4) := '70706C7954656D706C617465222C2264656661756C7445736361706546696C746572222C22736574506167654974656D222C222473222C22696E636C75646573222C22636F6E646974696F6E54797065222C2270616765222C2276616C6964617465222C';
wwv_flow_api.g_varchar2_table(5) := '2269734368616E676564222C22636F6E646974696F6E46756E6374696F6E222C2263616C6C222C226461222C2274657374436F6E646974696F6E222C22636F6E646974696F6E4974656D222C22616C7465726E6174654576656E744E616D65222C226461';
wwv_flow_api.g_varchar2_table(6) := '746146756E6374696F6E222C226576656E74222C2263616E63656C4576656E74222C2263616E63656C222C226743616E63656C466C6167222C226743616E63656C416374696F6E73222C227761726E225D2C226D617070696E6773223A22414145412C49';
wwv_flow_api.g_varchar2_table(7) := '414149412C4941414D432C4F41414F442C4B41414F2C4741437842412C49414149452C4B41414F462C49414149452C4D4141512C4741597642462C49414149452C4B41414B432C514141552C53414155432C45414157432C47414370432C49414149432C';
wwv_flow_api.g_varchar2_table(8) := '45414161442C4541414F432C5741437842432C4B41414B432C4D41414D432C4B41414B482C45414159442C47414535422C494143494B2C4541414D432C4541416742432C4541416942432C45414157432C4541416943432C4541446E46432C454141615A';
wwv_flow_api.g_varchar2_table(9) := '2C45414155612C6942414733422C4741414B442C4541414C2C43414D41462C45414161542C4541414F512C554141554B2C4D41414D2C4B414770432C4941414B2C49414149432C454141492C45414147412C45414149482C45414157492C4F414151442C';
wwv_flow_api.g_varchar2_table(10) := '4941436E432C4941414B2C49414149452C454141492C45414147412C45414149502C454141574D2C4F414151432C4941516E432C47415041522C47414161432C454141574F2C4941414D2C49414149432C4F414339426A422C4541414F6B422C65414169';
wwv_flow_api.g_varchar2_table(11) := '42562C4941437842412C454141594E2C4B41414B4C2C4B41414B73422C63414163582C454141572C4341433343592C6F42414171422C51414978425A2C4541414C2C43412B42412C4741354249522C4541414F71422C61414350432C4741414774422C45';
wwv_flow_api.g_varchar2_table(12) := '41414F71422C59414161622C47414776422C434141432C6742414169422C674241416742652C5341415376422C4541414F77422C674241436C446A422C4541416B424C2C4B41414B75422C4B41414B432C57414335426E422C45414134432C694241417A';
wwv_flow_api.g_varchar2_table(13) := '42502C4541414F77422C65414171436A422C4541416B42412C47414331452C434141432C65414167422C6F4241416F4267422C5341415376422C4541414F77422C6742414335446A422C4541416B424C2C4B41414B75422C4B41414B452C594143354270';
wwv_flow_api.g_varchar2_table(14) := '422C45414134432C714241417A42502C4541414F77422C65414179436A422C4541416B42412C47414374442C794241417842502C4541414F77422C634145646A422C4541416B42502C4541414F34422C6B4241416B42432C4B41414B39422C4541415753';
wwv_flow_api.g_varchar2_table(15) := '2C47414335422C674241417842522C4541414F77422C654143646C422C45414169424E2C4541414F4D2C65414370424E2C4541414F6B422C65414169425A2C4941437842412C45414169424A2C4B41414B4C2C4B41414B73422C63414163622C45414167';
wwv_flow_api.g_varchar2_table(16) := '422C4341437244632C6F42414171422C514149374272422C45414155532C55414159412C4541437442442C4541416B424C2C4B41414B34422C47414147432C63414163462C4B41414B39422C45414157432C4541414F67432C6341416568432C4541414F';
wwv_flow_api.g_varchar2_table(17) := '77422C634141656C422C4941457047432C4741416B422C4741496A42412C4741416D42502C4541414F69432C6D4241416F422C4341592F432C4741484131422C4741416B422C4941436C42432C47415449522C4541414F6B422C65414169426C422C4541';
wwv_flow_api.g_varchar2_table(18) := '414F69432C6D424143542F422C4B41414B4C2C4B41414B73422C634141636E422C4541414F69432C6D4241416F422C4341437245622C6F42414171422C4F41474870422C4541414F69432C6F4241455370422C4D41414D2C4B41456842472C4941456842';
wwv_flow_api.g_varchar2_table(19) := '2C5341455A68422C4541414F71422C61414350432C4741414774422C4541414F71422C59414161622C47414B3342442C47414549502C4541414F4B2C4B414548412C454144414C2C4541414F6B422C65414169426C422C4541414F4B2C4B41437842482C';
wwv_flow_api.g_varchar2_table(20) := '4B41414B4C2C4B41414B73422C634141636E422C4541414F4B2C4B41414D2C4341437843652C6F42414171422C4F41476C4270422C4541414F4B2C4B4145584C2C4541414F6B432C6541476437422C4541414F4C2C4541414F6B432C614141614C2C4B41';
wwv_flow_api.g_varchar2_table(21) := '414B39422C45414157532C4941472F43452C4541416942522C4B41414B69432C4D41414D72432C51414151612C45414157472C474141494E2C45414157482C4941453944482C4B41414B432C4D41414D432C4B41414B482C454141612C694641416D464F';
wwv_flow_api.g_varchar2_table(22) := '2C49414B7848452C4741416B42562C4541414F6F432C65414572426C432C4B41414B34422C474141474F2C4F4145526E432C4B41414B34422C474141474F2C554145526E432C4B41414B69432C4D41414D472C614141632C4541437A4270432C4B41414B';
wwv_flow_api.g_varchar2_table(23) := '34422C47414147532C6742414169422C53416C47374272432C4B41414B432C4D41414D71432C4B41414B76432C45414161222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8482990473132750)
,p_plugin_id=>wwv_flow_api.id(2657630155025963)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done




