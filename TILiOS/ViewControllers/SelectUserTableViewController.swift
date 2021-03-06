/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Alamofire

class SelectUserTableViewController: UITableViewController {

  // MARK: - Properties
  var users: [User] = []
  var selectedUser: User!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  func loadData() {
    getAllUsers { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the users", on: self) { _ in
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let users):
        self?.users = users
        DispatchQueue.main.async { [weak self] in
          self?.tableView.reloadData()
        }
      }
    }
  }
  
  func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
    AF.request("http://localhost:8080/api/users").validate().responseDecodable(of: [User].self) { response in
      switch response.result {
      case .success(let users):
        completion(.success(users))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "UnwindSelectUserSegue" {
      guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
          return
      }

      selectedUser = users[indexPath.row]
    }
  }
}

// MARK: - UITableViewDataSource
extension SelectUserTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let user = users[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserCell", for: indexPath)
    cell.textLabel?.text = user.name

    if user.name == selectedUser.name {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    return cell
  }
}
