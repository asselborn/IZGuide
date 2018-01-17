//
//  NavigationTree.swift
//  InformatikzentrumGuide
//
//  Created by Björn Dählmann on 17.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import Foundation


class TreeNode {
    
    // node name
    var name: String?
    
    // data that saves the area which will be marked as green
    var roomArea = [Float] ()
    
    // parent node
    var parentNode: TreeNode?
    
    // children of the node (rooms wihtin this part of the building)
    var children = [TreeNode] ()

    
    func initNode(name: String, area: [Float]) {
        
        self.name = name
        self.roomArea = area
    }

    func addToParentNode(parent: TreeNode) {
        self.parentNode = parent
        
        parent.children.append(self)
    }

    


    func navigateUser() {
        
//        // check whether user is outside the building
//        if () {
//            // user's position is outside of the building
//            // guide the user to the closest entrance
//
//
//
//        } else {
//            // user is inside the building
//
//
//
//            // check whether user is on the correct floor
//            if () {
//                // user is on correct floor
//                // guide the user to the room
//
//            } else {
//                // user is not on the correct floor
//                // guide the user to the closest stairs
//
//            }
//
//        }
        
    }

}


func createTree() {
    
//    //----------------------------------------------------------------
//    // example tree creation
//
//    // root node = the whole building
//    var IZNode: TreeNode = TreeNode()
//    IZNode.initNode(name: "InformatikZentrum", area: [0, 1, 2, 3])
//
//    var SammelbauNode: TreeNode = TreeNode()
//    SammelbauNode.initNode(name: "Sammelbau", area: [0, 1, 2, 3])
//    SammelbauNode.addToParentNode(parent: IZNode)
//
//    var FachschaftNode: TreeNode = TreeNode()
//    FachschaftNode.initNode(name: "Fachschaft", area: [0, 1, 2, 3])
//    FachschaftNode.addToParentNode(parent: SammelbauNode)
//
//    var MensaNode: TreeNode = TreeNode()
//    MensaNode.initNode(name: "Mensa", area: [0, 1, 2, 3])
//    MensaNode.addToParentNode(parent: IZNode)
//
//    print("elements in IZNode.children")
//    for element in IZNode.children {
//        print(element.name)
//    }
//
//    print("elements in SammelbauNode.children")
//    for element in SammelbauNode.children {
//        print(element.name)
//    }
}
