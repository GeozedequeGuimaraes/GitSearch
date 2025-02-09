import UIKit

class HomeViewController: UIViewController {
    private let textField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor") ?? .white
        setupUI()
    }
    
    private func setupUI() {
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false

        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.backgroundColor = UIColor(named: "backgroundColor") ?? .blue
        searchButton.layer.cornerRadius = 5
        searchButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addBorder(searchButton)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 16)
        resultLabel.textColor = .lightGray
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textField)
        view.addSubview(searchButton)
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            textField.heightAnchor.constraint(equalToConstant: 40),

            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            searchButton.heightAnchor.constraint(equalToConstant: 45),

            resultLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }
    
    private func addBorder(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: "colorBorder")?.cgColor ?? UIColor.black.cgColor
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
    }

    @objc private func searchTapped() {
        let username = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !username.isEmpty else {
            resultLabel.text = "Digite algo para pesquisar."
            return
        }

        searchButton.isEnabled = false

        APIClient.shared.fetchUserProfile(for: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.searchButton.isEnabled = true

                switch result {
                case .success(let user):
                    let profileVC = ProfileViewController(user: user)
                    self?.navigationController?.pushViewController(profileVC, animated: true)
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
