import Testing
@testable import SwiftSourceSig

extension String {
    func expectIsSameAfterSigningAgain() throws(SwiftSourceSigError) -> String {
        let signedAgain = try SwiftSourceSig.signFile(self)
        #expect(signedAgain == self)
        return self
    }
}

@Test func `render empty parsed code`() throws {
    let parsed = ParsedCode(sections: [])
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        """)
}

@Test func `render parsed generated code section`() throws {
    let parsed = ParsedCode(
        sections: [
            ParsedCode.Section.generated(
                codeHash: "fake-hash",
                code: "myCode()",
                loc: -1
            )
        ]
    )
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        // @generated-section-start fake-hash
        myCode()
        // @generated-section-end fake-hash
        
        """)
}

@Test func `render parsed two generated code sections`() throws {
    let parsed = ParsedCode(
        sections: [
            ParsedCode.Section.generated(
                codeHash: "fake-hash",
                code: "myCode()",
                loc: -1
            ),
            ParsedCode.Section.generated(
                codeHash: "fake-hash2",
                code: "myCode2()",
                loc: -1
            )
        ]
    )
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        // @generated-section-start fake-hash
        myCode()
        // @generated-section-end fake-hash
        
        // @generated-section-start fake-hash2
        myCode2()
        // @generated-section-end fake-hash2
        
        """)
}

@Test func `render parsed manual code section`() throws {
    let parsed = ParsedCode(
        sections: [
            ParsedCode.Section.manual(
                manualSectionName: "my-manual",
                code: "myCode()"
            )
        ]
    )
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        // @manual-section-start my-manual
        myCode()
        // @manual-section-end my-manual
        
        """)
}

@Test func `render parsed manual code section after synthesis`() throws {
    let parsed = ParsedCode(
        sections: [
            ParsedCode.Section.manualPlaceholder(manualSectionName: "my-manual")
        ]
    )
    let synthesized = try parsed.signAndSynthesize(with: ParsedCode(sections: [
        ParsedCode.Section.manual(
            manualSectionName: "my-manual",
            code: "myCode()"
        )
    ]))
    let rendered = try synthesized.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        // @manual-section-start my-manual
        myCode()
        // @manual-section-end my-manual
        
        """)
}

@Test func `render parsed manual code section after synthesis and sign`() throws {
    let parsed = ParsedCode(
        sections: [
            .unsignedGenerated(code: "signMe()"),
            .manualPlaceholder(manualSectionName: "my-manual")
        ]
    )
    let synthesized = try parsed.signAndSynthesize(with: ParsedCode(sections: [
        ParsedCode.Section.manual(
            manualSectionName: "my-manual",
            code: "myCode()"
        )
    ]))
    let rendered = try synthesized.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        // @generated-section-start 68b5919252c6d86e
        signMe()
        // @generated-section-end 68b5919252c6d86e
        
        // @manual-section-start my-manual
        myCode()
        // @manual-section-end my-manual
        
        """)
}

