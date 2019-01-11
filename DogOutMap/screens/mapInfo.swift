//
//  mapInfo.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/11.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import Foundation

class mapInfo {
    
    var folderName: String = "";
    var folderInfo: [[String]] = Array();
    
    func setFolderName(name: String) {
        self.folderName = name;
    }
    
    func appendPlaceInfo(placeInfo: [String]) {
        self.folderInfo.append(placeInfo);
    }
    
    func getFolderName() -> String {
        return self.folderName;
    }
    
    func getPlaceInfos() -> [[String]] {
        return self.folderInfo;
    }
    
}
