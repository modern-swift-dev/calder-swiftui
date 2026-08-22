#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing
import UIKit

@Suite(.serialized) struct ImageUIImageTests {

    // MARK: - UIImage asSwiftUIImage

    @Test func `ui image as swift UI image returns image`() throws {
        let uiImage = try #require(UIImage(systemName: "star"))
        let swiftUIImage = uiImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ui image as swift UI image with filled symbol`() throws {
        let uiImage = try #require(UIImage(systemName: "star.fill"))
        let swiftUIImage = uiImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ui image as swift UI image with custom size`() throws {
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        let uiImage = try #require(UIImage(systemName: "heart", withConfiguration: config))
        let swiftUIImage = uiImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `ui image as swift UI image can be used in view`() throws {
        let uiImage = try #require(UIImage(systemName: "gear"))
        let swiftUIImage = uiImage.asSwiftUIImage
        _ = swiftUIImage
            .resizable()
            .frame(width: 50, height: 50)
    }

    @Test func `ui image as swift UI image with modifiers`() throws {
        let uiImage = try #require(UIImage(systemName: "person"))
        let swiftUIImage = uiImage.asSwiftUIImage
        _ = swiftUIImage
            .renderingMode(.template)
            .foregroundStyle(.blue)
    }

    // MARK: - UIImage creation and conversion

    @Test func `blank UI image conversion`() throws {
        // Create a blank 1x1 image
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let uiImage = try #require(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()

        let swiftUIImage = uiImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    @Test func `colored UI image conversion`() throws {
        // Create a colored 10x10 image
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let uiImage = try #require(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()

        let swiftUIImage = uiImage.asSwiftUIImage
        #expect(type(of: swiftUIImage) == Image.self)
    }

    // MARK: - Image in SwiftUI containers

    @Test func `ui image in V stack`() throws {
        let uiImage = try #require(UIImage(systemName: "star"))
        _ = VStack {
            uiImage.asSwiftUIImage
            Text("Label")
        }
    }

    @Test func `ui image in H stack`() throws {
        let uiImage = try #require(UIImage(systemName: "star"))
        _ = HStack {
            uiImage.asSwiftUIImage
            Text("Label")
        }
    }

    @Test func `ui image in button`() throws {
        let uiImage = try #require(UIImage(systemName: "star"))
        _ = Button {
            // action
        } label: {
            uiImage.asSwiftUIImage
        }
    }

    // MARK: - Multiple system images

    @Test func `multiple system images conversion`() throws {
        let icons = ["star", "heart", "person", "gear", "bell"]
        for iconName in icons {
            let uiImage = try #require(UIImage(systemName: iconName))
            let swiftUIImage = uiImage.asSwiftUIImage
            #expect(type(of: swiftUIImage) == Image.self)
        }
    }
}
#endif

#endif
