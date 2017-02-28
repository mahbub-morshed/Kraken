# Kraken

[![Build Status](https://travis-ci.org/sabirvirtuoso/Kraken.svg?branch=master)](https://travis-ci.org/sabirvirtuoso/Kraken)
[![Code Climate](https://codeclimate.com/github/sabirvirtuoso/Kraken/badges/gpa.svg)](https://codeclimate.com/github/sabirvirtuoso/Kraken)
[![Version](https://img.shields.io/cocoapods/v/Kraken.svg?style=flat)](http://cocoapods.org/pods/Kraken)
[![License](https://img.shields.io/cocoapods/l/Kraken.svg?style=flat)](http://cocoapods.org/pods/Kraken)
[![Platform](https://img.shields.io/cocoapods/p/Kraken.svg?style=flat)](http://cocoapods.org/pods/Kraken)
[![Swift Version](https://img.shields.io/badge/Swift-3.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)

![Kraken GIF](Kraken.gif)
_Photo courtesy of [www.krakenstudios.blogspot.com](http://krakenstudios.blogspot.com/)_

## Introduction

`Kraken` is a simple **Dependency Injection Container**.

It's aimed to be as simple as possible yet provide rich functionality usual for DI containers on other platforms. It's inspired by [Dip](https://github.com/AliSoftware/Dip) and some other DI containers.

* You start by creating a `Dependency Configurator` for bootstrapping and **registering your dependencies, by associating a _protocol_ or _type_ to either an `implementation type`, an `implementation` or a `factory`**. It is preferrable to call your `Dependency Configurator` from `main.swift`.
* Then you can call `inject(typeToInject)` to **resolve an instance of _protocol_ or _type_** based on the bootstrapping in your `Dependency Configurator`.

## Documentation

`Kraken` is yet to be documented fully but it comes with a sample project that lets you try all its features and become familiar with the API. You can find it in `Trigger.xcworkspace`.

File an issue if you have any question.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Features

- **Scopes**. Kraken supports 3 different scopes (or life cycle strategies): _Prototype_, _Singleton_, _EagerSingleton_;
- **Named definitions**. You can register an `implementation type`, an `implementation` or a `factory` for a protocol or type;
- **Runtime arguments**. You can register factories that accept up to 3 runtime arguments (You can create an extension to increase number of runtime arguments);
- **Multiple definitions**. You can register multiple `implementation types`, `implementations` or `factories` per type or protocol;
- **Circular dependencies**. Kraken can resolve circular dependencies;
- **Auto-wiring**. Kraken can infer your components' dependencies injected in constructor and automatically resolve them.
- **Easy configuration**. No complex container hierarchy, no unneeded functionality;
- **Thread safety**. Registering and resolving components is thread safe;
- **Helpful error messages**. If something can not be resolved at runtime Kraken throws an error that completely describes the issue;

## Basic usage

Create a Dependency Configurator file where you bootstrap your dependencies much like the example shown below:

```swift
import Kraken

class DependencyConfigurator {

  static func bootstrapDependencies() {

    // Register a protocol or type by providing its implementation type
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self, scope: .singleton)

    // Register same protocol or type with different dependency by providing tag that can be either Int, String or Custom Type conforming to DependencyTagConvertible
    Kraken.register(ServiceA.self, tag: CustomTag.One, implementationType: CustomFactory.self, scope: .singleton)

    // Register a protocol or type by providing its implementation
    Kraken.register(ServiceC.self, implementation: dummyImplementation, scope: .singleton)

    // Register a protocol or type having weak property to allow Kraken to handle circular dependencies
    // An example of such protocol (ServiceB) is given below
    Kraken.register(ServiceB.self, implementationType: ServiceBImpl.self, scope: .singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceB = resolvedInstance as! ServiceBImpl
      serviceB.serviceA = injectWeak(ServiceA.self).value as! ServiceAImpl
    }

    // Register a protocol or type having runtime arguments to be injected in constructor
    Kraken.register(ServiceD.self) {
      ServiceDImpl(host: $0, port: $1, serviceB: inject(ServiceB.self)) as ServiceD
    }

    // Register generic protocols or types
    Kraken.register(GenericDataSource<ServiceAImpl>.self, implementationType: ServiceAImplDataSource.self, scope: .eagerSingleton)

    // Register a protocol or type whose components' dependencies are injected automatically by container
    Kraken.register(ServiceE.self) {
      ServiceEImpl(serviceA: $0, serviceB: $1, serviceC: $2)
    }
  }
}

```

```swift
import Kraken

protocol ServiceB: Injectable {

  weak var serviceA: ServiceA? { get set }

  var serviceC: ServiceC { get set }

  var serviceBImplDataSource: GenericDataSource<ServiceBImpl> { get set }

  func myCompanyB() -> String

}

```

It is worth mentioning that the protocols or types which are registered must conform to the `Injectable` protocol in order to be resolved by the container as shown in the example below:

```swift
import Kraken

protocol ServiceA: Injectable {

  func myCompanyA() -> String

}

```

If you want to register multiple dependencies per type or protocol, you have to register with tag conforming to `DependencyTagConvertible`. You can declare a custom enum for this as shown below:

```swift
import Kraken

enum CustomTag: Int, DependencyTagConvertible {
    case One = 1, Two
}

```

After bootstrapping dependencies, its injection is as simple as invoking `inject()` which can be of different types as shown below:

```swift
import Kraken

// Inject dependency whose implementation was registered
let serviceC: ServiceC = inject(ServiceC.self)

// Inject dependency whose implementation type was registered
let serviceA: ServiceA = inject(ServiceA.self)

// Inject dependency whose implementation type was registered with tag
let serviceA: ServiceA = inject(ServiceA.self, tag: CustomTag.One)

// Inject dependency providing runtime arguments
let serviceD: ServiceD = inject(ServiceD.self, withArguments: "localhost", 8080)

// Inject dependency which is resolved by container through AutoWiring
let serviceE: ServiceE = inject(ServiceE.self)

```

## Installation

Kraken is built with Swift 3.0.

#### CocoaPods

Kraken is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Kraken', '1.5.0'
```

#### Manually
1. Download and drop ```/Kraken``` folder in your project.
2. Congratulations!

## Author

Syed Sabir Salman-Al-Musawi, sabirvirtuoso@gmail.com

I'd also like to thank [**Sharafat Ibn Mollah Mosharraf**](sharafat_8271@yahoo.co.uk) for his big support during the development phase.

**Kraken** is available under the **MIT license**. See the `LICENSE` file for more info.

The GIF at the top of this `README.md` is from [www.krakenstudios.blogspot.com](http://krakenstudios.blogspot.com/)
