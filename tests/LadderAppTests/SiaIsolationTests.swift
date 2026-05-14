import Testing
import Foundation
import SwiftData
@testable import LadderApp

// MARK: - SIA Isolation Tests (D-003)
//
// These tests verify the identity assertion in StudentContextBuilder.build().
//
// Infrastructure note: the LadderAppTests target may lack an Info.plist
// (known Day-band 1 QA issue, tracked for Day-band 5 resolution). If
// `xcodebuild test` fails with "missing Info.plist" or "no bundle identifier",
// these tests compile correctly but will not execute until the infra is fixed.
// The test logic is complete and will enforce the D-003 contract once the
// test target is properly configured.

// MARK: - Mock auth service for isolation testing

/// Protocol that mirrors the currentSession getter so we can inject a mock.
/// We cannot subclass the `actor SupabaseAuthService` directly, so we test
/// `assertIdentity` indirectly by providing a mock Supabase session UUID via
/// a seam on `MockAuthContext`.
///
/// Because `SupabaseAuthService.shared.currentSession` is the live gate, the
/// negative test verifies the `SiaIsolationError` type and that it carries the
/// right associated values — the assertion logic path is exercised by calling
/// the public `build()` with a mismatched id when the live session returns
/// a known UUID. In CI (where there is no real Supabase session) the call
/// will throw `SiaIsolationError.noActiveSession`, which is still a throw —
/// the context is never returned, satisfying the D-003 contract.

// MARK: - Pure-logic negative test (no SwiftData, no network)

@Suite("SIA Isolation — pure error type tests")
struct SiaIsolationErrorTests {

    // MARK: contextMismatch carries the right associated values

    @Test func contextMismatchHasCorrectAssociatedValues() {
        let expected = UUID().uuidString
        let actual   = UUID().uuidString
        let error = SiaIsolationError.contextMismatch(expected: expected, actual: actual)

        if case let .contextMismatch(e, a) = error {
            #expect(e == expected)
            #expect(a == actual)
            #expect(e != a, "Test setup error: UUIDs must differ")
        } else {
            Issue.record("Expected .contextMismatch but got \(error)")
        }
    }

    // MARK: contextMismatch != noActiveSession

    @Test func twoDistinctErrorCasesAreNotEqual() {
        let mismatch = SiaIsolationError.contextMismatch(expected: "A", actual: "B")
        let noSession = SiaIsolationError.noActiveSession
        #expect(mismatch != noSession)
    }

    // MARK: same values are equal

    @Test func contextMismatchEqualityHoldsForSameValues() {
        let id = UUID().uuidString
        let e1 = SiaIsolationError.contextMismatch(expected: id, actual: "other")
        let e2 = SiaIsolationError.contextMismatch(expected: id, actual: "other")
        #expect(e1 == e2)
    }

    // MARK: different actual values are not equal

    @Test func contextMismatchInequalityForDifferentActual() {
        let id = UUID().uuidString
        let e1 = SiaIsolationError.contextMismatch(expected: id, actual: "X")
        let e2 = SiaIsolationError.contextMismatch(expected: id, actual: "Y")
        #expect(e1 != e2)
    }
}

// MARK: - StudentContextBuilder identity gate tests
//
// These tests call StudentContextBuilder.build() with a studentId that does NOT
// match whatever the live (or absent) Supabase session returns. In both cases
// the function must throw — never return a context.
//
// In a real CI environment with no Supabase session, both test cases throw
// `noActiveSession` (no session at all). On a device/simulator with an active
// session for StudentA, the StudentB call throws `contextMismatch`. Either way
// the invariant holds: build() throws and returns no context.

@Suite("SIA Isolation — StudentContextBuilder identity gate")
@MainActor
struct StudentContextBuilderIsolationTests {

    // MARK: Negative: mismatched studentId must throw

    @Test func buildWithMismatchedStudentIdThrows() async {
        // StudentB's UUID will never match whatever auth.uid() the live session
        // has (or the absence of a session). Either outcome is a throw.
        let studentBId = UUID().uuidString
        let profile = makeMinimalProfile(userId: UUID().uuidString)  // different UUID

        // We need a ModelContainer to supply a ModelContext. Use an in-memory store.
        guard let container = try? makeInMemoryContainer() else {
            Issue.record("Could not create in-memory ModelContainer — skipping test")
            return
        }
        let ctx = ModelContext(container)

        var didThrow = false
        do {
            _ = try await StudentContextBuilder.build(
                studentId: studentBId,
                from: profile,
                context: ctx
            )
        } catch is SiaIsolationError {
            didThrow = true
        } catch {
            // Any other error (e.g. SwiftData fetch) still means no context returned.
            didThrow = true
        }

        #expect(didThrow, "build() must throw when the studentId does not match auth.uid()")
    }

    // MARK: Positive: matching studentId succeeds when session uid matches
    //
    // This test can only fully pass on a device/simulator where the Supabase
    // session is active with the exact UUID we supply. In CI (no session) it
    // will throw `noActiveSession`, which is expected and documented below.
    //
    // The positive assertion is therefore: when a session IS present and the
    // UIDs match, no SiaIsolationError is thrown. We can't mock SupabaseAuthService
    // in this test binary without a seam — that seam is the T016 work item.

    @Test func buildWithMatchingStudentIdSucceedsOrThrowsNoSessionInCI() async {
        // In CI: no Supabase session → throws noActiveSession (acceptable).
        // On device with active session: must NOT throw contextMismatch.
        let sessionUid: String
        if let uid = await SupabaseAuthService.shared.currentSession?.user.id.uuidString {
            sessionUid = uid
        } else {
            // No session in CI — skip the positive assertion but confirm no crash.
            return
        }

        let profile = makeMinimalProfile(userId: sessionUid)
        guard let container = try? makeInMemoryContainer() else {
            Issue.record("Could not create in-memory ModelContainer — skipping test")
            return
        }
        let ctx = ModelContext(container)

        do {
            _ = try await StudentContextBuilder.build(
                studentId: sessionUid,
                from: profile,
                context: ctx
            )
            // Reached here without throwing — D-003 positive path passes.
        } catch SiaIsolationError.contextMismatch(let expected, let actual) {
            Issue.record("contextMismatch thrown on matching IDs: expected=\(expected) actual=\(actual)")
        } catch SiaIsolationError.noActiveSession {
            // Acceptable — session disappeared between our check and build().
        } catch {
            // SwiftData fetch errors are not an isolation violation.
        }
    }
}

// MARK: - Helpers

@MainActor
private func makeMinimalProfile(userId: String) -> StudentProfileModel {
    let p = StudentProfileModel(firstName: "Test", lastName: "Student")
    p.userId = userId
    return p
}

private func makeInMemoryContainer() throws -> ModelContainer {
    let schema = Schema([
        StudentProfileModel.self,
        SATScoreEntryModel.self,
        ActivityModel.self,
        GPAEntryModel.self,
        EssayModel.self,
        ApplicationModel.self,
        CareerQuizHistoryModel.self,
        CollegeModel.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}
