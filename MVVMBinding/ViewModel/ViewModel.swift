//
//  ViewModel.swift
//  MVVMBinding
//
//  Created by MacBook on 04/04/2022.
//

import Foundation

// ViewModels

struct UserListViewModel {
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel {
    var name: String
}
