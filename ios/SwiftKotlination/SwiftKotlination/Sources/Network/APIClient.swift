import Foundation

protocol APIClientProtocol {
    func observe(_ request: Request, _ observer: @escaping Observer<Data>)
    func execute(_ request: Request)
}

final class APIClient {
    private var session: URLSessionProtocol
    private(set) var observables: [Request: [Observer<Data>]]
    
    init(session: URLSessionProtocol = URLSession(configuration: URLSessionConfiguration.default), observables: [Request: [Observer<Data>]] = [:]) {
        self.session = session
        self.observables = observables
    }
    
    private func execute(_ request: Request, with observers: [Observer<Data>]) {
        guard
            !observers.isEmpty,
            let urlRequest = build(request) else {
                observers.forEach { $0(.failure(NetworkError.invalidRequest)) }
                return
        }
        
        let dataTask = session.dataTask(with: urlRequest) { data, urlResponse, error in
            guard let data = data else {
                guard let error = error else {
                    observers.forEach { $0(.failure(NetworkError.invalidResponse)) }
                    return
                }
                
                observers.forEach { $0(.failure(error)) }
                return
            }
            
            observers.forEach { $0(.success(data)) }
        }
        
        dataTask.resume()
    }
    
    private func build(_ request: Request) -> URLRequest? {
        guard let url = URL(string: request.url) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.name
        
        switch request.parameters {
        case .body(let data):
            urlRequest.httpBody = data
            
        case .url(let dictionary):
            guard var urlComponents = URLComponents(string: request.url) else {
                return urlRequest
            }
            
            urlComponents.queryItems = dictionary.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
            urlRequest.url = urlComponents.url
        case .none:
            break
        }
        
        return urlRequest
    }
}

extension APIClient: APIClientProtocol {
    func observe(_ request: Request, _ observer: @escaping Observer<Data>) {
        var observers = observables[request] ?? []
        observers.append(observer)
        observables[request] = observers
        
        execute(request, with: [observer])
    }
    
    func execute(_ request: Request) {
        guard let observers = observables[request] else {
            return
        }
        execute(request, with: observers)
    }
}
