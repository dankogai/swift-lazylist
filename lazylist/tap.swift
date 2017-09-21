//
//  tap.swift
//  tap
//
//  Created by Dan Kogai on 1/21/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//
import Foundation

open class TAP {
    var tests = 0, runs = [Bool]()
    public init() {}
    public init(tests:Int) {
        self.plan(tests)
    }
    /// sets the number of tests to run. call it before the first test
    open func plan(_ tests:Int) {
        self.tests = tests
        print("1..\(tests)")
    }
    /// ok if `predicate` is true
    @discardableResult open func ok(_ predicate:@autoclosure ()->Bool, _ message:String = "")->Bool {
        let ok = predicate()
        runs.append(ok)
        let ornot = ok ? "" : "not "
        print("\(ornot)ok \(runs.count) - \(message)")
        return ok
    }
    /// ok if `actual` == `expected`
    @discardableResult open func eq<T:Equatable>(_ actual:T?, _ expected:T?, _ message:String = "")->Bool {
        if ok(actual == expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: \(String(describing:expected))")
        return false
    }
    /// ok if arrays are `actual` == `expected`
    @discardableResult open func eq<T:Equatable>(_ actual:[T], _ expected:[T], _ message:String = "")->Bool {
        if ok(actual == expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: \(String(describing:expected))")
        return false
    }
    /// ok if dictionaries are `actual` == `expected`
    @discardableResult open func eq<K,V:Equatable>(_ actual:[K:V], _ expected:[K:V], _ message:String = "")->Bool {
        if ok(actual == expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: \(String(describing:expected))")
        return false
    }
    /// ok if `actual` != `expected`
    @discardableResult open func ne<T:Equatable>(_ actual:T?, _ expected:T?, _ message:String = "")->Bool {
        if ok(actual != expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: anthing but \(String(describing:expected))")
        return false
    }
    /// ok if arrays are `actual` == `expected`
    @discardableResult open func ne<T:Equatable>(_ actual:[T], _ expected:[T], _ message:String = "")->Bool {
        if ok(actual != expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: anthing but \(String(describing:expected))")
        return false
    }
    /// ok if dictionaries are `actual` == `expected`
    @discardableResult open func ne<K,V:Equatable>(_ actual:[K:V], _ expected:[K:V], _ message:String = "")->Bool {
        if ok(actual != expected, message) { return true }
        print("#       got: \(String(describing:actual))")
        print("#  expected: anthing but \(String(describing:expected))")
        return false
    }
    /// checks the test results, print stuff if neccesary,
    /// and `exit()` with code == number of failures
    @discardableResult open func done(dontExit nx:Bool = false)->[Bool] {
        if runs.count == 0 && nx != true {
            print("# no test run!")
            exit(-1)
        }
        if tests == 0 {
            print("1..\(runs.count)")
        }
        else if runs.count != tests {
            print("not ok \(runs.count + 1) - planned to run \(tests) but actually ran \(runs.count)")
            runs.append(false)
            if nx != true { exit(-1) }
        }
        if nx != true {
            let code = min(254, runs.filter{ $0 == false }.count)
            exit(Int32(code))
        }
        return runs
    }
    deinit {
        done(dontExit:true)
    }
}
