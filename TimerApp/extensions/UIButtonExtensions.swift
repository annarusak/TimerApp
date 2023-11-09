import Foundation
import UIKit

extension UIButton {
    
    func changeAlphaWhenHighlighted() {
        addTarget(self, action: #selector(buttonHighlightedChanged), for: .touchUpInside)
        addTarget(self, action: #selector(buttonHighlightedChanged), for: .touchDown)
        addTarget(self, action: #selector(buttonHighlightedChanged), for: .touchUpOutside)
    }
    
    @objc func buttonHighlightedChanged() {
        struct Holder {
            static var isPressed : Bool = false
        }
        Holder.isPressed = Holder.isPressed ? false : true
        alpha = Holder.isPressed ? 0.5 : 0.7
    }
}
