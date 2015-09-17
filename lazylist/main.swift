//
//  main.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

let ns = lazylist { $0 }
print(ns.take(10))
print(ns[10])
print(ns.take(10) == LazyLists.UInts.map{Int($0)}.take(10) )
print(LazyLists.Ints[1_000_000_000_000_000_000])
print(LazyLists.Ints.drop(1_000_000).drop(1_000_000)[0])
print(ns.drop(10).take(10))
print(ns[5..<10])
print(ns[5...10])
print(ns.map{$0 * $0}.take(10))
print(ns.filter{$0 % 2 == 0}.take(10))
print(ns.filter{$0 % 2 == 0}.map{$0 * $0}.drop(5).take(5))
print(ns.map{$0 * $0}.filter{$0 % 2 == 0}.drop(5).take(5))
print(ns.map{ "a\($0)" }.take(10))
print(ns.filter{$0 % 2 == 0}.filter{$0 % 3 == 0}.take(5))
for (i,v) in ns.enumerate() {
    if i % 7 != 0 { continue }
    if v > 42 { break }
    print("ns[\(i)] = \(v)")
}
let theAnswer = lazylist { i in 42 }
print(theAnswer.drop(40).take(2))
/// finite list from an array
let p100 = lazylist(Array(0..<100))
print(p100.drop(10).take(10))
print(p100.drop(90).take(20))
print(p100.drop(100).take(10))
print(p100[100])
/// indefinite list -- infinite but with terminator
let m100 = lazylist { $0 < 100 ? -$0 : nil }
print(m100.drop(10).take(10))
print(m100.drop(90).take(20))
print(m100.drop(100).take(10))
print(m100[100])
/// with seed and maker
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
print(fibs.drop(10).take(10))
let primes = lazylist([2,3]) { i, ps in
    for var n = ps[i-1] + 1; true; n++ {
        for p in ps {
            if n % p == 0 { break }
            if p * p > n  { return n }
        }
    }
}
print(primes.take(25))
// indefinite list with seed array
let fact13 = lazylist([1]){ i, a in i < 13 ? i * a[i-1] : nil }
print(fact13.drop(10).take(10))
