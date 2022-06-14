import SwiftUI
import MetalSnapshotTaker

struct ImageData: Equatable{
    let id: Int
    let image: Image
    static func ==(lhs: ImageData, rhs: ImageData)->Bool{
        lhs.id == rhs.id
    }
}

struct ContentView: View {
    
    @State var uniforms = Uniforms()
    
    @State var images: [ImageData] = []
    
    let snapshotDelegate = MetalSnapshotTaker(
        size: CGSize(width: 1000, height: 1000))
    
    func addImage(_ image: Image?){
        if let image = image, images.count<10{
            let imData = ImageData(id: (images.last?.id ?? 0)+1, 
                                   image: image)
            withAnimation{ images.append(imData) }
        }
    }
    
    var body: some View{
        VStack{ 
            MetalView(uniforms: $uniforms,
                      snapshotTaker: snapshotDelegate)
            .frame(width: 200, height: 200)
            .padding()
            Spacer()
            HStack{
                ForEach(images, id: \.id){ imData in
                    imData.image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture(count: 2) { 
                            images.removeAll(where: {$0.id == imData.id})
                        }
                }
            }.animation(.default, value: images)
            Spacer()
            Button { 
                let image: Image? = snapshotDelegate.take()
                addImage(image)
            } label: { 
                Text("Take Snapshot")
            }
            .padding()
        }
        .onAppear(){
            uniforms.time = 0
        }
    }
}
