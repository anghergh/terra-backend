//
//  PollComment.swift
//  App
//
//  Created by Andrei GHERGHE on 05/05/2018.
//

import FluentMySQL
import Vapor

/// A single entry of a PollComment list.
final class PollComment: MySQLUUIDModel, Timestampable {

    var createdAt: Date?
    var updatedAt: Date?

    static var createdAtKey: CreatedAtKey { return \.createdAt }
    static var updatedAtKey: UpdatedAtKey { return \.updatedAt }

    /// The unique identifier for this `PollComment`.
    var id: UUID?
    
    /// The unique identifier for the parent `Poll`
    var pollID: Poll.ID?
    
    /// The unique identifier for the parent `User`
    var userID: User.ID?
    
    /// The body of the `PollComment`.
    var body: String
    
    /// Creates a new `PollComment`.
    init(id: UUID? = nil, body: String, pollID: Poll.ID, userID: User.ID?) {
        self.id = id
        self.body = body
        self.pollID = pollID
        self.userID = userID
    }
}

/// Allows `PollComment` to be used as a dynamic migration.
extension PollComment: Migration { }

/// Allows `PollComment` to be encoded to and decoded from HTTP messages.
extension PollComment: Content { }

/// Allows `PollComment` to be used as a dynamic parameter in route definitions.
extension PollComment: Parameter { }

extension PollComment {
    // TODO: fix this
//    var poll: Parent<PollComment, Poll> {
//        return parent(\.pollID)
//    }

    var user: Parent<PollComment, User> {
        return parent(\.userID)!
        // TODO: do not force unwrap
    }
}

extension PollComment: Validatable {
    static func validations() throws -> Validations<PollComment> {
        var validations = Validations(PollComment.self)
        try validations.add(\.body, .count (1...144))
        return validations
    }
}
