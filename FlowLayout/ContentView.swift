//
//  ContentView.swift
//  FlowLayout
//
//  Created by A'zamjon Abdumuxtorov on 10/03/25.
//

import SwiftUI

struct ContentView: View {
    @State var tags:[Tag] = rawTags.compactMap{tag -> Tag? in
        return .init(name: tag)
    }
    var body: some View {
        NavigationStack {
            VStack{
                TagView(alignment: .center, spacing: 0){
                    ForEach($tags) { $tag in
                        Text(tag.name)
                            .font(.headline)
                            .padding(5)
                            .background(tag.isSelected ? Color.blue.opacity(0.2) : Color.clear)
                            .onTapGesture {
                                tag.isSelected.toggle()
                            }
                    }
                    
                }
            }
            .padding()
            .navigationTitle(Text("Layout"))
        }
        
    }
}

#Preview {
    ContentView()
}


struct TagView: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 10
    
    init(alignment: Alignment, spacing: CGFloat) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return .init(width: proposal.width ?? 0, height: proposal.width ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        
        // Group views into rows
        var row: ([LayoutSubviews.Element], CGFloat) = ([], 0)
        var rows: [([LayoutSubviews.Element], CGFloat)] = []
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            if (origin.x + viewSize.width + spacing) > maxWidth {
                // Calculate the total width of the current row
                let rowWidth = origin.x - bounds.minX
                row.1 = rowWidth
                rows.append(row)
                row.0.removeAll()
                
                origin.x = bounds.origin.x
                
                row.0.append(view)
                origin.x += (viewSize.width + spacing)
            } else {
                row.0.append(view)
                origin.x += (viewSize.width + spacing)
            }
        }
        
        if !row.0.isEmpty {
            // Calculate the total width of the last row
            let rowWidth = origin.x - bounds.minX - spacing // Subtract the trailing spacing
            row.1 = rowWidth
            rows.append(row)
        }
        
        origin = bounds.origin
        
        for row in rows {
            // Calculate proper offset based on alignment
            let rowWidth = row.1
            
            switch alignment {
            case .leading:
                origin.x = bounds.minX
            case .trailing:
                origin.x = bounds.maxX - rowWidth
            case .center:
                // Center the row by calculating the proper offset
                let availableSpace = maxWidth - rowWidth
                origin.x = bounds.minX + (availableSpace / 2)
            default:
                origin.x = bounds.minX + (maxWidth - rowWidth) / 2
            }
            
            for view in row.0 {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }
            
            let maxHeight = row.0.compactMap { view -> CGFloat? in
                return view.sizeThatFits(proposal).height
            }.max() ?? 0
            
            origin.y += (maxHeight + spacing)
        }
    }
}

var rawTags: [String] = [
    "SwiftUI","Xcode","iOS","macOS","tvOS","watchOS","UIKit","AppKit","Cocoa","Objective-C","UIKit","AppKit","Cocoa","Objective-C","UIKit","AppKit","Cocoa","Objective-C","UIKit","AppKit","Cocoa","Objective-C"
]


struct Tag:Identifiable{
    var id = UUID().uuidString
    var name:String
    var isSelected:Bool = false
}
