import SwiftUI

struct ContentView: View {
    
    @State private var birdPosition = CGPoint(x: 100, y: 300)
    @State private var pipeOffset: CGFloat = 0
    @State private var topPipeHeight: CGFloat = 0
    @State private var bottomPipeY: CGFloat = 0
    @State private var isGameOver = false
    @State private var score = 0
    @State private var birdVelocity: CGFloat = 0
    @State private var debugInfo = ""
    @State private var currentGapHeight: CGFloat = 300
    
    let gravity: CGFloat = 0.7
    let jumpStrength: CGFloat = -15
    let pipeWidth: CGFloat = 80
    let birdSize: CGFloat = 40
    let minGapHeight: CGFloat = 150
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: pipeWidth, height: topPipeHeight)
                    .position(x: pipeOffset + pipeWidth/2, y: topPipeHeight/2)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: pipeWidth, height: geometry.size.height - bottomPipeY)
                    .position(x: pipeOffset + pipeWidth/2, y: (geometry.size.height + bottomPipeY) / 2)
                
                
                Image("birb")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(.circle)
                    .frame(width: birdSize, height: birdSize)
                    .position(birdPosition)
                
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .position(x: 100, y: 50)
                
                if isGameOver {
                    VStack {
                        Text("Game Over!")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Tap anywhere to restart")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                Text(debugInfo)
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .position(x: geometry.size.width / 2, y: 100)
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        if isGameOver {
                            self.resetGame(geometry: geometry)
                        } else {
                            self.jump()
                        }
                    }
            )
            .onReceive(timer) { _ in
                self.updateGame(geometry: geometry)
            }
            .onAppear {
                self.resetGame(geometry: geometry)
            }
        }
    }
    
    func jump() {
        if !isGameOver {
            birdVelocity = jumpStrength
        }
    }
    
    func resetGame(geometry: GeometryProxy) {
        birdPosition = CGPoint(x: 100, y: geometry.size.height / 2)
        pipeOffset = geometry.size.width
        currentGapHeight = 300
        generateNewPipeHeights(geometry: geometry)
        score = 0
        birdVelocity = 0
        isGameOver = false
    }
    
    func generateNewPipeHeights(geometry: GeometryProxy) {
        let minHeight: CGFloat = 50
        let maxHeight = geometry.size.height - currentGapHeight - minHeight
        topPipeHeight = CGFloat.random(in: minHeight...maxHeight)
        bottomPipeY = topPipeHeight + currentGapHeight
    }
    
    func updateGame(geometry: GeometryProxy) {
        if !isGameOver {
            birdVelocity += gravity
            birdPosition.y = min(max(birdPosition.y + birdVelocity, 0), geometry.size.height - birdSize)
            
            pipeOffset -= 3
            
            if pipeOffset <= -pipeWidth {
                pipeOffset = geometry.size.width
                generateNewPipeHeights(geometry: geometry)
                score += 1
                currentGapHeight = max(300 - CGFloat(score * 5), minGapHeight)
            }
            
            let birdRect = CGRect(x: birdPosition.x - birdSize/2, y: birdPosition.y - birdSize/2, width: birdSize, height: birdSize)
            let topPipeRect = CGRect(x: pipeOffset, y: 0, width: pipeWidth, height: topPipeHeight)
            let bottomPipeRect = CGRect(x: pipeOffset, y: bottomPipeY, width: pipeWidth, height: geometry.size.height - bottomPipeY)
            
            let collidesWithTopPipe = birdRect.intersects(topPipeRect)
            let collidesWithBottomPipe = birdRect.intersects(bottomPipeRect)
            let isOutOfBounds = birdPosition.y <= 0 || birdPosition.y >= geometry.size.height - birdSize
            
            debugInfo = """
            Bird: x=\(Int(birdPosition.x)), y=\(Int(birdPosition.y))
            Pipe: x=\(Int(pipeOffset))
            Gap Height: \(Int(currentGapHeight))
            Collides Top: \(collidesWithTopPipe)
            Collides Bottom: \(collidesWithBottomPipe)
            Out of Bounds: \(isOutOfBounds)
            """
            
            if collidesWithTopPipe || collidesWithBottomPipe || isOutOfBounds {
                isGameOver = true
            }
        }
    }
}
