infix 3 |>
fun x |> f = f x

fun println s = print (s ^ "\n")

fun readLines filename = filename |> TextIO.openIn |> TextIO.input |> String.tokens (fn c => c = #"\n") |> List.map (Option.valOf o Int.fromString)

fun partOne masses = masses |> List.map (fn m => m div 3 - 2) |> List.foldl op+ 0

fun partTwo masses = let
    fun getFuel n acc = if n <= 0 then acc else getFuel (n div 3 - 2) (n + acc)
in
    List.map (fn m => getFuel m 0 - m) masses |> List.foldl op+ 0
end

val lines = readLines "input.txt"
val _ = partOne lines |> Int.toString |> println
val _ = partTwo lines |> Int.toString |> println



    