//
//  TagView.swift
//  IqroQuronKorean
//
//  Created by A'zamjon Abdumuxtorov on 14/03/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 10
    
    init(alignment: Alignment, spacing: CGFloat) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            // If adding this view would exceed the row width, start a new row
            if currentRowWidth + viewSize.width > maxWidth && currentRowWidth > 0 {
                height += currentRowHeight + spacing
                currentRowWidth = viewSize.width + spacing
                currentRowHeight = viewSize.height
            } else {
                // Continue current row
                currentRowWidth += viewSize.width + spacing
                currentRowHeight = max(currentRowHeight, viewSize.height)
            }
        }
        
        // Add the last row's height
        if currentRowHeight > 0 {
            height += currentRowHeight
        }
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        
        let maxWidth = bounds.width
        var rowOrigin = bounds.origin
        var rowHeight: CGFloat = 0
        var rowViews: [LayoutSubviews.Element] = []
        
        func placeRow() {
            guard !rowViews.isEmpty else { return }
            
            // Calculate row width (excluding the last spacing)
            let rowWidth = rowViews.reduce(0) { $0 + $1.sizeThatFits(proposal).width } + spacing * CGFloat(rowViews.count - 1)
            
            // Determine starting x position based on alignment
            var xPos: CGFloat
            switch alignment {
            case .leading:
                xPos = bounds.minX
            case .trailing:
                xPos = bounds.maxX - rowWidth
            default: // center or other alignments
                xPos = bounds.minX + (maxWidth - rowWidth) / 2
            }
            
            // Place each view in the row
            for view in rowViews {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: CGPoint(x: xPos, y: rowOrigin.y), proposal: proposal)
                xPos += viewSize.width + spacing
            }
            
            // Move to next row
            rowOrigin.y += rowHeight + spacing
        }
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            // If adding this view would exceed the row width, place the current row and start a new one
            if rowOrigin.x - bounds.minX + viewSize.width > maxWidth && !rowViews.isEmpty {
                placeRow()
                rowViews = [view]
                rowOrigin.x = bounds.minX + viewSize.width + spacing
                rowHeight = viewSize.height
            } else {
                // Add to current row
                rowViews.append(view)
                rowOrigin.x += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        // Place the last row
        placeRow()
    }
}
