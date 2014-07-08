//
//  main.swift
//  linkedlist
//
//  Created by Dan Kogai on 6/30/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
let l = list(3, 2, 1, 0)
println(l)
println(l.car)
println(l.cdr?.car)
println(l.cdr?.cdr?.car)
println(l.cdr?.cdr?.cdr?.car)
println(l.cdr?.cdr?.cdr?.cdr?.car)
for e in l { println("iterating: \(e)") }
for i in 0..<l.count {
    println("l[\(i)] == \(l[i])")
}
for i in 0...5 {
    println("l.take(\(i)) == \(l.take(i))")
}
for i in 0...5 {
    println("l.drop(\(i)) == \(l.drop(i))")
}
println(l.append(l))
println(l + l)
println(l.map { $0 * $0 })
println(l.filter { $0 % 2 == 1 })
println(l.filter { $0 < 0 })
println(l.any { $0 % 2 == 1 })
println(l.any { $0 < 0 })
println(l.all { $0 < 10 })
println(l.all { $0 > 1 })
println(list(1.0,2.0,3.0).reduce(1.0, /))
println(list(1.0,2.0,3.0).foldr(1.0, /))
println(l.reverse())
println(l.copy())
println(l.copy() === l)
println(l.copy() == l)
println(l.toArray())
println((l+l).nqsort(<) == (l+l).sort(<))
