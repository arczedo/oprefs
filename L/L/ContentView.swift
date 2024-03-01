//
//  ContentView.swift
//  L
//
//  Created by JPZ3562 on 2021/10/23.
//

import SwiftUI
import Carbon

extension CGEventFlags {
    var modifier: KeyModifier {
        var a: KeyModifier = []
        if contains(.maskCommand) {
            a.insert(.command)
        }
        if contains(.maskShift) {
            a.insert(.shift)
        }
        if contains(.maskControl) {
            a.insert(.control)
        }
        if contains(.maskAlternate) {
            a.insert(.option)
        }
        return a
    }
}

struct KeyModifier: OptionSet, Codable, Hashable, CustomDebugStringConvertible {
    let rawValue: Int

    static let command = KeyModifier(rawValue: 1 << 0)
    static let shift = KeyModifier(rawValue: 1 << 1)
    static let option = KeyModifier(rawValue: 1 << 2)
    static let control = KeyModifier(rawValue: 1 << 3)

    var debugDescription: String {
        [KeyModifier.command, .shift, .control, .option].compactMap {
            contains($0) ? $0.title : nil
        }.joined(separator: "|")
    }

    var title: String {
        switch self {
            case .command: return KeyCode.commandL.hu
            case .shift: return KeyCode.shiftL.hu
            case .option: return KeyCode.optionL.hu
            case .control: return KeyCode.controlL.hu
            default: return ""
        }
    }
}

struct KeyOp: Codable, Hashable {
    enum Kind: Int, Codable {
        case up, down
    }

    var key: Key
    var kind: Kind

    init(key: Key, kind: Kind) {
        self.key = key
        self.kind = kind
    }

    init?(_ type: CGEventType, _ event: CGEvent) {
        switch type {
            case .keyUp:
                kind = .up
            case .keyDown:
                kind = .down
            default:
                return nil
        }

        guard let k = KeyCode(rawValue: event.keyCode) else { return nil }
        key = Key(keyCode: k, modifier: event.flags.modifier)
    }

}

extension KeyOp: CustomDebugStringConvertible {
    var debugDescription: String {
        key.modifier.debugDescription + ":" +
        key.keyCode.title + ":" + String(describing: kind)
    }
}

struct Key: Codable, Hashable {
    var keyCode: KeyCode
    var modifier: KeyModifier
}



enum Action: Codable {
    case keyOp(KeyOp)
    case activateApp(String)
    case runScript(String)
    case ignore
}

struct Config: Codable {
    var keys: [KeyOp]
    var value: Action
}

class KeyOPAction {
    var keyOp: KeyOp
    init(keyOp: KeyOp) {
        self.keyOp = keyOp
    }
    func run() -> Unmanaged<CGEvent>? {
        nil
    }
}


struct Conf: Codable {
    var seqence : [KeyOp]
    var action: Action
}

struct ContentView: View {

    @State var on = true

    @State var selection: KeyCode = .commandR
    @State var text = "4"
    var body: some View {
        ZStack {
            Color.black
            VStack {
                Toggle("Use eiji as Command", isOn: $on)
                    .toggleStyle(.checkbox)

                HStack{
                    Picker("", selection: $selection) {
                        ForEach(KeyCode.allCases) { key in
                            Text(key.title)
                                .tag(key)
                        }
                    }
                    TextField("", text: $text)
                }
                Text("selected: \(selection.hu)")

                Button {

                } label: {
                    Image(nsImage: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)! )
                }



//                KeyEventHandlingView()
//                    .frame(height:20)
//                    .background(Color.white)
//                Spacer()
            }
            .onAppear {
//                run("w") {
//                    print($0)
//                }
            }
        }
    }


}

struct KeyEventHandlingView: NSViewRepresentable {
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            if let t = event.characters {
                run(t) {
                    print($0)
                    NSApplication.shared.hide(nil)
                }
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
