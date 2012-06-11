%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the efbapp application.

-module(efbapp_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for efbapp.
start(_Type, _StartArgs) ->
    efbapp_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for efbapp.
stop(_State) ->
    ok.
