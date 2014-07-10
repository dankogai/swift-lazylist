//
//  main.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//

let ns = lazylist { $0 }
println(ns.take(10))
println(ns[10])
println(ns.take(10) == LazyLists.UInts.map{Int($0)}.take(10) )
println(LazyLists.Ints[1_000_000_000_000_000_000])
println(LazyLists.Ints.drop(1_000_000).drop(1_000_000)[0])
println(ns.drop(10).take(10))
println(ns[5..<10])
println(ns[5...10])
println(ns.map{$0 * $0}.take(10))
println(ns.filter{$0 % 2 == 1}.take(10))
println(ns.filter{$0 % 2 == 1}.map{$0 * $0}.take(10))
println(ns.map{$0 * $0}.filter{$0 % 2 == 1}.take(10))
println(ns.map{ "a\($0)" }.take(10))
let theAnswer = lazylist { i in 42 }
println(theAnswer.drop(40).take(2))
/// finite list from an array
let p100 = lazylist(Array(0..<100))
println(p100.drop(10).take(10))
println(p100.drop(90).take(20))
println(p100.drop(100).take(10))
println(p100[100])
/// indefinite list -- infinite but with terminator
let m100 = lazylist { $0 < 100 ? -$0 : nil }
println(m100.drop(10).take(10))
println(m100.drop(90).take(20))
println(m100.drop(100).take(10))
println(m100[100])
for (i,v) in enumerate(m100) {
    if i % 10 != 0 { continue }
    if v < -42 { break }
    println("m100[\(i)] = \(v)")
}
/// with seed and maker
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
println(fibs.drop(10).take(10))
let fibs42 = lazylist([0,1]){ i, a in
    i < 42 ? a[i-2] + a[i-1] : nil
}
println(fibs42.drop(40).take(10))
let facts = lazylist([1]) { i, a in i * a[i-1] }
println(facts.take(10))
let primes = lazylist([2,3]) { i, ps in
    for var n = ps[i-1] + 1; true; n++ {
        for p in ps {
            if n % p == 0 { break }
            if p * p > n  { return n }
        }
    }
}
println(primes.take(25))
