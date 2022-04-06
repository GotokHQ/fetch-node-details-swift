//
//  File.swift
//  
//
//  Created by Dhruv Jaiswal on 04/04/22.
//

import Foundation
import web3
import BigInt


open class AllNodeDetailsModel:Equatable {
    public static func == (lhs: AllNodeDetailsModel, rhs: AllNodeDetailsModel) -> Bool {
        return lhs.currentEpoch == rhs.currentEpoch && lhs.torusNodeEndpoints == rhs.torusNodeEndpoints && lhs.torusNodePub == rhs.torusNodePub && lhs.currentEpoch == rhs.currentEpoch && lhs.torusIndexes == rhs.torusIndexes && lhs.updated == rhs.updated
    }

    private var currentEpoch : BigUInt?
    private var nodeListAddress : String?
    private var torusNodeEndpoints : Array<String>?
    private var torusIndexes : Array<BigUInt>?
    private var torusNodePub : Array<TorusNodePub>?
    private var updated = false
    
    public init(_currentEpoch : BigUInt, _nodeListAddress : String, _torusNodeEndpoints : Array<String>,  _torusIndexes : Array<BigUInt>, _torusNodePub : Array<TorusNodePub>, _updated : Bool) {
        self.currentEpoch = _currentEpoch;
        self.nodeListAddress = _nodeListAddress;
        self.torusNodeEndpoints = _torusNodeEndpoints;
        self.torusIndexes = _torusIndexes;
        self.torusNodePub = _torusNodePub;
        self.updated = _updated;
    }

    public func getTorusIndexes() -> Array<BigUInt> {
        return self.torusIndexes!;
    }

    public func setTorusIndexes(torusIndexes : Array<BigUInt>){
        self.torusIndexes = torusIndexes;
    }

    public func getUpdated() -> Bool {
        return updated;
    }

    public func setUpdated(updated : Bool){
        self.updated = updated;
    }

    public func getCurrentEpoch() -> BigUInt{
        return currentEpoch!;
    }

    public func setCurrentEpoch( currentEpoch : BigUInt) {
        self.currentEpoch = currentEpoch;
    }

    public func getNodeListAddress() -> String {
        return nodeListAddress!;
    }

    public func setNodeListAddress(nodeListAddress : String) {
        self.nodeListAddress = nodeListAddress;
    }

    public func getTorusNodeEndpoints() ->  Array<String> {
        return torusNodeEndpoints!;
    }

    public func setTorusNodeEndpoints(torusNodeEndpoints : Array<String>) {
        self.torusNodeEndpoints = torusNodeEndpoints;
    }

    public func getTorusNodePub() -> Array<TorusNodePub> {
        return torusNodePub!;
    }

    public func setTorusNodePub(torusNodePub : Array<TorusNodePub>) {
        self.torusNodePub = torusNodePub;
    }
}
