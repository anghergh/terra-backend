//
//  UserController.swift
//  App
//
//  Created by Andrei GHERGHE on 06/05/2018.
//

import Vapor
import Crypto
import Fluent

/// Controlers basic CRUD operations on `User`s.

//thanks @bensyverson
final class UserController {    
    /// Saves a decoded `User` to the database.
    func signup(_ req: Request) throws -> Future<HTTPResponse> {
        return try req.content.decode(User.self).flatMap { user in
            try User.query(on: req).filter(\User.username == user.username).count().flatMap { userCount in
                if userCount > 0 {
                    throw Abort(.conflict)
                }
                else {
                    user.password = try BCrypt.hash(user.password, cost: 4)
                    return user.save(on: req).transform(to: HTTPResponse(status: .created))
                }
            }
        }
    }

    func login(_ req: Request) throws -> Future<LoggedUserResponse> {
        guard let user = req.user() else {
            throw Abort(.unauthorized)
        }
        let token = try TerraToken.generate(for: user)
        return token.save(on: req).flatMap { savedToken -> Future<LoggedUserResponse> in
            return Future.map(on: req) {
                return LoggedUserResponse(username: user.username, token: savedToken.token)
            }
        }
    }

    /// Deletes a parameterized `User`.
    func getSelf(_ req: Request) throws -> Future<UserProfileResponse> {
        guard let user = req.user() else {
            throw Abort(.unauthorized)
        }
        return Future.map(on: req) {
            return UserProfileResponse(username: user.username, email: user.email, points: user.points, gender: user.gender, city: user.city, age: user.age)
        }
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }

    /// Updates a parameterized `User`.
    func update(_ req: Request) throws -> Future<UserProfileResponse> {
        guard let authedUser = req.user() else {
            throw Abort(.unauthorized)
        }
        return try req.content.decode(UserProfileResponse.self).flatMap { user in
            authedUser.age = user.age
            authedUser.city = user.city
            //TODO: CHECK FOR DUPLICATES, ADD VERIFICATION
            authedUser.email = user.email
            authedUser.gender = user.gender

            return authedUser.update(on: req).flatMap { updatedUser in
                return Future.map(on: req) {
                    return UserProfileResponse(username: user.username, email: user.email, points: user.points, gender: user.gender, city: user.city, age: user.age)
                }
            }
        }
    }
}
