//
//  LYError.swift
//  LYNetworkingModule
//
//  Created by User on 13/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import UIKit

public enum LYError: Error {

    public enum ParameterInputFailureReason {
        case dataError
        case illegalArgument
    }
}
