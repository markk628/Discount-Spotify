import SnapKit
import Spartan
import Kingfisher

class ArtistCell: UITableViewCell {
    
    var artist: Artist!
    static let identifier: String = "ArtistTableViewCell"
    
    lazy var mainStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var artistRankLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var artistNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .electricBlue
        label.font = label.font.withSize(20)
        label.textAlignment = .left
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        artistNameLabel.text = ""
//        artistRankLabel.text = ""
//        artistImageView.image = nil
//    }
        
    fileprivate func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        mainStackView.addArrangedSubview(artistRankLabel)
        artistRankLabel.snp.makeConstraints {
            $0.width.height.equalTo(25)
        }
        
        mainStackView.addArrangedSubview(artistImageView)
        artistImageView.snp.makeConstraints {
            $0.height.width.equalTo(self.contentView.snp.height).multipliedBy(0.8)
        }

        mainStackView.addArrangedSubview(artistNameLabel)
        artistNameLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.lessThanOrEqualToSuperview()
        }
    }
    
    func populateViews(artist: Artist, rank: Int) {
        artistNameLabel.text = artist.name
        artistRankLabel.text = "\(rank)"
        guard let urlString = artist.images.first?.url,
              let imageUrl = URL(string: urlString)
        else { return }
        artistImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            //            self.imgIndicator.shouldAnimate(shouldAnimate: false)
            do {
                let _ = try result.get() //value
            } catch {
                DispatchQueue.main.async {
                    print("Done downloading image")
                }
            }
        }
    }
}
