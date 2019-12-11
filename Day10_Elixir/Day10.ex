defmodule Day10 do
    def prepare_input(filename) do
        filename
        |> File.read!
        |> String.split("\n")
        |> Enum.with_index
        |> Enum.flat_map(fn {row, y} -> 
            row
            |> String.graphemes
            |> Enum.with_index
            |> Enum.filter(fn {c, _} -> c == "#" end)
            |> Enum.map(fn
                {"#", x} -> {x, y}
            end)
        end)
    end

    def get_relative_coords({x1, y1}, coords) do
        Enum.filter(coords, fn c -> c != {x1, y1} end)
        |> Enum.map(fn {x2, y2} -> {x2 - x1, y2 - y1} end)
    end

    def find_max_visible(coords) do
        coords
        |> Enum.map(fn coord ->
            get_relative_coords(coord, coords)
            |> Enum.map(fn {dx, dy} ->
                    gcd = Integer.gcd(dx, dy)
                    {div(dx, gcd), div(dy, gcd)}
            end)
            |> Enum.uniq
            |> length
        end)
        |> Enum.zip(coords)
        |> Enum.max
    end

    def flat_zip([]), do: []
    def flat_zip(lists) do
        nonempty = Enum.filter(lists, fn x -> x != [] end)
        heads = Enum.map(nonempty, &hd/1)
        tails = Enum.map(nonempty, &tl/1)
        heads ++ flat_zip(tails)
    end

    def sort_by_angle_distance({cx, cy}, coords) do
        get_relative_coords({cx, cy}, coords)
        |> Enum.map(fn {x, y} ->
            angle = :math.atan2(x, -y)
            {if(angle >= 0, do: angle, else: 2 * :math.pi + angle), x, y}
        end)
        |> Enum.group_by(fn {a, _, _} -> a end, fn {_, x, y} -> {x, y} end)
        |> Map.to_list
        |> Enum.sort_by(fn {a, _} -> a end)
        |> Enum.map(fn {_, cs} ->
            cs |> Enum.sort_by(fn {x, y} -> {abs(x), abs(y)}end)
        end)
        |> flat_zip
        |> Enum.map(fn {x, y} -> {x + cx, y + cy} end)
    end
end

coords = Day10.prepare_input("input.txt")
{maxCount, coord} = Day10.find_max_visible(coords)
IO.puts maxCount

{x, y} = Day10.sort_by_angle_distance(coord, coords) |> Enum.at(199)
IO.puts x * 100 + y
