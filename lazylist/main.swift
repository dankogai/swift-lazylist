//
//  main.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
let test = TAP()
test.eq(lazylist{$0}.take(10), Array(0..<10), "lazylist{$0}.take(10) == Array(0..<10)")
test.eq(lazylist{$0}.take(10), LazyLists.uints.map{Int($0)}.take(10),
    "lazylist{$0}.take(10) == LazyLists.uints.map{Int($0)}")
let ints = LazyLists.ints
test.eq(ints[1_000_000_000_000_000_000], 1_000_000_000_000_000_000,
    "ints[1_000_000_000_000_000_000] == 1_000_000_000_000_000_000")
test.eq(ints.drop(1_000_000).drop(1_000_000)[0], 2000000,
    "ints.drop(1_000_000).drop(1_000_000)[0] == 2000000")
test.eq(ints.drop(10).take(10), Array(10..<20), "ints.drop(10).take(10) == Array(10..<20)")
test.eq(ints[5..<10], Array(5..<10), "ints[5..<10] == Array(5..<10)")
test.eq(ints[5...10], Array(5...10), "ints[5...10] == Array(5...10)")
test.eq(ints.map{$0*$0}.take(10), (0..<10).map{$0*$0}, "ints.map{$0*$0}.take(10) == (0..<10).map{$0*$0}")
test.eq(ints.filter{$0%2==0}.take(10), (0..<20).filter{$0%2==0},
    "ints.filter{$0%2==0}.take(10) == (0..<20).filter{$0%2==0}")
test.eq(
    ints.filter{$0%2==0}.map{$0*$0}.drop(5).take(5),
    ints.map{$0*$0}.filter{$0%2==0}.drop(5).take(5),
    "ints.filter{$0%2==0}.map{$0*$0} == ints.map{$0*$0}.filter{$0%2==0}"
)
test.eq(ints.map{"a\($0)"}.take(10), (0..<10).map{"a\($0)"},
    "ints.map{\"a\\($0)\"}.take(10) == (0..<10).map{\"a\\($0)\"}")
test.eq(ints.filter{$0%2==0}.filter{$0%3==0}.take(5), (0..<5).map{$0*6},
    "ints.filter{$0%2==0}.filter{$0%3==0}.take(5) == (0..<5).map{$0*6}")
var d = [Int:Int]()
for (i,v) in ints.enumerated() {
    if i % 7 != 0 { continue }
    if v > 42 { break }
    d[i] = v
}
test.eq(d, [0:0,7:7,14:14,21:21,28:28,35:35,42:42], "lazylist is a generator")
let theAnswer = lazylist { i in 42 }
test.eq(theAnswer.drop(40).take(2), [42,42], "lazylist of same elements")
/// finite list from an array
let p100 = lazylist(Array(0..<100))
test.eq(p100.drop(10).take(10), Array(10..<20),  "p100.drop(10).take(10) == Array(10..<20)")
test.eq(p100.drop(90).take(20), Array(90..<100), "p100.drop(10).take(10) == Array(90..<100)")
test.ok(p100.drop(100).take(10).isEmpty, "p100.drop(100).take(10) is empty")
test.ok(p100[100] == nil, "p100[100] is nil")
/// indefinite list -- infinite but with terminator
let m100 = lazylist { $0 < 100 ? -$0 : nil }
test.eq(m100.drop(10).take(10), (10..<20).map{-$0},  "m100.drop(10).take(10) == (10..<20).map{-$0}")
test.eq(m100.drop(90).take(20), (90..<100).map{-$0}, "m100.drop(90).take(20) == (90..<100).map{-$0}")
test.ok(m100.drop(100).take(10).isEmpty, "m100.drop(100).take(10) is empty")
test.ok(m100[100] == nil, "m100[100] is nil")
/// with seed and maker
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
test.eq(fibs.drop(5).take(5), [5, 8, 13, 21, 34], "fibs.drop(5).take(5) == [5, 8, 13, 21, 34]")
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
test.eq(primes.filter{$0 > 100}.take(5), [101, 103, 107, 109, 113],
    "primes.filter{$0 > 100}.take(5) == [101, 103, 107, 109, 113]")
// indefinite list with seed array
let fact13 = lazylist([1]){ i, a in i < 13 ? i * a[i-1] : nil }
test.eq(fact13.drop(10).take(10), [3628800, 39916800, 479001600],
    "fact13.drop(10).take(10) == [3628800, 39916800, 479001600]")
test.done()
