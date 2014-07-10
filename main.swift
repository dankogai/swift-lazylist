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
println(LazyLists.Ints.drop(1_000_000_000_000_000)[0])
println(ns.drop(10).take(10))
println(ns[5..<10])
println(ns[5...10])
println(ns.map{$0 * $0}.take(10))
println(ns.filter{$0 % 2 == 1}.take(10))
println(ns.filter{$0 % 2 == 1}.map{$0 * $0}.take(10))
println(ns.map{$0 * $0}.filter{$0 % 2 == 1}.take(10))
println(ns.map{ "a\($0)" }.take(10))
/// finite list from an array
let a100 = lazylist(Array(0..<100))
println(a100.drop(10).take(10))
println(a100.drop(90).take(20))
println(a100.drop(100).take(10))
/// with seed and maker
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
println(fibs.drop(10).take(10))
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
