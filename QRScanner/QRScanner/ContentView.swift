//
//  ContentView.swift

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var viewModel = QRScannerViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
        
            switch viewModel.cameraPermission {
            case .restricted, .denied:
                permissionDeniedView
            case .authorized:
                scanningView
            default:
                Color.black.ignoresSafeArea()
                    .onAppear {
                        viewModel.requestPermissionAutorization()
                    }
            }
        }
        .onAppear { viewModel.requestPermissionAutorization() }
        .onDisappear { viewModel.stopSession() }
        .colorScheme(.dark)
    }
    
    
    
    private var scanningView: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreview(session: viewModel.session)
                    .ignoresSafeArea()
                
                let frameSize = min(geo.size.width, geo.size.height) * 0.66
                ViewFinderOverlay(size: frameSize)
                    .ignoresSafeArea()
            }
            
            VStack {
                topBar
                Spacer()
            }
            
            VStack() {
                Spacer()
                if viewModel.scannedResult == nil {
                    Text("Наведите камеру на QR-код")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.bottom, geo.size.height * 0.3)
                }
            }
            
            if let result = viewModel.scannedResult {
                VStack {
                    Spacer()
                    ResultSheet(result: result) {
                        viewModel.resetScan()
                    }
                    .padding(.horizontal, 10)
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.scannedResult != nil)
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("QR Сканер")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Наведите на код")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            
            Button {
                viewModel.toggleTorch()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.torchOn ? .yellow.opacity(0.2) : .white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: viewModel.torchOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(viewModel.torchOn ? .yellow : .white)
                }
            }

        }
        .padding(.horizontal, 20)
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.white.opacity(0.3))
            VStack(spacing: 10) {
                Text("Нет доступа к камере")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Разрешить доступ к камере \nв настройках устройства")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Открыть настройки")
                    .font(.system(size: 16, weight: .semibold))

            }

        }
    }
}

#Preview {
    ContentView()
}
