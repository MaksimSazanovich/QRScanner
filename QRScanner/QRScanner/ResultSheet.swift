// ResultSheet.swift

import SwiftUI

struct ResultSheet: View {
    let result: QRResult
    var onReset: () -> Void
    
    @State private var appeared = false
    @State private var copied  = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 48, height: 48)
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(iconColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(typeLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text("Данные получены")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Divider()
                .background(.white.opacity(0.2))
                .padding(.vertical, 16)
            ScrollView {
                Text(result.rawString)
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxHeight: 120)
            Spacer()
                .frame(height: 20)
            
            VStack {
                mainButton
                HStack {
                    copyButton
                    scanAgainButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.black.opacity(0.9))
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                })
        )
        .offset(y: appeared ? 0 : 300)
        .onAppear {
            withAnimation(.spring(response: 0.5, blendDuration: 0.8)) {
                appeared = true
            }
        }
    }
    
    @ViewBuilder
    private var mainButton: some View {
        switch result {
        case .url(let url):
            Button {
                UIApplication.shared.open(url)
            } label: {
                Label("Открыть ссылку", systemImage: "safari.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        case .text:
            Button {
                let activityController = UIActivityViewController(activityItems: [result.rawString], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let vc = scene.windows.first?.rootViewController {
                        vc.present(activityController, animated: true)
                    }
            } label: {
                Label("Поделиться текстом", systemImage: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        }
    }
    
    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = result.rawString
            withAnimation { copied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { copied = false }
            }
        } label: {
            Label(copied ? "Скопировано" : "Копировать", systemImage: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var scanAgainButton: some View {
        Button {
            onReset()
        } label: {
            Label("Сканировать ещё ", systemImage: "qrcode.viewfinder")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var iconName: String {
        switch result {
        case .url: return "link"
        case .text: return "text.alignleft"
        }
    }
    
    private var typeLabel: String {
        switch result {
        case .url: return "Ссылка"
        case .text: return "Текст"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch result {
        case .url: return .cyan.opacity(0.2)
        case .text: return .purple.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        switch result {
        case .url: return .cyan
        case .text: return .purple
        }
    }
}
