function readFile(filename)
    reactions = Dict()
    open(filename) do file
        for line in eachline(file)
            data = [match(r"^ ?(\d+) ([A-Z]+) ?$", entry).captures for entry in split(line, r"=>|,")]
            reactions[data[end][2]] = (parse(Int, data[end][1]), [(x[2], parse(Int,x[1])) for x in data[1:end-1]])
        end
    end
    return reactions
end

function topoSort(reactions, root)
    visited = Set{String}()
    sorted = Array{String,1}()
    topoSortVisit(reactions, root, visited, sorted)
    return sorted
end

function topoSortVisit(reactions, product, visited, sorted)
    if in(product, visited)
        return
    end
    if haskey(reactions, product)
        for ingredient in reactions[product][2]
            topoSortVisit(reactions, ingredient[1], visited, sorted)
        end
    end
    push!(visited, product)
    pushfirst!(sorted, product)
end

function getCounts(reactions, ordered, requiredCount)
    counts = Dict()
    counts[ordered[1]] = requiredCount
    for chemical in ordered[2:end]
        counts[chemical] = 0
    end
    for chemical in ordered
        if haskey(reactions, chemical)
            countProduced, ingredients = reactions[chemical]
            numReactions = Int(ceil(counts[chemical] / countProduced))
            for (ingredient, ingredientCount) in ingredients
                counts[ingredient] += ingredientCount * numReactions
            end
        end
    end
    return counts
end

function findMaxFuel(oreCount, reactions, ordered)
    counts = getCounts(reactions, ordered, 1)
    estimate = Int(ceil(oreCount / counts["ORE"]))
    l = 0
    r = 2 * estimate
    mid = 0
    maxFuel = 0
    while l <= r
        mid = div(l + r, 2)
        curOreCount = getCounts(reactions, ordered, mid)["ORE"]
        if curOreCount > oreCount
            r = mid - 1
        else
            maxFuel = mid
            l = mid + 1
        end
    end
    return maxFuel
end

reactions = readFile("input.txt")
ordered = topoSort(reactions, "FUEL")
counts = getCounts(reactions, ordered, 1)
println(counts["ORE"])

println(findMaxFuel(1000000000000, reactions, ordered))


