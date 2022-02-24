//
//  SharedFunctionsAndConstants.swift
//  DadJokes
//
//  Created by Judy Yu on 2022-02-24.
//

import Foundation

//return the location of the Documents directory for the app
func getDocumentsDirectory() -> URL{
    let paths = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
    
    //return the first path
    return paths[0]
}

//defina a filename that we will write data to in the directory
let savedFavouritesLabel = "savedFavourites"