@Test func `parse empty file`() throws {
    let parsed = try ParsedCode(code: "")
    #expect(parsed.sections.count == 0)
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        """)
}

@Test func `parse empty file with header already present`() throws {
    let parsed = try ParsedCode(code: """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        """)
    #expect(parsed.sections.count == 0)
    let rendered = try parsed.toString()
    #expect(rendered == """
        // Automatically generated
        // Do not edit directly!
        // swift-format-ignore-file
        
        """)
}

@Test func `parse file with header already present (for manual section version)`() throws {
    let parsed = try ParsedCode(code: """
        // This file is automatically generated, but has editable manual sections.
        // Only edit the code between the manual sections.
        // Do NOT edit code outside of the manual sections.
        // Use the SwiftSourceSigLintBuildTool plugin via SPM to verify that generated code is not modified.
        // swift-format-ignore-file
        
        @manual-section-placeholder my-manual
        
        """)
    #expect(parsed.sections.count == 1)
    let rendered = try parsed.toString()
    #expect(rendered == """
        // This file is automatically generated, but has editable manual sections.
        // Only edit the code between the manual sections.
        // Do NOT edit code outside of the manual sections.
        // Use the SwiftSourceSigLintBuildTool plugin via SPM to verify that generated code is not modified.
        // swift-format-ignore-file

        // @manual-section-start my-manual

        // Write your own code here for my-manual

        // @manual-section-end my-manual
        
        """)
}

@Test func `one unsigned generated section`() throws {
    let parsed = try ParsedCode(code: """
        unsignedCode()
        """)
    try #require(parsed.sections.count == 1)
    guard case .unsignedGenerated(let code) = parsed.sections[0] else {
        Issue.record()
        return
    }
    #expect(code == "unsignedCode()")
}
@Test func `signing code`() throws {
    let parsed = try ParsedCode(code: """
        signedCode()
        """)
    try #require(parsed.sections.count == 1)
    guard case .unsignedGenerated(let code) = parsed.sections[0] else {
        Issue.record()
        return
    }
    #expect(code == "signedCode()")
    let signed = parsed.signAndSynthesize(with: ParsedCode(sections: []))
    try #require(signed.sections.count == 1)
    guard case .generated(let codeHash, let code, _) = signed.sections[0] else {
        Issue.record()
        return
    }
    #expect(codeHash == "dccacfd1df463f4f")
    #expect(code == "signedCode()")
}

@Test func `one manual placeholder section`() throws {
    let parsed = try ParsedCode(code: """
        @manual-section-placeholder my-manual
        """)
    try #require(parsed.sections.count == 1)
    guard case .manualPlaceholder(let manualSectionName) = parsed.sections[0] else {
        Issue.record()
        return
    }
    #expect(manualSectionName == "my-manual")
}

@Test func `one signed generated section`() throws {
    let parsed = try ParsedCode(code: """
        // @generated-section-start 68b5919252c6d86e
        signedCode()
        // @generated-section-end 68b5919252c6d86e
        """)
    try #require(parsed.sections.count == 1)
    guard case .generated(let codeHash, let code, _) = parsed.sections[0] else {
        Issue.record()
        return
    }
    #expect(codeHash == "68b5919252c6d86e")
    #expect(code == "signedCode()")
}

@Test func `one manual section`() throws {
    let parsed = try ParsedCode(code: """
        // @manual-section-start my-manual
        myCode()
        // @manual-section-end my-manual
        """)
    try #require(parsed.sections.count == 1)
    guard case .manual(let manualSectionName, let code) = parsed.sections[0] else {
        Issue.record()
        return
    }
    #expect(manualSectionName == "my-manual")
    #expect(code == "myCode()")
}

@Test func `validate correctly signed generated section`() throws {
    try SwiftSourceSig.validate("""
        // @generated-section-start dccacfd1df463f4f
        signedCode()
        // @generated-section-end dccacfd1df463f4f
        """)
}

@Test func `validate badly signed generated section`() throws {
    #expect(throws: SwiftSourceSigError.self) {
        try SwiftSourceSig.validate("""
            // @generated-section-start dccacfd1df463f4f
            signedCode() // different contents
            // @generated-section-end dccacfd1df463f4f
            """)
    }
}

// MARK: - signFile

@Test func `signFile unsigned code returns signed string`() throws {
    let code = """
        signedCode()
        """
    let result = try SwiftSourceSig.signFile(code)
    try SwiftSourceSig.validate(result)
    #expect(result.contains("// @generated-section-start dccacfd1df463f4f"))
    #expect(result.contains("signedCode()"))
    #expect(result.contains("// @generated-section-end dccacfd1df463f4f"))
}

@Test func `signFile with previousState nil uses empty saved`() throws {
    let code = """
        signedCode()
        """
    let result = try SwiftSourceSig.signFile(code, previousState: nil)
    #expect(result.contains("// @generated-section-start dccacfd1df463f4f"))
}

@Test func `signFile with previousState fills manual placeholder`() throws {
    let code = SwiftSourceSig.startingHeader + """
        
        @manual-section-placeholder my-manual
        """
    let previousState = SwiftSourceSig.startingHeader + """
        
        // @manual-section-start my-manual
        myCode()
        // @manual-section-end my-manual
        
        """
    let result = try SwiftSourceSig.signFile(code, previousState: previousState)
    #expect(result.contains("// @manual-section-start my-manual"))
    #expect(result.contains("myCode()"))
    #expect(result.contains("// @manual-section-end my-manual"))
}

@Test func `signFile already signed file returns same`() throws {
    let signed = SwiftSourceSig.startingHeader + """
        
        // @generated-section-start dccacfd1df463f4f
        signedCode()
        // @generated-section-end dccacfd1df463f4f
        
        """
    _ = try signed.expectIsSameAfterSigningAgain()
}
