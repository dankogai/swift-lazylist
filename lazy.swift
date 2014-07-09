//
//  lazy.swift
//  lazylist
//
//  Created by Dan Kogai on 7/9/14.
//  Copyright (c) 2014 Dan Kogai. All rights reserved.
//
class LazyList<T,U> {
    let maker:((Int,[T])->T)?
    let seed:[T]
    let mapper:(T->U?)
    let offset:Int
    /// lazy, inifite, list.
    init(maker:((Int,[T])->T)?, seed:[T],
        mapper:(T->U?), offset:Int = 0) {
        self.maker  = maker
        self.seed   = seed
        self.mapper = mapper
        self.offset = offset
    }
    /// creates new mapper and installs it
    func map<V>(mapper:U->V?)->LazyList<T,V> {
        return LazyList<T,V>(
            maker:maker,
            seed:seed,
            mapper: { (t:T) -> V? in
                if let u = self.mapper(t) { return mapper(u) }
                else { return nil }
            }
        )
    }
    /// installs filter as a mapper
    /// which returns nil on false
    func filter(judge:U->Bool)->LazyList<T,U> {
        return LazyList<T,U>(
            maker:maker,
            seed:seed,
            mapper: { (t:T)-> U? in
                if let u = self.mapper(t) {
                    return judge(u) ? u : nil
                }
                return nil
            }
        )
    }
    /// returns an array with n elements.
    func take(n:Int) -> [U] {
        var seed = self.seed
        var result:[U] = []
        var idx = 0
        while result.count < n + self.offset {
            if let mk = self.maker { // infinite
                var m = mk(idx++, seed)
                if let v = mapper(m) { result.append(v) }
                if seed.count < idx  { seed.append(m) }
            } else {            // finite
                if seed.count <= idx { break }
                if let v = mapper(seed[idx++]) { result.append(v) }
            }
        }
        if self.offset == 0 {
            return result
        } else {
            return Array(result[self.offset..<result.count])
        }
    }
    /// just take(i+1) and return the last element
    subscript(i:Int)->U {
        return self.take(i+1)[i]
    }
    /// returns a new lazy list with n elements truncated
    /// -- actually it only sets the offset
    func drop(n:Int) -> LazyList<T,U> {
        return LazyList<T,U> (
            maker:  self.maker,
            seed:   self.seed,
            mapper: self.mapper,
            offset: n
        )
    }
    /// b..<e -> drop(b) then take (e-b)
    subscript(r:Range<Int>)->[U] {
        let b = r.startIndex
        let e = r.endIndex
        return self.drop(b).take(e-b)
    }
    func copy()->LazyList<T,U> {
        return LazyList<T,U> (
            maker:  self.maker,
            seed:   self.seed,
            mapper: self.mapper,
            offset: self.offset
        )
    }
}
/// placeholder class
class LazyLists {
    class var Ints:LazyList<Int,Int> {
        return LazyList (
            maker: {(i,_) in i},
            seed:  [Int](),
            mapper:{ $0 }
        )
    }
    class var UInts:LazyList<UInt,UInt> {
        return LazyList (
            maker: {(i,_) in UInt(i)},
            seed:  [UInt](),
            mapper:{ $0 }
        )
    }
}
/// Factory Functions
func lazylist<T>(maker:(Int,[T])->T)->LazyList<T,T> {
    return LazyList (
        maker:maker,
        seed:[T](),
        mapper:{$0}
    )
}
func lazylist<T>(seed:[T])->LazyList<T,T> {
    return LazyList (
        maker:nil,
        seed:seed,
        mapper:{$0}
    )
}
func lazylist<T>(seed:[T], maker:(Int,[T])->T)->LazyList<T,T> {
    return LazyList (
        maker:maker,
        seed:seed,
        mapper:{$0}
    )
}
