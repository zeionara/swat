// https://blog.devgenius.io/forward-pipe-or-pipe-forward-in-swift-3a6da6f9c000

precedencegroup ForwardPipe {
    associativity: left
}

infix operator |> : ForwardPipe

func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

func |> <T, U>(value: T, function: ((T) throws -> U)) throws -> U {
    return try function(value)
}
