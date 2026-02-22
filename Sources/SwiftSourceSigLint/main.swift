import SwiftSourceSig
import Foundation

guard CommandLine.arguments.count >= 2 else {
    print("""
        Welcome to SwiftSourceSigLint cli.
        Commands:
        - validate <absoluteFilePath> - validate a single file
        - sign <absoluteFilePath> - sign a single file
        """)
    exit(0)
}
let command = CommandLine.arguments[1]
guard command == "validate" || command == "sign" else {
    print("Invalid command: \(command)")
    exit(1)
}
guard CommandLine.arguments.count >= 3 else {
    print("\(command) command requires 1 argument: <absoluteFilePath>")
    exit(1)
}
let absoluteFilePath = CommandLine.arguments[2]
let url = URL(fileURLWithPath: absoluteFilePath)
let code = try String(contentsOf: url)
switch command {
case "validate":
    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
        do {
            try SwiftSourceSig.validate(code)
        } catch let error as SwiftSourceSigError {
            print("\(absoluteFilePath):\(error.lineOfCodeStart.map { "\($0):" } ?? "") error: \(error.message)")
            exit(1)
        } catch {
            print("\(absoluteFilePath): error: \(error)")
            exit(1)
        }
    } else {
        print("SwiftSourceSig.validate is only available on iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0")
        exit(1)
    }
case "sign":
    print("SwiftSourceSig.signFile is not supported in the CLI yet. Use the Swift API instead.")
    exit(1)
default:
    preconditionFailure("Unreachable: command already validated above")
}
