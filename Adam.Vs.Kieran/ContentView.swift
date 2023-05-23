import SwiftUI

struct ContentView: View {
    
    @State private var currentDate = ""
    @State private var currentTime = ""
    @State private var adamScore = 0
    @State private var kieranScore = 0
    @State private var selectedGame = ""
    @State private var scoreTimer: Timer?
        
        
    var body: some View {
        
        VStack {
            Spacer()
            
            Text("Adam")
                .font(.title)
                .foregroundColor(.white)
            
            Text("VS")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 10)
            
            Text("Kieran")
                .font(.title)
                .foregroundColor(.white)
            
            Picker("What Game:", selection: $selectedGame) {
                Text("PvZ Heroes").tag("PvZ Heroes")
                Text("MTG").tag("MTG")
                Text("Chess").tag("Chess")
                Text("Random Bet").tag("Random Bet")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .background(Color.gray)
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            HStack(spacing: 20) {
                Button(action: {
                    sendDataToServer(endpoint: "Adam")
                }) {
                    Text("Adam")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    sendDataToServer(endpoint: "Kieran")
                }) {
                    Text("Kieran")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            Text("\(adamScore) : \(kieranScore)")
            
            Spacer()
            HStack(spacing:10){
                Button(action: {
                    fetchScores()
                }) {
                    Text("Update")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            setCurrentDateTime()
            fetchScores()
        })
    }
    
    func setCurrentDateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let date = dateFormatter.string(from: Date())

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        let time = timeFormatter.string(from: Date())

        currentDate = date
        currentTime = time
    }
    
    
    func sendDataToServer(endpoint: String) {
    guard let url = URL(string: "https://ntek.kieranbendell.dev/win") else {
        print("Invalid URL")
        return
    }
    
    // Create the data to be sent


        print(selectedGame)
    let jsonData: [String: Any] = [
            "date": currentDate,
            "time": currentTime,
            "game": selectedGame,
            "winner": endpoint
        ]
    
    do {
        // Convert the data to JSON
        let requestData = try JSONSerialization.data(withJSONObject: jsonData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set JSON header
        
        let task = URLSession.shared.uploadTask(with: request, from: requestData) { (data, response, error) in
            // Handle the response from the server
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }
        fetchScores()
        task.resume()
    } catch {
        print("Error creating JSON data: \(error)")
    }
}

    func parseScoreResponse(_ response: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: response, options: [])
            
            if let jsonDict = json as? [String: Any],
               let adamScore = jsonDict["adamScore"] as? Int,
               let kieranScore = jsonDict["kieranScore"] as? Int {
                self.adamScore = adamScore
                self.kieranScore = kieranScore
            } else {
                print("Invalid score JSON format")
            }
        } catch {
            print("Error parsing score response: \(error)")
        }
    }

    func fetchScores() {
        let url = URL(string: "https://ntek.kieranbendell.dev/score")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                parseScoreResponse(data)
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&")
        return allowed
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
