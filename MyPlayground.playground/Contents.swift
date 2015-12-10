//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let bezier2Path = UIBezierPath()
bezier2Path.moveToPoint(CGPointMake(80.5, 103.5))
bezier2Path.addLineToPoint(CGPointMake(150.5, 68.5))
bezier2Path.addLineToPoint(CGPointMake(79.5, 26.5))
UIColor.blackColor().setStroke()
bezier2Path.lineWidth = 1
bezier2Path.stroke()
