import UIKit

class ProfileViewController: UIViewController {
    private let user: GitHubUser
    private var repositories: [Repository] = []
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()

    init(user: GitHubUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor") ?? .white
        setupUI()
        setupTableView()
        loadProfileImage()
        fetchRepositories()
    }
    
    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(separatorView)
        view.addSubview(tableView)
        
        usernameLabel.text = user.name ?? user.login
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),

            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            separatorView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 2),

            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "repoCell")
    }
    
    private func loadProfileImage() {
        guard let url = URL(string: user.avatar_url) else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            return
        }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        }
    }
    
    private func fetchRepositories() {
        APIClient.shared.fetchRepositories(for: user.login) { [weak self] result in
            switch result {
            case .success(let repos):
                self?.repositories = repos
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "repoCell")
        let repo = repositories[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.textLabel?.text = repo.name
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = repo.language ?? "Unknown"
        cell.detailTextLabel?.textColor = .lightGray
        cell.isUserInteractionEnabled = false

        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.white
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        return cell
    }
}
