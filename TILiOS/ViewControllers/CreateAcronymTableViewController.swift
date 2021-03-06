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

class CreateAcronymTableViewController: UITableViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var acronymShortTextField: UITextField!
  @IBOutlet weak var acronymLongTextField: UITextField!
  @IBOutlet weak var userLabel: UILabel!

  // MARK: - Properties
  var selectedUser: User?
  var acronym: Acronym?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    populateUsers()
  }

  func populateUsers() {
    getAllUsers { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the users", on: self) { _ in
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let users):
        DispatchQueue.main.async { [weak self] in
          self?.userLabel.text = users[0].name
        }
        self?.selectedUser = users[0]
      }
    }
  }
  
  func saveAcronym(_ acronym: Acronym, completion: @escaping (Result<Void, Error>) -> Void) {
    AF.request("http://localhost:8080/api/acronyms", method: .post, parameters: acronym, encoder: JSONParameterEncoder.default).validate(statusCode: 200...200).response { response in
      switch response.result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
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

  // MARK: - IBActions
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: UIBarButtonItem) {
    guard let shortText = acronymShortTextField.text, !shortText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify an acronym!", on: self)
      return
    }

    guard let longText = acronymLongTextField.text, !longText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a meaning!", on: self)
      return
    }

    guard let userID = selectedUser?.id else {
      ErrorPresenter.showError(message: "You must have a user to create an acronym!", on: self)
      return
    }

    let acronym = Acronym(short: shortText, long: longText, userID: userID)
    saveAcronym(acronym) { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was a problem saving the acronym", on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }
  }
  
  @IBAction func updateSelectedUser(_ segue: UIStoryboardSegue) {
    guard let controller = segue.source as? SelectUserTableViewController else {
      return
    }
    selectedUser = controller.selectedUser
    userLabel.text = selectedUser?.name
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SelectUserSegue" {
      guard let destination = segue.destination as? SelectUserTableViewController,
        let user = selectedUser else {
          return
      }

      destination.selectedUser = user
    }
  }
}
