## Die, μ-framework to exit swift scripts    <a href='https://circleci.com/gh/daehn/Equal/tree/master' target='_blank'><img src='https://circleci.com/gh/daehn/die.svg?style=svg' height='20px' /></a> [![codecov.io](https://codecov.io/github/daehn/die/coverage.svg?branch=develop)](https://codecov.io/github/daehn/die?branch=develop) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Usage

Calling `die()` or `die("Oh no!")` prints the current callstack, the optional message and calls `exit(EXIT_FAILURE)` afterwards. There also are multiple convenience functions to work with throwing functions:

```swift
dieOnThrow {
    try maybeThrowingFunction(["Please", "don't", "throw"])
}
```

Or using the message parameter to supply a failure reason:

```swift
dieOnThrow("Failed to compute the answer") {
    guard someValue == 42 else { throw SomeError }
}
```

And for working with throwing functions and using the result:

```swift
let contents = dieOnThrow("Unable to get the contents of \(someURL)") {
    let contents = try fm.contentsOfDirectoryAtURL(someURL, includingPropertiesForKeys: nil, options: [])
    // Do more stuff...
    return contents
}
```

Additionaly there are functions to die in case an expression evaluates to nil, or not to nil:
```swift
let result = dieIfNil(someObject.methodThatMightReturnNil())
dieIfNotNil(someObject.methodThatReturnsAnError())
```

As well as for true or false:
```swift
dieIfFalse(fm.isDeletableFileAtPath(sourcePath))

dieOnThrow("Failed to delete \(sourcePath)") {
    try fm.removeItemAtPath(sourcePath)
}

dieIfTrue(fm.fileExistsAtURL(sourceURL))
```


### Installation

Add `github "daehn/die"` to your `Cartfile`
