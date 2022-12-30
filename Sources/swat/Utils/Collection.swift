precedencegroup ArraySum {
    associativity: left
}

infix operator + : ArraySum

func + <T>(item: T, items: [T]) -> [T] {  // Add item to the beginning of items
    var items = items

    items.insert(item, at: 0)

    return items
}

func prependToEach<T>(_ item: T, _ previousItemGroups: [[T]], _ nextItemGroups: [[T]] = []) -> [[T]] {
    switch previousItemGroups.count {
        case 0:
            return nextItemGroups
        case _:
            let firstItemGroup = previousItemGroups.first!
            let lastItemGroups = Array(previousItemGroups.dropFirst())

        return prependToEach(item, lastItemGroups, nextItemGroups.appending(item + firstItemGroup))
    }
}


func cartesianProduct<T>(_ itemCollections: [T]...) -> [[T]] {
    return cartesianProduct(itemCollections)
}

func cartesianProduct<T>(_ itemCollections: [[T]]) -> [[T]] {
    guard itemCollections.count > 0 else {
        return []
    }

    return itemCollections.reversed().reduce([[]]) { itemGroups, items in 
        items.flatMap{ item in  // For each item get all possible groups then merge into a single array
            prependToEach(item, itemGroups)  // Prepend item to each itemGroup
        }
    }
}
