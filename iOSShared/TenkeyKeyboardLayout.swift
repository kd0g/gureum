//
//  TenkeyKeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 6..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class TenkeyKeyboardView: KeyboardView {
    @IBOutlet var numberButton: GRInputButton!
    @IBOutlet var alphabetButton: GRInputButton!
    @IBOutlet var hangeulButton: GRInputButton!

    override var visibleButtons: [GRInputButton] {
        return [self.numberButton, self.alphabetButton, self.hangeulButton, self.nextKeyboardButton, self.deleteButton, self.doneButton, self.shiftButton, self.spaceButton]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.deleteButton.keycode = 0x0e
        self.numberButton = GRInputButton()
        self.numberButton.captionLabel.text = "123"
        self.numberButton.tag = 2
        self.alphabetButton = GRInputButton()
        self.alphabetButton.captionLabel.text = "ABC"
        self.alphabetButton.tag = 1
        self.hangeulButton = GRInputButton()
        self.hangeulButton.captionLabel.text = "한글"
        self.hangeulButton.tag = 0

        self.spaceButton.keycode = 12
        self.spaceButton.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        self.doneButton.keycode = 13

        self.numberButton.addTarget(nil, action: "selectLayout:", forControlEvents: .TouchUpInside)
        self.alphabetButton.addTarget(nil, action: "selectLayout:", forControlEvents: .TouchUpInside)
        self.hangeulButton.addTarget(nil, action: "selectLayout:", forControlEvents: .TouchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TenkeyKeyboardLayout: KeyboardLayout {
    var tenkeyView: TenkeyKeyboardView {
        get {
            return self.view as! TenkeyKeyboardView
        }
    }

    override func themesForTrait(trait: ThemeTraitConfiguration) -> [GRInputButton : ThemeCaptionConfiguration] {
        return [
            self.tenkeyView.numberButton!: trait.tenkeyToggleCaption,
            self.tenkeyView.alphabetButton!: trait.tenkeyAbcCaption,
            self.tenkeyView.hangeulButton!: trait.tenkeyHangeulCaption,
            self.tenkeyView.shiftButton!: trait.tenkeyShiftCaption,
            self.tenkeyView.deleteButton!: trait.tenkeyDeleteCaption,
            self.tenkeyView.nextKeyboardButton!: trait.tenkeyGlobeCaption,
            self.tenkeyView.spaceButton!: trait.tenkeySpaceCaption,
            self.tenkeyView.doneButton!: trait.tenkeyDoneCaption,
        ]
    }

    override class func loadView() -> KeyboardView {
        let view = TenkeyKeyboardView(frame: CGRectMake(0, 0, 200, 100))

        return view
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    func keycodeForPosition(position: GRKeyboardLayoutHelper.Position) -> Int {
        return position.row * 3 + position.column
    }

    override func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        let keycode = self.keycodeForPosition(position)
        let altkey = "key-\(keycode)" // fixme
        let theme1 = trait.tenkeyCaptionForKey(altkey, fallback: trait.tenkeyCaptionForKeyInRow(position.row + 1))
        let title = self.helper(self.helper, titleForPosition: position)
        let theme2 = trait.tenkeyCaptionForKey("key-" + title, fallback: theme1)
        return theme2
    }

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        super.layoutWillLayoutForHelper(helper, forRect: rect)

        let size = rect.size
        for button in [self.tenkeyView.numberButton, self.tenkeyView.alphabetButton, self.tenkeyView.hangeulButton, self.tenkeyView.shiftButton, self.tenkeyView.deleteButton, self.tenkeyView.nextKeyboardButton, self.tenkeyView.doneButton, self.tenkeyView.spaceButton] {
            button.frame.size = CGSizeMake(size.width / 5, size.height / 4)
        }
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        return 3
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize size: CGSize) -> CGFloat {
        return size.height / 4
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 5
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 0:
            return [self.tenkeyView.numberButton]
        case 1:
            return [self.tenkeyView.alphabetButton]
        case 2:
            return [self.tenkeyView.hangeulButton]
        case 3:
            return [self.tenkeyView.nextKeyboardButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        switch row {
        case 0:
            return [self.tenkeyView.deleteButton]
        case 1:
            return [self.tenkeyView.shiftButton]
        case 2:
            return [self.tenkeyView.doneButton]
        case 3:
            return [self.tenkeyView.spaceButton]
        default:
            assert(false)
            return []
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as! GRInputButton
        let keycode = self.keycodeForPosition(position)

        let shift = contains([3, 5, 6, 8, 11], keycode) ? 2 : 1
        button.keycodes = [keycode, keycode + shift * 0x100]
        button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position)
        let titles = "123456789*0#".unicodeScalars
        let key = titles[advance(titles.startIndex, keycode)]
        return "\(Character(key))"
    }
}

class TenKeyAlphabetKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(alphabet_from_tenkey_handler(), alphabet_from_tenkey_handler(), alphabet_tenkey_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.alphabetButton.selected = true
        return view
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position)
        let titles1 = ["@#/&_", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "⇨", ".,?!", ""]
        let titles2 = ["@#/&_", "ABC", "DEF", "GHI", "JKL", "MNO", "PQRS", "TUV", "WXYZ", "⇨", ".,?!", ""]
        let label = (self.view.shiftButton.selected ? titles2 : titles1)[keycode]

        return "\(label)"
    }
}

class TenKeyNumberKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(number_from_tenkey_handler(), number_from_tenkey_handler(), number_tenkey_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.numberButton.selected = true
        return view
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position)
        let titles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "0", "."]
        let titles2 = titles1
        let label = (self.view.shiftButton.selected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}

class CheonjiinKeyboardLayout: TenkeyKeyboardLayout {
    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(cheonjiin_from_tenkey_handler(), cheonjiin_from_tenkey_handler(), cheonjiin_decoder())
    }

    override class func loadView() -> KeyboardView {
        let view = super.loadView() as! TenkeyKeyboardView
        view.hangeulButton.selected = true
        return view
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position)
        let titles1 = ["ㅣ", "·", "ㅡ", "ㄱㅋ", "ㄴㄹ", "ㄷㅌ", "ㅂㅍ", "ㅅㅎ", "ㅈㅊ", "⇨", "ㅇㅁ", ".,?!"]
        let titles2 = ["ㅣ", "· ·", "ㅡ", "ㄲ", "ㄹ", "ㄸ", "ㅃ", "ㅆ", "ㅉ", "⇨", "ㅁ", "?"]
        let label = (self.view.shiftButton.selected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}

class CheonjiinPlusKeyboardLayout: TenkeyKeyboardLayout {

    override func keycodeForPosition(position: GRKeyboardLayoutHelper.Position) -> Int {
        return position.row * 6 + position.column
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        switch row {
            case 0: return 4
            case 1, 2: return 6
            case 3: return 5
            default: return 0
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow row: Int, forSize size: CGSize) -> CGFloat {
        return size.width / 5
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(cheonjiin_from_tenkey_handler(), cheonjiin_from_tenkey_handler(), cheonjiin_decoder())
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        let keycode = self.keycodeForPosition(position)
        let titles1 = ["ㅣ", "·", "··", "ㅡ", "ㄱ", "ㅋ", "ㄴ", "ㄹ", "ㄷ", "ㅌ", "ㅂ", "ㅍ", "ㅅ", "ㅎ", "ㅈ", "ㅊ", "⇨", "ㅇ", "ㅁ", ".,", "?!"]
        let titles2 = titles1
        let label = (self.view.shiftButton.selected ? titles2 : titles1)[keycode]
        return "\(label)"
    }
}
