//
//  LApp.swift
//  L
//
//  Created by JPZ3562 on 2021/10/23.
//

import SwiftUI
import Combine
import KeyRun_core

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var handler: Any?

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    func applicationDidFinishLaunching(_ notification: Notification) {
//        let encoder = JSONEncoder()
//        let data = try? encoder.encode(ActionValue.keyOp(KeyOp(keyCode: .h, modifier: [.command], kind: .up)))
//        print(data)
//        window = Window(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .fullSizeContentView, .resizable],
//            backing: .buffered, defer: false)

        if let window = NSApplication.shared.windows.first {
////            window.center()
////            window.setFrameAutosaveName("Main Window")
//
//            window.isOpaque = false
//            window.level = .floating
//            window.isMovableByWindowBackground = true
//            window.isReleasedWhenClosed = false
//            window.standardWindowButton(.closeButton)?.isHidden = true
//            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
//            window.standardWindowButton(.zoomButton)?.isHidden = true
//            window.hasShadow = false
//            window.titleVisibility = .hidden
//

            window.orderOut(nil)

        }

        // Create the SwiftUI view that provides the window contents.
//        let contentView = DemoKeyPressedView()
//            .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
//            .environment(\.keyPublisher, window.keyEventPublisher) // inject publisher

//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)


//        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.keyUp) { e in
//            print(e)
//        }


//        handler = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyUp) { e in
//            let t: NSEvent = e
//            print(t)
//            return t
//        }

        // ポップオーバーの中にSwiftUIビューを設定
        let contentView = ContentView()
        // ポップオーバーを設定
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        // ステータスバーアイコンを設定
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil)
        button.action = #selector(showHidePopover(_:))

        let a = [
            Config(
                keys: [KeyOp(key: Key(keyCode: .h, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .left, modifier: []), kind: .down))
            ),
            Config(
                keys: [KeyOp(key: Key(keyCode: .j, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .down, modifier: []), kind: .down))
            ),
            Config(
                keys: [KeyOp(key: Key(keyCode: .k, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .up, modifier: []), kind: .down))
            ),
            Config(
                keys: [KeyOp(key: Key(keyCode: .l, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .right, modifier: []), kind: .down))
            ),
            Config(
                keys: [KeyOp(key: Key(keyCode: .i, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .left, modifier: [.command]), kind: .down))
            ),
            Config(
                keys: [KeyOp(key: Key(keyCode: .semicolon, modifier: .command), kind: .down)],
                value: .keyOp(KeyOp(key: Key(keyCode: .right, modifier: [.command]), kind: .down))
            ),
        ]

        let tree = TrieTree<KeyOp, Action>()
        a.forEach { config in
            tree.insertValue(for: config.keys, value: config.value)
        }


        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f1, modifier: []), kind: .down)], value: .activateApp("/System/Applications/Utilities/Terminal.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f2, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f3, modifier: []), kind: .down)], value: .activateApp("/Applications/Safari.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f4, modifier: []), kind: .down)], value: .activateApp("/Applications/Numbers.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f5, modifier: []), kind: .down)], value: .activateApp("/Applications/Xcode.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f6, modifier: []), kind: .down)], value: .activateApp("/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f7, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f8, modifier: []), kind: .down)], value: .activateApp("/Applications/Slack.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f9, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f10, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f11, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))
        tree.insertValue(for: [KeyOp(key: Key(keyCode:.f12, modifier: []), kind: .down)], value: .activateApp("/System/Library/CoreServices/Finder.app"))

        let root = "/Users/zedozedo/W/prefs/macOS/zsh/f12"

        (try? FileManager.default.contentsOfDirectory(atPath: root))?.forEach({ s in
            var keys = Array(s).compactMap { c -> KeyOp? in
                guard c.isASCII else { return nil }
                guard let key = Key(c: c) else { return nil }
                return KeyOp(key: key, kind: .down)
            }

            guard !keys.isEmpty else { return }
            keys.insert(KeyOp(key: Key(keyCode: .escape, modifier: []), kind: .down), at: 0)
            print(keys)
            tree.insertValue(for: keys, value: .runScript(root + "/" + s))
        })

        var node = tree.rootNode

        var keyDownOpSet = Set<KeyOp>()
        let ke = KeyEvent()
        ke.handler = { type, event, flags -> Unmanaged<CGEvent>? in
            guard var op = KeyOp(type, event) else { return  Unmanaged.passUnretained(event) }
            print("=====")
            print(op)

            if flags.contains(.maskCommand) {
                op.key.modifier.insert(.command)
            }

            if type == .keyDown {
                if keyDownOpSet.contains(op) {
                    return nil
                }
            }

            if type == .keyUp {
                let downOp = KeyOp(key: op.key, kind: .down)
                if keyDownOpSet.contains(downOp) {
                    keyDownOpSet.remove(downOp)
                    return nil
                }
            }

            if let t = node.child(for: op) {
                print("found in trie")

                node = t
                if t.isLeaf, let action = t.value {
                    node = tree.rootNode

                    switch action {
                        case .keyOp(let keyOp):
                            print(95)
                            event.setIntegerValueField(.keyboardEventKeycode, value: Int64(keyOp.key.keyCode.rawValue))
                            if keyOp.key.modifier.contains(.command) {
                                event.flags.insert(.maskCommand)
                            } else {
                                event.flags.remove(.maskCommand)
                            }
                            if keyOp.key.modifier.contains(.shift) {
                                event.flags.insert(.maskShift)
                            } else {
                                event.flags.remove(.maskShift)
                            }
                            if keyOp.key.modifier.contains(.option) {
                                event.flags.insert(.maskAlternate)
                            } else {
                                event.flags.remove(.maskAlternate)
                            }
                            if keyOp.key.modifier.contains(.control) {
                                event.flags.insert(.maskControl)
                            } else {
                                event.flags.remove(.maskControl)
                            }
//                            keyDownOpSet.insert(op)
                            return Unmanaged.passUnretained(event)
                        case .runScript(let path):
                            DispatchQueue.main.async {
                                run(path) {_ in }
                            }
                            keyDownOpSet.insert(op)
                            return nil
                        case .activateApp(let path):
                            DispatchQueue.main.async {
                                open(URL(fileURLWithPath: path))
                            }
                            keyDownOpSet.insert(op)
                            return nil
                        case .ignore:
                            print(98)
                            return nil
                    }
                }
                print(99)
                keyDownOpSet.insert(op)
                return nil
            } else {
                node = tree.rootNode
            }
            print(100)
            if op.key.keyCode == .jisEisuu {
                if op.kind == .down {
                    if !flags.contains(.maskCommand) {
                        flags.insert(.maskCommand)
                    }
                } else {
                    if flags.contains(.maskCommand) {
                        flags.remove(.maskCommand)
                    }

                    event.setIntegerValueField(.keyboardEventKeycode, value: Int64(KeyCode.commandL.rawValue))
                    return Unmanaged.passUnretained(event)

                }
                return nil
            }

            if flags.contains(.maskCommand) {
                event.flags.insert(.maskCommand)
            }

            return Unmanaged.passUnretained(event)

        }
        ke.start()

        print(1000)
    }
    func applicationWillHide(_ notification: Notification) {
        NSApplication.shared.windows.first?.orderOut(nil)
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc func showHidePopover(_ sender: AnyObject?) {
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self.popover.contentViewController?.view.window?.becomeKey()
        }
    }
}

@main
struct LApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate : AppDelegate

    var body: some Scene {
        Settings {
            EmptyView()
                }
//        WindowGroup {
//            EmptyView()
//        }
    }
}

class Handler {
    func loadConfig() {

    }
}
