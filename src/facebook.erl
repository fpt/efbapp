%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc facebook api wrapper

-module(facebook).
-author('author <author@example.com>').
-export([app/1, oauth_access_token/3, me/1, me_friends/1, me_photos/1, me_likes/1, fql/2]).


app(AppId) ->
    GraphUrl = "https://graph.facebook.com/" ++ AppId,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).

oauth_access_token(AppId, Secret, Code) ->
    GraphUrl = "https://graph.facebook.com/oauth/access_token?client_id=" ++ AppId ++ "&client_secret=" ++ Secret ++ "&redirect_uri=&code=" ++ Code,
    {ok, {{_, 200, _}, _, RespBody}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochiweb_util:parse_qs(RespBody).

me(AccessToken) ->
    GraphUrl = "https://graph.facebook.com/me?access_token=" ++ AccessToken,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).

me_friends(AccessToken) ->
    GraphUrl = "https://graph.facebook.com/me/friends?access_token=" ++ AccessToken,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).

me_photos(AccessToken) ->
    GraphUrl = "https://graph.facebook.com/me/photos?access_token=" ++ AccessToken,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).

me_likes(AccessToken) ->
    GraphUrl = "https://graph.facebook.com/me/likes?access_token=" ++ AccessToken,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).

fql(Query, AccessToken) ->
    GraphUrl = "https://graph.facebook.com/fql?q=" ++ http_uri:encode(Query) ++ "&access_token=" ++ AccessToken,
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {GraphUrl, []}, [], []),
    mochijson2:decode(Body).
