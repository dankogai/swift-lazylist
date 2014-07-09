swift-lazylist
==============

A Haskell-Like Lazy List in [Swift]

[Swift]: https://developer.apple.com/swift/

Synopsis
--------

Infinite list
````swift
let ns = lazylist { (i,_) in i } // infinite list of natural numbers
println(ns.filter{$0 % 2 == 1}.map{$0 * $0}.take(10)) // [1, 9, 25, 49, 81, 121, 169, 225, 289, 361]
println(ns.map{$0 * $0}.filter{$0 % 2 == 1}.take(10)) // [1, 9, 25, 49, 81, 121, 169, 225, 289, 361]
````
Finite list
````swift
let a100 = lazylist(Array(0..<100)) // [0, 1, 2 ... 99]
println(a100.drop(10).take(10))   // [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
println(a100.drop(90).take(20))   // [90, 91, 92, 93, 94, 95, 96, 97, 98, 99] -- only 10
println(a100.drop(100).take(10))  // [] -- no elements left
````
Infinite list with seed array
````swift
let fibs = lazylist([0,1]){ (i,a) in a[i-2] + a[i-1] }
println(fibs.drop(10).take(10)) // [55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181] -- F10...F19
````
