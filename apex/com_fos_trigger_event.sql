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

prompt APPLICATION 102 - FOS Dev
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 34175298479606152
--     PLUGIN: 2657630155025963
--     PLUGIN: 35822631205839510
--     PLUGIN: 14934236679644451
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
,p_display_name=>'FOS - Trigger Event'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script.min.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render',
'    ( p_dynamic_action apex_plugin.t_dynamic_action',
'    , p_plugin         apex_plugin.t_plugin',
'    )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'',
'    l_event_name         p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_data               p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'    l_value              p_dynamic_action.attribute_03%type := p_dynamic_action.attribute_03;',
'    l_javascript_code    p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'begin',
'',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_dynamic_action',
'            ( p_dynamic_action => p_dynamic_action',
'            , p_plugin         => p_plugin',
'            );',
'    end if;',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    apex_json.write(''event'', l_event_name);',
'    ',
'    case l_data',
'        when ''value'' then',
'            apex_json.write(''data'', l_value);',
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
'    end case;',
' ',
'    apex_json.close_object;',
'',
'    l_result.javascript_function := ''function(){FOS.trigger.action(this, '' || apex_json.get_clob_output || '');}'';',
'',
'    apex_json.free_output;',
'',
'    return l_result;',
'end;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'ITEM:BUTTON:REGION:JQUERY_SELECTOR:JAVASCRIPT_EXPRESSION:TRIGGERING_ELEMENT:EVENT_SOURCE:REQUIRED'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_help_text=>'<p>Triggers an event on the affected elements with an optional data object.</p>'
,p_version_identifier=>'20.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-export',
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>168
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
,p_help_text=>'<p>The event name to be triggered.</p>'
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
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F532020202020202020203D2077696E646F772E464F532020202020202020207C7C207B7D3B0A77696E646F772E464F532E74726967676572203D2077696E646F772E464F532E74726967676572207C7C207B7D3B0A0A464F532E74';
wwv_flow_api.g_varchar2_table(2) := '7269676765722E616374696F6E203D2066756E6374696F6E20286461436F6E746578742C20636F6E66696729207B0A0A2020202076617220706C7567696E4E616D65203D2027464F53202D2054726967676572204576656E74270A20202020617065782E';
wwv_flow_api.g_varchar2_table(3) := '64656275672E696E666F28706C7567696E4E616D652C20636F6E666967293B0A0A20202020766172206166456C656D656E7473203D206461436F6E746578742E6166666563746564456C656D656E74733B0A2020202076617220646143616E63656C6564';
wwv_flow_api.g_varchar2_table(4) := '203D2066616C73653B0A0A2020202069662028216166456C656D656E747329207B0A202020202020202072657475726E3B0A202020207D3B0A0A202020206C657420646174613B0A20202020696628636F6E6669672E64617461297B0A20202020202020';
wwv_flow_api.g_varchar2_table(5) := '2064617461203D20636F6E6669672E646174613B0A202020207D20656C736520696628636F6E6669672E6461746146756E6374696F6E297B0A202020202020202064617461203D20636F6E6669672E6461746146756E6374696F6E2E63616C6C28646143';
wwv_flow_api.g_varchar2_table(6) := '6F6E74657874293B0A202020207D0A0A20202020666F7220287661722069203D20303B2069203C206166456C656D656E74732E6C656E6774683B20692B2B29207B0A20202020202020207661722063616E63656C6564203D20617065782E6576656E742E';
wwv_flow_api.g_varchar2_table(7) := '74726967676572286166456C656D656E74735B695D2C20636F6E6669672E6576656E742C2064617461293B0A2020202020202020646143616E63656C6564203D20646143616E63656C6564207C7C2063616E63656C65643B0A202020207D0A0A20202020';
wwv_flow_api.g_varchar2_table(8) := '696628617065782E64612E63616E63656C297B0A20202020202020202F2F206173206F662032302E310A2020202020202020617065782E64612E63616E63656C28293B0A202020207D20656C7365207B0A2020202020202020617065782E6576656E742E';
wwv_flow_api.g_varchar2_table(9) := '6743616E63656C466C6167203D20747275653B0A2020202020202020617065782E64612E6743616E63656C416374696F6E73203D20747275653B0A202020207D0A7D3B';
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
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F533D77696E646F772E464F537C7C7B7D2C77696E646F772E464F532E747269676765723D77696E646F772E464F532E747269676765727C7C7B7D2C464F532E747269676765722E616374696F6E3D66756E6374696F6E28652C6129';
wwv_flow_api.g_varchar2_table(2) := '7B617065782E64656275672E696E666F2822464F53202D2054726967676572204576656E74222C61293B766172206E3D652E6166666563746564456C656D656E74732C743D21313B696628216E2972657475726E3B6C657420693B612E646174613F693D';
wwv_flow_api.g_varchar2_table(3) := '612E646174613A612E6461746146756E6374696F6E262628693D612E6461746146756E6374696F6E2E63616C6C286529293B666F722876617220723D303B723C6E2E6C656E6774683B722B2B297B76617220673D617065782E6576656E742E7472696767';
wwv_flow_api.g_varchar2_table(4) := '6572286E5B725D2C612E6576656E742C69293B743D747C7C677D617065782E64612E63616E63656C3F617065782E64612E63616E63656C28293A28617065782E6576656E742E6743616E63656C466C61673D21302C617065782E64612E6743616E63656C';
wwv_flow_api.g_varchar2_table(5) := '416374696F6E733D2130297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
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
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22464F53222C2274726967676572222C22616374696F6E222C226461436F6E74657874222C22636F6E66696722';
wwv_flow_api.g_varchar2_table(2) := '2C2261706578222C226465627567222C22696E666F222C226166456C656D656E7473222C226166666563746564456C656D656E7473222C22646143616E63656C6564222C2264617461222C226461746146756E6374696F6E222C2263616C6C222C226922';
wwv_flow_api.g_varchar2_table(3) := '2C226C656E677468222C2263616E63656C6564222C226576656E74222C226461222C2263616E63656C222C226743616E63656C466C6167222C226743616E63656C416374696F6E73225D2C226D617070696E6773223A2241414141412C4F41414F432C49';
wwv_flow_api.g_varchar2_table(4) := '414163442C4F41414F432C4B4141652C4741433343442C4F41414F432C49414149432C51414155462C4F41414F432C49414149432C534141572C4741453343442C49414149432C51414151432C4F4141532C53414155432C45414157432C474147744343';
wwv_flow_api.g_varchar2_table(5) := '2C4B41414B432C4D41414D432C4B41444D2C7342414357482C47414535422C49414149492C454141614C2C454141554D2C694241437642432C474141612C4541456A422C4941414B462C454143442C4F41474A2C49414149472C45414344502C4541414F';
wwv_flow_api.g_varchar2_table(6) := '4F2C4B41434E412C4541414F502C4541414F4F2C4B414352502C4541414F512C65414362442C4541414F502C4541414F512C61414161432C4B41414B562C49414770432C4941414B2C49414149572C454141492C45414147412C454141494E2C45414157';
wwv_flow_api.g_varchar2_table(7) := '4F2C4F414151442C4941414B2C43414378432C49414149452C45414157582C4B41414B592C4D41414D68422C514141514F2C454141574D2C47414149562C4541414F612C4D41414F4E2C4741432F44442C45414161412C474141634D2C4541473542582C';
wwv_flow_api.g_varchar2_table(8) := '4B41414B612C47414147432C4F414550642C4B41414B612C47414147432C55414552642C4B41414B592C4D41414D472C614141632C4541437A42662C4B41414B612C47414147472C674241416942222C2266696C65223A227363726970742E6A73227D';
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


