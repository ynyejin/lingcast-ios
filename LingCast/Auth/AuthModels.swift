//
//  AuthModels.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import Foundation

// 로그인 요청
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

// 로그인 응답 데이터
struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int64
    let refreshTokenExpiresIn: Int64
    let user: LoginUser
}

struct LoginUser: Decodable {
    let userId: Int64
    let email: String
    let nickname: String
}

// 회원가입 요청
struct SignupRequest: Encodable {
    let email: String
    let password: String
    let nickname: String
}

// 회원가입 응답
struct SignupResponse: Decodable {
    let userId: Int64
    let email: String
    let nickname: String
}

// 내 정보 조회 응답
struct UserResponse: Decodable {
    let userId: Int64
    let email: String
    let nickname: String
    let englishLevel: String?
    let createdAt: String
}
