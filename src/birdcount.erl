-module(birdcount).

-export([count/0]).

count()->
Dependencies=[inets,crypto,public_key,ssl],
lists:map(fun(App) ->  ok=application:start(App) end, Dependencies),


{_,_,_,_,Photos}=flittr:get_photoset("20721230@N00", "72157649941478239", "f01f8180ef7d445bacc1a95d0d9a7efd" ),
io:format("~p~n", [Photos]),
BirdNames = lists:sort(sets:to_list(sets:from_list(lists:map(fun(X) -> {_,_,_,_,_,Title,_,_,_,_}=X,Title end, Photos)))),
BirdPhotoRefs = build_photorefs(lists:map(fun(BirdName)-> {BirdName, []} end, BirdNames), Photos),

String = lists:flatten(lists:map(fun(Bird) -> io_lib:format("<li class=\"entry\"><span class=\"name\">~s</span></li>~n", [Bird]) end, BirdNames)),
Document = lists:flatten(["<html><body><ol>", String, "</ol></body></html>"]),

file:write_file("/tmp/foo.html", binary:list_to_bin(Document)),

BirdPhotoUrls = lists:map(fun(PhotoRefEntry) -> {BirdName, Refs} = PhotoRefEntry,
			        PhotoUrls=lists:map(fun(Ref) -> flittr:photo_source_url_from_photoref(Ref) end, Refs),
				{BirdName, PhotoUrls} end, BirdPhotoRefs),
io:format("~p~n", [BirdPhotoUrls]),
length(BirdNames).


build_photorefs(Acc, [H|T])->
 {_,_,_,_,_,BirdName,_,_,_,_}=H,
 {BirdName, PhotoList} = lists:keyfind(BirdName, 1, Acc),
 NewAcc = lists:keyreplace(BirdName, 1, Acc, {BirdName, lists:append(PhotoList, [H])}),
 build_photorefs(NewAcc, T);  
build_photorefs(Acc, [])->
 Acc.

