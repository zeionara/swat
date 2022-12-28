struct TrivialConfig: Decodable {
    enum Keys: String, Decodable {
        case foo, bar
    }

    let foo: Int
    let bar: String
}
