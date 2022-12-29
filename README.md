# swat

[![test](https://github.com/zeionara/swat/actions/workflows/test.yml/badge.svg)](https://github.com/zeionara/swat/actions/workflows/test.yml)
[![language](https://skillicons.dev/icons?i=swift)](https://skillicons.dev)

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

Then, in your code you need to import the package and use it as you want:

```swift
import Swat

try! read(from: "singleFile.yml", in: Path.testAssets)
```

Then you can run the following command to fetch the dependencies and build the app:

```swift
swift build
```

To update the dependencies of your project invoke the following command:

```swift
swift package update
```
