-module(day8).
-export([run/0]).

split_by_count(Digits, Count) -> split_by_count(Digits, Count, []).
split_by_count([], _, Result) -> lists:reverse(Result);
split_by_count(Digits, Count, Result) ->
    {Layer, Remaining} = lists:split(Count, Digits),
    split_by_count(Remaining, Count, [Layer | Result]).

count_digits(_, []) -> 0;
count_digits(Digit, [D|Ds]) ->
    count_digits(Digit, Ds) + if
        D == Digit -> 1;
        true -> 0
    end.

find_fewest_zeros([]) -> {notfound, unknown};
find_fewest_zeros([Layer|Layers]) ->
    CurCount = count_digits(0, Layer),
    {MinLayer, MinCount} = find_fewest_zeros(Layers),
    if
        MinLayer == notfound ; CurCount < MinCount -> {Layer, CurCount};
        true -> {MinLayer, MinCount}
    end.

apply_layer(Layer, init) -> Layer;
apply_layer([], []) -> [];
apply_layer([2|Row], [CurPixel|Remaining]) -> [CurPixel|apply_layer(Row, Remaining)];
apply_layer([TopPixel|Row], [_|Remaining]) -> [TopPixel|apply_layer(Row, Remaining)].

print_image(Image, Width) ->
    Characters = lists:map(fun(C) -> case C of
        0 -> " ";
        1 -> "#"
    end end, Image),
    Rows = split_by_count(Characters, Width),
    lists:foreach(fun(Row) -> io:format("~s\n", [Row]) end, Rows).

run() ->
    Width = 25,
    Height = 6,
    {ok, FileData} = file:read_file('input.txt'),
    FileContent = binary_to_list(FileData),
    Digits = lists:map(fun(C) -> C - 48 end, FileContent),
    Layers = split_by_count(Digits, Width * Height),

    {LeastZeros, _} = find_fewest_zeros(Layers),
    Part1 = count_digits(1, LeastZeros) * count_digits(2, LeastZeros),
    io:fwrite("~w\n", [Part1]),

    Image = lists:foldr(fun(Layer, Accum) -> apply_layer(Layer, Accum) end, init, Layers),
    print_image(Image, Width).