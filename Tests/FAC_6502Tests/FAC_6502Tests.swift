//
//  FAC_6502Tests.swift
//  FAC_6502Tests
//
//  Created by Mike Hall on 07/03/2025.
//

import Testing
@testable import FAC_6502

struct FAC_650xTests {

    @Test func example() async throws {
        #expect(FAC_6502().test1() == 6502)
    }

}
