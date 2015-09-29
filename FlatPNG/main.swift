//
//  main.swift
//  FlatPNG
//
//  Created by Maxim Ananov on 29.09.15.
//  © 2015 Maxim Ananov. All rights reserved.
//

import AppKit

func flatten(url: NSURL) {
    guard let sourceData = try? NSData(contentsOfURL: url, options: .DataReadingUncached),
        source = CGImageSourceCreateWithData(sourceData, nil) else {
            return
    }

    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    let width = CGImageGetWidth(image), height = CGImageGetHeight(image)
    let alpha = CGImageGetAlphaInfo(image)

    guard width * height > 0 && alpha != .NoneSkipLast else {
        return
    }

    let contextOptions = CGImageAlphaInfo.NoneSkipLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
    let context = CGBitmapContextCreate(nil, width, height,
        CGImageGetBitsPerComponent(image), CGImageGetBytesPerRow(image),
        CGImageGetColorSpace(image), contextOptions)

    let rect = NSRect(x: 0, y: 0, width: width, height: height)
    CGContextDrawImage(context, rect, image)
    if let flat = CGBitmapContextCreateImage(context) {
        let bitmap = NSBitmapImageRep(CGImage: flat)
        let data = bitmap.representationUsingType(.NSPNGFileType, properties: [:])
        data?.writeToURL(url, atomically: false)
    }
}

// MARK: - Iterate arguments

var args = NSProcessInfo.processInfo().arguments
args.removeFirst()

for argument in args {
    let url = NSURL(fileURLWithPath: argument)

    if let props = try? url.resourceValuesForKeys([NSURLIsDirectoryKey])
        where props[NSURLIsDirectoryKey] as? Bool == false {
            flatten(url)
    }
}
