//
//  File.swift
//
//
//  Created by Shubham on 13/3/20.
//

import Foundation
import web3swift
import BigInt

public class FetchNodeDetails {
    
     var web3 : web3
     var network : EthereumNetwork = EthereumNetwork.MAINNET;
     var proxyAddress : EthereumAddress = EthereumAddress("0x638646503746d5456209e33a2ff5e3226d698bea")!
     var walletAddress : EthereumAddress = EthereumAddress("0x5F7A02a42bF621da3211aCE9c120a47AA5229fBA")!
     let yourContractABI: String = contractABIString
     var contract : web3.web3contract
     var nodeDetails : NodeDetails
    
    
    public init(){
        self.web3 = Web3.InfuraMainnetWeb3()
        self.contract = web3.contract(yourContractABI, at: proxyAddress, abiVersion: 2)!
        self.nodeDetails = NodeDetails() //Initialize with default values
    }
    
    public func getCurrentEpoch() -> Int{
        let contractMethod = "currentEpoch" // Contract method you want to call
        let parameters: [AnyObject] = [] // Parameters for contract method
        let extraData: Data = Data() // Extra data for contract method
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let tx = self.contract.read(
            contractMethod,
            parameters: parameters,
            extraData: extraData,
            transactionOptions: options)!
        
        let result : [String:Any] = try! tx.call() // Explicit Conversion from Any? -> Any -> String -> Int
        let epoch = result.first?.value
        
        // Explicit Conversion from Any? -> Any -> String -> Int
        guard let newEpoch = epoch else { return 0}
        return Int("\(newEpoch)")!
    }
    
    public func getEpochInfo(epoch : Int) throws -> EpochInfo{
        let contractMethod = "getEpochInfo"
        let parameters: [AnyObject] = [18 as AnyObject] // Parameters for contract method
        let extraData: Data = Data() // Extra data for contract method
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        
        let tx = self.contract.read(
            contractMethod,
            parameters: parameters,
            extraData: extraData,
            transactionOptions: options)!
        
        let result = try! tx.call()
        //print(result.keys)
        //print(result["prevEpoch"])
        
        var nodeList = result["nodeList"] as! Array<Encodable> //Unable to convert to Array<String>
        nodeList = nodeList.map{ (el) -> String in
            let address = el as! EthereumAddress
            return String(describing: address.address)
        }
        //print(nodeList)
        
        guard let id = result["id"] else { throw "Casting for id from Any? -> Any failed"}
        guard let n = result["n"] else { throw "Casting for n from Any? -> Any failed"}
        guard let k = result["k"] else { throw "Casting for k from Any? -> Any failed"}
        guard let t = result["t"] else { throw "Casting for t from Any? -> Any failed"}
        guard let prevEpoch = result["prevEpoch"] else { throw "Casting for prevEpoch from Any? -> Any failed"}
        guard let nextEpoch = result["nextEpoch"] else { throw "Casting for nextEpoch from Any? -> Any failed"}
        
        let object = EpochInfo(_id: "\(id)", _n: "\(n)", _k: "\(k)", _t: "\(t)", _nodeList: nodeList as! Array<String>, _prevEpoch: "\(prevEpoch)", _nextEpoch: "\(nextEpoch)")
        return object
    }
    
    public func getNodeEndpoint(nodeEthAddress: String) throws -> NodeInfo {
        let contractMethod = "getNodeDetails"
        let parameters: [AnyObject] = [nodeEthAddress as AnyObject] // Parameters for contract method
        let extraData: Data = Data() // Extra data for contract method
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        //print(extraData)
        
        let tx = self.contract.read(
            contractMethod,
            parameters: parameters,
            extraData: extraData,
            transactionOptions: options)!
        //print(tx)
        
        let result = try! tx.call()
        //print(result.keys)
        //print(result.values)
        
        // Unwraping Any? -> Any
        guard let declaredIp = result["declaredIp"] else { throw "Casting for declaredIp from Any? to Any failed" }
        guard let position = result["position"] else { throw "Casting for position from Any? to Any failed" }
        guard let pubKx = result["pubKx"] else { throw "Casting for pubKx from Any? to Any failed" }
        guard let pubKy = result["pubKy"] else { throw "Casting for pubKy from Any? to Any failed" }
        guard let tmP2PListenAddress = result["tmP2PListenAddress"] else { throw "Casting for tmP2PListenAddress from Any? to Any failed" }
        guard let p2pListenAddress = result["p2pListenAddress"] else { throw "Casting for p2pListenAddress from Any? to Any failed" }

        let object = NodeInfo(_declaredIp: "\(declaredIp)", _position: "\(position)", _pubKx: "\(pubKx)", _pubKy: "\(pubKy)", _tmP2PListenAddress: "\(tmP2PListenAddress)", _p2pListenAddress: "\(p2pListenAddress)")
        return object
    }
    
    public func getNodeDetails() -> NodeDetails{
        if(self.nodeDetails.getUpdated()) { return self.nodeDetails }
        
        let currentEpoch = self.getCurrentEpoch();
        let epochInfo = try! getEpochInfo(epoch: currentEpoch);
        let nodelist = epochInfo.getNodeList();
        
        var torusIndexes:[BigInt] = Array()
        var nodeEndPoints:[NodeInfo] = Array()
        
        for i in 0..<nodelist.count{
            torusIndexes.append(BigInt(i+1))
            nodeEndPoints.append(try! getNodeEndpoint(nodeEthAddress: nodelist[i]))
        }
        // print(torusIndexes, nodeEndPoints)
        
        var updatedEndpoints: Array<String> = Array()
        var updatedNodePub:Array<TorusNodePub> = Array()
        
        for i in 0..<nodeEndPoints.count{
            let endPointElement:NodeInfo = nodeEndPoints[i];
            let endpoint = "https://" + endPointElement.getDeclaredIp().split(separator: ":")[0] + "/jrpc";
            updatedEndpoints.append(endpoint)
            
            let hexPubX = String(BigInt(endPointElement.getPubKx(), radix:10)!, radix:16, uppercase: true)
            let hexPubY = String(BigInt(endPointElement.getPubKy(), radix:10)!, radix:16, uppercase: true)
            updatedNodePub.append(TorusNodePub(_X: hexPubX, _Y: hexPubY))
            //print(hexPubX,hexPubY)
        }
        
        // print(updatedNodePub, updatedEndpoints)
        
        self.nodeDetails.setNodeListAddress(nodeListAddress: self.proxyAddress.address);
        self.nodeDetails.setCurrentEpoch(currentEpoch: String(currentEpoch));
        self.nodeDetails.setTorusNodeEndpoints(torusNodeEndpoints: updatedEndpoints);
        self.nodeDetails.setTorusNodePub(torusNodePub: updatedNodePub);
        self.nodeDetails.setUpdated(updated: true);
        return self.nodeDetails
    }
    
    private func getProxyUrl() -> String{
        return "https://api.infura.io/v1/jsonrpc/" + self.network.rawValue;
    }
}
