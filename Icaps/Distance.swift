//
//  Distance.swift
//  Icaps
//
//  Created by 張百鴻 on 2024/7/6.
//

import Foundation
import Cocoa

class Distance {
    private var distance = 50.0;
    private static var instance: Distance? = nil;
    static public func getDisInstance() -> Distance {
        if instance == nil {
            instance = Distance()
        }
        return instance!
    }
    public func setDistance(dis:CGFloat) {
        distance = dis
    }
    public func getDistance() -> CGFloat {
        return distance
    }
}
