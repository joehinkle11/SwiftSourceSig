import Foundation
import PackagePlugin

@main
struct SwiftSourceSigLintBuildTool: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: any Target) async throws -> [Command] {
        guard let sourceModule = target as? SourceModuleTarget else {
            return []
        }
        let executable = try context.tool(named: "SwiftSourceSigLint")
        return sourceModule.sourceFiles.compactMap { sourceFile in
            guard sourceFile.type == .source else {
                return nil
            }
            guard sourceFile.url.pathExtension == "swift" else {
                return nil
            }
            guard sourceFile.url.path().contains("generated") else {
                return nil
            }
            return .buildCommand(
                displayName: "Linting generate file '\(sourceFile.url.lastPathComponent)'",
                executable: executable.url,
                arguments: ["validate", sourceFile.url.path()],
                environment: [:],
                inputFiles: [sourceFile.url],
                outputFiles: []
            )
        }
    }
}
