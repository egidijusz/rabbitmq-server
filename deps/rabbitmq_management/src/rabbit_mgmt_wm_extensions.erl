%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Plugin.
%%
%%   The Initial Developer of the Original Code is GoPivotal, Inc.
%%   Copyright (c) 2011-2015 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_mgmt_wm_extensions).

-export([init/1, to_json/2, content_types_provided/2, is_authorized/2]).
-export([finish_request/2, allowed_methods/2]).
-export([encodings_provided/2]).

-include("rabbit_mgmt.hrl").
-include_lib("webmachine/include/webmachine.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------
init(_Config) -> {ok, #context{}}.

finish_request(ReqData, Context) ->
    {ok, rabbit_mgmt_cors:set_headers(ReqData, Context), Context}.

allowed_methods(ReqData, Context) ->
    {['HEAD', 'GET', 'OPTIONS'], ReqData, Context}.

content_types_provided(ReqData, Context) ->
   {[{"application/json", to_json}], ReqData, Context}.

encodings_provided(ReqData, Context) ->
    {[{"identity", fun(X) -> X end},
     {"gzip", fun(X) -> zlib:gzip(X) end}], ReqData, Context}.

to_json(ReqData, Context) ->
    Modules = rabbit_mgmt_dispatcher:modules([]),
    rabbit_mgmt_util:reply(
      [Module:web_ui() || Module <- Modules], ReqData, Context).

is_authorized(ReqData, Context) ->
    rabbit_mgmt_util:is_authorized(ReqData, Context).
