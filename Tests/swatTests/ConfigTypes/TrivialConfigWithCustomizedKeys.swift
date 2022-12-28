struct TrivialConfigWithCustomizedKeys: Decodable {
    enum CodingKeys: String, CodingKey {
        case qux = "foo", quux = "bar"
    }

    let qux: Int
    let quux: String
}
