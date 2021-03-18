//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif


public extension ConstraintView {
    
    var snp_left: ConstraintItem { return self.snp.left }
    
    var snp_top: ConstraintItem { return self.snp.top }
    
    var snp_right: ConstraintItem { return self.snp.right }
    
    var snp_bottom: ConstraintItem { return self.snp.bottom }
    
    var snp_leading: ConstraintItem { return self.snp.leading }
    
    var snp_trailing: ConstraintItem { return self.snp.trailing }
    
    var snp_width: ConstraintItem { return self.snp.width }
    
    var snp_height: ConstraintItem { return self.snp.height }
    
    var snp_centerX: ConstraintItem { return self.snp.centerX }
    
    var snp_centerY: ConstraintItem { return self.snp.centerY }
    
    var snp_baseline: ConstraintItem { return self.snp.baseline }
    
    var snp_lastBaseline: ConstraintItem { return self.snp.lastBaseline }
    
    var snp_firstBaseline: ConstraintItem { return self.snp.firstBaseline }
    
    var snp_leftMargin: ConstraintItem { return self.snp.leftMargin }
    
    var snp_topMargin: ConstraintItem { return self.snp.topMargin }
    
    var snp_rightMargin: ConstraintItem { return self.snp.rightMargin }
    
    var snp_bottomMargin: ConstraintItem { return self.snp.bottomMargin }
    
    var snp_leadingMargin: ConstraintItem { return self.snp.leadingMargin }
    
    var snp_trailingMargin: ConstraintItem { return self.snp.trailingMargin }
    
    var snp_centerXWithinMargins: ConstraintItem { return self.snp.centerXWithinMargins }
    
    var snp_centerYWithinMargins: ConstraintItem { return self.snp.centerYWithinMargins }
    
    var snp_edges: ConstraintItem { return self.snp.edges }
    
    var snp_size: ConstraintItem { return self.snp.size }
    
    var snp_center: ConstraintItem { return self.snp.center }
    
    var snp_margins: ConstraintItem { return self.snp.margins }
        
    var snp_centerWithinMargins: ConstraintItem { return self.snp.centerWithinMargins }
    
    func snp_prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        return self.snp.prepareConstraints(closure)
    }
    
    func snp_makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
    }
    
    func snp_remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.remakeConstraints(closure)
    }
    
    func snp_updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.updateConstraints(closure)
    }
    
    func snp_removeConstraints() {
        self.snp.removeConstraints()
    }
    
    var snp: ConstraintViewDSL {
        return ConstraintViewDSL(view: self)
    }
    
}
