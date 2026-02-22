# SwiftSourceSig 🔐

**TL;DR** — Sign generated Swift files so you can mix **manual editable sections** with **signed generated sections**. Re-run the generator without losing user edits; build fails if generated code is tampered with.

> AI-generated project (with edits).

---

## What it does

- 🔏 **Sign** generated blocks (SHA-512 hash in comments) → any edit breaks the hash
- ✏️ **Manual sections** — regions users can edit; preserved when re-signing
- 🔄 **Placeholders** — `@manual-section-placeholder name` filled from `previousState` when signing
- ✅ **Validate** — CLI or build plugin fails the build if generated code was changed

## Install

```swift
.package(url: "https://github.com/joehinkle11/SwiftSourceSig.git", from: "1.0.0")
// target: .product(name: "SwiftSourceSig"), plugins: [.plugin(name: "SwiftSourceSigLintBuildTool")]
```

## Use

**Library:** `try SwiftSourceSig.signFile(code, previousState: priorSigned)` · `try SwiftSourceSig.validate(code)`  
**CLI:** `SwiftSourceSigLint validate /path/to/file.swift`  
**Plugin:** Validates every Swift file whose path contains `"generated"`.

## Format (short)

`// @generated-section-start <hash>` … code … `// @generated-section-end <hash>`  
`// @manual-section-start <name>` … code … `// @manual-section-end <name>`

Swift 6.2+ · iOS 13 / macOS 10.15+ for CryptoKit. [LICENSE](LICENSE)
