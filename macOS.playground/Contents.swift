import Cocoa    // this is an OS X Playground
//: Playground - noun: a place where people can play
let ints = LazyLists.ints
ints[1_000_000_000_000_000_000]
let fibs = lazylist([0,1]){ i, a in a[i-2] + a[i-1] }
fibs[10..<20]
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
let ps = primes.filter{ $0 % 4 == 3 }
ps.take(10)

let r = 0...2
let r2 = 0..<2
