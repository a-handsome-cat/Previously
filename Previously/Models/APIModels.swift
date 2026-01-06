import Foundation

struct APIResultResponse<T: Decodable>: Decodable {
    let result: T
}

struct APIPhotosResponse: Codable {
    let photos: [APIPhotoModel]
}

struct APIPhotoModel: Codable {
    let file: String
    let title: String
    let geo: [Double]
    let year: Int
}
