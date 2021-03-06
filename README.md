[![build status](https://secure.travis-ci.org/dankogai/swift-lazylist.png)](http://travis-ci.org/dankogai/swift-lazylist)

# swift-lazylist

A Haskell-Like Lazy List in [Swift].

[Swift]: https://developer.apple.com/swift/

## Synopsis

### Infinite list
````swift
let ns = lazylist { $0 } // infinite list of natural numbers
ns.filter{$0 % 2 == 1}.map{$0 * $0}.take(10) // [1, 9, 25, 49, 81, 121, 169, 225, 289, 361]
ns.map{$0 * $0}.filter{$0 % 2 == 1}.take(10) // [1, 9, 25, 49, 81, 121, 169, 225, 289, 361]
````
### Finite list
````swift
let p100 = lazylist(Array(0..<100)) // [0, 1, 2 ... 99]
p100.drop(10).take(10)   // [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
p100.drop(90).take(20)   // [90, 91, 92, 93, 94, 95, 96, 97, 98, 99] -- only 10
p100.drop(100).take(10)  // [] -- no elements left
````
### Indefinite list -- Lazy list with a terminator
````swift
let m100 = lazylist { $0 < 100 ? -$0 : nil } // [0, -1, -2 ... -99]
m100.drop(10).take(10)  // [-10, -11, -12, -13, -14, -15, -16, -17, -18, -19]
m100.drop(90).take(20)  // [-90, -91, -92, -93, -94, -95, -96, -97, -98, -99]
m100.drop(100).take(10) // []
````
### Infinite list with seed array
````swift
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
fibs.drop(10).take(10) // [55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181] -- F10...F19
````
````swift
let primes = lazylist([2,3]) { i, ps in
    var n = ps[i-1] + 2
    while true {
        for p in ps {
            if n % p == 0 { break }
            if p * p > n  { return n }
        }
        n += 2
    }
}
primes.take(25) // first 25 prime numbers -- primes less than 100
````

### Inifinite list of repeated values

Simple `{ constant }` does not work. Use `{ i in constant }` to make type inference happy.

```
let theAnswer = lazylist { i in 42 }
theAnswer.drop(40).take(2) // [42, 42]
```
### Caution: Enumerate with care

LazyList conforms to the `Sequence` protocol so it supports for-in loop like this:
    
````swift
/// you can enumurate it in for-in loop so long as you `break` it anyhow
for (i,v) in enumerate(ns) {
    if i % 7 != 0 { continue }
    if v > 42 { break }
    print("ns[\(i)] = \(v)")
}
````

However, this is very inefficient unless the list does not depend on the seed array.
Such lists:

0. are constructed without seed array
1. AND  `.filter()` is never applied

The natural number list example above meets that condition until you apply `.filter()`.
If you are not sure avoid using enumurator directly.  Just `take()` to get an ordinary array

## Prerequisite

Swift 4 or better.
