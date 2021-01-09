//
//  ImageLoader.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 03.12.2020.
//

import SwiftUI
import Combine


public final class ImageLoader: ObservableObject {
    public let path: String?
    private let imageService: ImageService
    
    public var objectWillChange: AnyPublisher<PlatformImage?, Never> = Publishers.Sequence<[PlatformImage?], Never>(sequence: []).eraseToAnyPublisher()
    
    @Published public var image: PlatformImage? = nil
    
    public var cancellable: AnyCancellable?
        
    public init(service: ImageService,  path: String?) {
       
        self.path = path
        self.imageService = service
        
        self.objectWillChange = $image.handleEvents(receiveSubscription: { [weak self] sub in
            self?.loadImage()
        }, receiveCancel: { [weak self] in
            self?.cancellable?.cancel()
        }).eraseToAnyPublisher()
    }
    
    private func loadImage() {
        guard let path = path, let url = URL(string: path), image == nil else {
            return
        }
        
        cancellable = imageService.load(imageURL: url)
            .map({PlatformImage?($0)})
            .catch{_ in
                return Just<PlatformImage?>(nil).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \ImageLoader.image, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
public extension View{
    func fetchingRemoteImage(from url: String) -> some View {
        ModifiedContent(content: self, modifier: RemoteImageModifier(url: url))
    }
}

public struct RemoteImageModifier: ViewModifier {
    
    @ObservedObject var loader: ImageLoader
    
    init(url: String){
        loader = ImageLoader(service: RealImageService.shared, path: url)
    }
  

    public func body(content: Content) -> some View {
        if let image = loader.image {
            #if os(iOS)
            return Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .eraseToAnyView()
            #endif
            
            #if os(macOS)
            return Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .eraseToAnyView()
            #endif
        }

        return content
            .eraseToAnyView()
    }
//
//    private func fetch() {
//        //let cancelBag = CancelBag()
//        RealImageService.shared.load(imageURL: self.url)
//            .subscribe(on: DispatchQueue.global(qos: .background))
//            .map{$0 as UIImage?}
//            .replaceError(with: nil)
//            .sink{
//            image in
//            fetchedImage = image
//            }//.store(in: cancelBag)
//
//    }
}
/*
public struct LoadableImage<Placeholder>: View where Placeholder: View{
    @ObservedObject var imageLoader: ImageLoader
    let placeholder: ()-> Placeholder
    
    init(url: String, placeholder: @escaping ()-> Placeholder){
        self.imageLoader = ImageLoader(service: RealImageService.shared, path: url)
    }
    var body: some View{
        if let image = imageLoader.image{
            Image(
        }
    }
    
    
}
*/
