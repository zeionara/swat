[![language](https://skillicons.dev/icons?i=swift)](https://skillicons.dev)

# swat

[![test](https://github.com/zeionara/swat/actions/workflows/test.yml/badge.svg)](https://github.com/zeionara/swat/actions/workflows/test.yml)

<p align="center">
    <img src="Assets/Images/logo.png"/>
</p>

**Sw**eet **at**tributes - a compact app for parsing files which specify several system setups in a convenient format and transforming them into a set of separate config files.  
The app is an implementation of idea from [cuco](https://github.com/zeionara/cuco) python package using swift programming language.

# Installation

It is recommended to utilize the swift package manager for installation. To use the app include the following statement in your `dependencies` section of the `Package.swift` like this:

```swift
dependencies: [
    .package(url: "https://github.com/zeionara/swat.git", .branch("master"))
]
```

And in the list of dependencies for your `target` like this:

```swift
dependencies: ["Swat"]
```

Then, in your code you need to import the package and use it as you want (see file `Examples/main.swift`):

```swift
import Swat

struct Bar: ConfigWithDefaultKeys {
    let foo: Int
    let bar: String
}

struct Foo: ConfigWithDefaultKeys, RootConfig {
    let foo: Int
    let bar: Bar

    let name: String
}

let configs: [Foo] = try ConfigFactory().make(
    """
    foo: 17
    bar:
        - foo:
            - 17
            - 19
          bar:
            - qux
            - quux
        - foo:
            - 21
            - 23
          bar:
            - corge
            - grault
    name: demo
    """
)

configs.sorted{ $0.bar.foo < $1.bar.foo }.forEach{ print($0) }
```

The command produces the following output:

```swift
Foo(foo: 17, bar: Examples.Bar(foo: 17, bar: "qux"), name: "demo;bar=[\"bar\": [\"qux\", \"quux\"], \"foo\": [17, 19]];bar.bar=qux;bar.foo=17")
Foo(foo: 17, bar: Examples.Bar(foo: 17, bar: "quux"), name: "demo;bar=[\"bar\": [\"qux\", \"quux\"], \"foo\": [17, 19]];bar.bar=quux;bar.foo=17")
Foo(foo: 17, bar: Examples.Bar(foo: 19, bar: "qux"), name: "demo;bar=[\"bar\": [\"qux\", \"quux\"], \"foo\": [17, 19]];bar.bar=qux;bar.foo=19")
Foo(foo: 17, bar: Examples.Bar(foo: 19, bar: "quux"), name: "demo;bar=[\"bar\": [\"qux\", \"quux\"], \"foo\": [17, 19]];bar.bar=quux;bar.foo=19")
Foo(foo: 17, bar: Examples.Bar(foo: 21, bar: "corge"), name: "demo;bar=[\"foo\": [21, 23], \"bar\": [\"corge\", \"grault\"]];bar.bar=corge;bar.foo=21")
Foo(foo: 17, bar: Examples.Bar(foo: 21, bar: "grault"), name: "demo;bar=[\"foo\": [21, 23], \"bar\": [\"corge\", \"grault\"]];bar.bar=grault;bar.foo=21")
Foo(foo: 17, bar: Examples.Bar(foo: 23, bar: "corge"), name: "demo;bar=[\"foo\": [21, 23], \"bar\": [\"corge\", \"grault\"]];bar.bar=corge;bar.foo=23")
Foo(foo: 17, bar: Examples.Bar(foo: 23, bar: "grault"), name: "demo;bar=[\"foo\": [21, 23], \"bar\": [\"corge\", \"grault\"]];bar.bar=grault;bar.foo=23")
```

Generated config can be saved to local storage:

```swift
try configs.first!.write(to: Path.assets.appendingPathComponent("config.json"))
```

Then you can run the following command to fetch the dependencies and build the app:

```sh
swift build
```

To update the dependencies of your project invoke the following command:

```sh
swift package update
```
