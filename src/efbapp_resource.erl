%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(efbapp_resource).
-export([
    init/1,
    allowed_methods/2,
    content_types_accepted/2,
    accept_form/2,
    process_post/2,
    to_html/2
]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

allowed_methods(ReqData, Ctx) ->
    {['GET','POST'], ReqData, Ctx}.

content_types_accepted(RD, Ctx) ->
    {[{"application/x-www-form-urlencoded", accept_form}], RD, Ctx}.

accept_form(RD, Ctx) ->
    {true, RD, Ctx}.

process_post(ReqData, Ctx) ->
    Body = mochiweb_util:parse_qs(wrq:req_body(ReqData)),
    BodySR = proplists:get_value("signed_request", Body),
    Cookie = wrq:get_cookie_value("fbsr_" ++ efbsr:get_app_id(), ReqData),

    if
        BodySR /= undefined ->
            AccessToken = efbsr:parse(BodySR);
        Cookie /= undefined ->
            AccessToken = efbsr:parse(Cookie);
        true ->
            AccessToken = undefined
    end,
    {Content, _, _} = to_html(ReqData, Ctx, AccessToken),
    {true,
     wrq:set_resp_header(
       "Content-type", "text/html",
       wrq:set_resp_body(Content, ReqData)),
     Ctx}.

to_html(ReqData, State) ->
    AppId = efbsr:get_app_id(),
    Cookie = wrq:get_cookie_value("fbsr_" ++ AppId, ReqData),
    if
        Cookie /= undefined ->
            AccessToken = efbsr:parse(Cookie);
        true ->
            AccessToken = undefined
    end,
    to_html(ReqData, State, AccessToken).

to_html(ReqData, State, Token) ->
    Content = handle_facebook_request(ReqData, Token),
    {Content, ReqData, State}.

% private

render_content(Data) ->
    {ok, Content} = index_dtl:render(Data),
    Content.

handle_facebook_request(ReqData, undefined) ->
    AppJson = facebook:app(efbsr:get_app_id()),
    App = jsonconv:conv(AppJson),
    Data = [
        {app, App},
        {req, [{friends, []}, {photos, []}, {likes, []}, {friends_using_app, []}]},
        {url, "https://efbapp.herokuapp.com"},
        {url_no_scheme, "efbapp.herokuapp.com"}
    ],
    render_content(Data);
handle_facebook_request(ReqData, OAuthToken) ->
    AppJson = facebook:app(efbsr:get_app_id()),
    App = jsonconv:conv(AppJson),
    MeJson = facebook:me(OAuthToken),
    Me = jsonconv:conv(MeJson),
    FriendsJson = facebook:me_friends(OAuthToken),
    Friends = proplists:get_value("data", jsonconv:conv(FriendsJson)),
    PhotosJson = facebook:me_photos(OAuthToken),
    Photos = proplists:get_value("data", jsonconv:conv(PhotosJson)),
    LikesJson = facebook:me_likes(OAuthToken),
    Likes = proplists:get_value("data", jsonconv:conv(LikesJson)),
    FriendsUsingAppJson = facebook:fql("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1", OAuthToken),
    FriendsUsingApp = proplists:get_value("data", jsonconv:conv(FriendsUsingAppJson)),
    Data = [
        {app, App},
        {user, Me},
        {req, [{friends, Friends}, {photos, Photos}, {likes, Likes}, {friends_using_app, FriendsUsingApp}]},
        {url, "https://efbapp.herokuapp.com"},
        {url_no_scheme, "efbapp.herokuapp.com"}
    ],
    render_content(Data).
