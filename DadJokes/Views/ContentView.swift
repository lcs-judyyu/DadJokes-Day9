//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    //Detect when app moves between foreground, background, and inactive atates
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentJoke: DadJoke = DadJoke(id: "",
                                       joke: "Knock, knock...",
                                       status: 0)
    
    // This will keep track of our list of favourite jokes
    @State var favourites: [DadJoke] = []   // empty list to start
    
    // This will let us know whether the current exists as a favourite
    @State var currentJokeAddedToFavourites: Bool = false
    
    @State var zoomIn: Bool = false
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            Text(currentJoke.joke)
                .font(.title)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .font(zoomIn ? .largeTitle : .system(size: 60))
                //                      CONDITION                        true   false
                .foregroundColor(currentJokeAddedToFavourites == true ? .red : .secondary)
                .onTapGesture {
                    zoomIn.toggle()
                    
                    // Only add to the list if it is not already there
                    if currentJokeAddedToFavourites == false {
                        
                        // Adds the current joke to the list
                        favourites.append(currentJoke)
                        
                        // Record that we have marked this as a favourite
                        currentJokeAddedToFavourites = true

                    }
                    
                }
            
            Button(action: {
                
                // The Task type allows us to run asynchronous code
                // within a button and have the user interface be updated
                // when the data is ready.
                // Since it is asynchronous, other tasks can run while
                // we wait for the data to come back from the web server.
                Task {
                    // Call the function that will get us a new joke!
                    await loadNewJoke()
                }
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack {
                Text("Favourites")
                    .bold()
                
                Spacer()
            }
            
            // Iterate over the list of favourites
            // As we iterate, each individual favourite is
            // accessible via "currentFavourite"
            List(favourites, id: \.self) { currentFavourite in
                Text(currentFavourite.joke)
            }
            
            Spacer()
                        
        }
        // When the app opens, get a new joke from the web service
        .task {
            
            // Load a joke from the endpoint!
            // We "calling" or "invoking" the function
            // named "loadNewJoke"
            // A term for this is the "call site" of a function
            // What does "await" mean?
            // This just means that we, as the programmer, are aware
            // that this function is asynchronous.
            // Result might come right away, or, take some time to complete.
            // ALSO: Any code below this call will run before the function call completes.
            await loadNewJoke()
            
            print("I tried to load a new joke")
            
            //load favourites from saved file
            loadFavourites()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .active{
                print("Active")
            } else {
                print("Background")
                
                //permanently save the favourite list
                persistFavourites()
            }
        }
        .navigationTitle("icanhazdadjoke?")
        .padding()
    }
    
    // MARK: Functions
    
    // Define the function "loadNewJoke"
    // Teaching our app to do a "new thing"
    //
    // Using the "async" keyword means that this function can potentially
    // be run alongside other tasks that the app needs to do (for example,
    // updating the user interface)
    func loadNewJoke() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
            // Reset the flag that tracks whether the current joke
            // is a favourite
            currentJokeAddedToFavourites = false
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }

    }
    
    //save data permanently
    func persistFavourites() {
        //get a location to save data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        //try to encodr data to JSON
        do {
           let encoder = JSONEncoder()
            
            //configure the encoder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            //Encode the list of favourites
            let data = try encoder.encode(favourites)
            
            //write JSON to a file in the filename location
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            //see the data
            print("Save data to the document directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            print("Unable to write list of favourites to the document directory")
            print("=========")
            print(error.localizedDescription)
        }
    }
    
    func loadFavourites() {
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        do {
            //load raw data
           let data = try Data(contentsOf: filename)
            
            print("Save data to the document directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            
            //decode JSON into Swift native data structures
            //NOTE: [] are used since we load into an array
            favourites = try JSONDecoder().decode([DadJoke].self, from: data)
            
        } catch {
            print("Could not loas the data from the stored JSON file")
            print("=========")
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
