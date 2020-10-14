//
//  User.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.

import Foundation

struct User : Codable {
    let trucker_id : Int?
    let first_name : String?
    let last_name : String?
    let phone : String?
    let email : String?
    let otp_code : String?
    let nationality : String?
    let dob : String?
    let image : String?
    let address : String?
    let id_card : String?
    let id_card_image : String?
    let id_card_expiry : String?
    let driving_license : String?
    let driving_license_image : String?
    let driving_license_expiry : String?
    let wallet : Int?
    let is_activate : Int?
    let deleted_at : String?
    let created_at : String?
    let updated_at : String?
    let access_token : String?

    enum CodingKeys: String, CodingKey {

        case trucker_id = "trucker_id"
        case first_name = "first_name"
        case last_name = "last_name"
        case phone = "phone"
        case email = "email"
        case otp_code = "otp_code"
        case nationality = "nationality"
        case dob = "dob"
        case image = "image"
        case address = "address"
        case id_card = "id_card"
        case id_card_image = "id_card_image"
        case id_card_expiry = "id_card_expiry"
        case driving_license = "driving_license"
        case driving_license_image = "driving_license_image"
        case driving_license_expiry = "driving_license_expiry"
        case wallet = "wallet"
        case is_activate = "is_activate"
        case deleted_at = "deleted_at"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case access_token = "access_token"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trucker_id = try values.decodeIfPresent(Int.self, forKey: .trucker_id)
        first_name = try values.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try values.decodeIfPresent(String.self, forKey: .last_name)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        otp_code = try values.decodeIfPresent(String.self, forKey: .otp_code)
        nationality = try values.decodeIfPresent(String.self, forKey: .nationality)
        dob = try values.decodeIfPresent(String.self, forKey: .dob)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        id_card = try values.decodeIfPresent(String.self, forKey: .id_card)
        id_card_image = try values.decodeIfPresent(String.self, forKey: .id_card_image)
        id_card_expiry = try values.decodeIfPresent(String.self, forKey: .id_card_expiry)
        driving_license = try values.decodeIfPresent(String.self, forKey: .driving_license)
        driving_license_image = try values.decodeIfPresent(String.self, forKey: .driving_license_image)
        driving_license_expiry = try values.decodeIfPresent(String.self, forKey: .driving_license_expiry)
        wallet = try values.decodeIfPresent(Int.self, forKey: .wallet)
        is_activate = try values.decodeIfPresent(Int.self, forKey: .is_activate)
        deleted_at = try values.decodeIfPresent(String.self, forKey: .deleted_at)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        access_token = try values.decodeIfPresent(String.self, forKey: .access_token)
    }

}
