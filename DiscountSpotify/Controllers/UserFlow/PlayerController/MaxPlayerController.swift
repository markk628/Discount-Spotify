//
//  MaxPlayerController.swift
//  DiscountSpotify
//
//  Created by Mark Kim on 1/11/21.
//

import UIKit
import SnapKit
import Spartan

protocol MaxPlayerSourceProtocol: class {
    var originatingFrameInWindow: CGRect { get }
    var originatingCoverImageView: UIImageView { get }
}

class MaxPlayerController: UIViewController, TrackSubscriber {
    
    // MARK: - Properties
    let primaryDuration = 0.5
    let backingImageEdgeInset: CGFloat = 15.0
    let cardCornerRadius: CGFloat = 10
    var currentTrack: Track?
    weak var sourceView: MaxPlayerSourceProtocol!
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.bounces = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var stretchyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var coverImageContainer: UIView!
    var coverArtImage: UIImageView!
    
    private lazy var dismissMaxPlayerButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "dismiss")?.withTintColor(.fluorescentBlue, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var backingImage: UIImage?
    
    private lazy var backingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var dimmerLayer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var bottomSectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var tabBarImage: UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureImageLayerInStartPosition()
        coverArtImage.image = sourceView.originatingCoverImageView.image
        configureCoverImageInStartPosition()
        stretchyView.backgroundColor = .white
        configureLowerModuleInStartPosition()
        configureBottomSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingImageIn()
        animateImageLayerIn()
        animateCoverImageIn()
        animateLowerModuleIn()
        animateBottomSectionOut()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .black
        
        
        backingImageView.image = backingImage
        scrollView.contentInsetAdjustmentBehavior = .never //dont let Safe Area insets affect the scroll view
        
        coverImageContainer.layer.cornerRadius = cardCornerRadius
        coverImageContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
        //        [backingImageView, dimmerLayer].forEach {
        //            self.view.addSubview($0)
        //            $0.snp.makeConstraints {
        //                $0.edges.equalToSuperview()
        //            }
        //        }
        
        self.view.addSubview(backingImageView)
        backingImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(dimmerLayer)
        dimmerLayer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backingImageView).offset(15)
            $0.left.right.bottom.equalToSuperview()
        }
        
        self.view.addSubview(bottomSectionImageView)
        bottomSectionImageView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(128)
        }
        
        //        [coverImageContainer, stretchyView, containerView].forEach {
        //            scrollView.addSubview($0)
        //        }
        scrollView.addSubview(coverImageContainer)
        coverImageContainer.snp.makeConstraints {
            $0.centerX.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(57)
            $0.bottom.equalTo(stretchyView.snp.top)
        }
        
        scrollView.addSubview(stretchyView)
        stretchyView.snp.makeConstraints {
            $0.top.equalTo(coverImageContainer.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalTo(coverImageContainer.snp.bottom).offset(30)
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        coverImageContainer.addSubview(coverArtImage)
        coverArtImage.snp.makeConstraints {
            $0.height.width.equalTo(354)
            $0.top.equalToSuperview().offset(38)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-30)
        }
        
        coverImageContainer.addSubview(dismissMaxPlayerButton)
        dismissMaxPlayerButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc func dismissButtonTapped() {
        animateBackingImageOut()
        animateCoverImageOut()
        animateImageLayerOut() { _ in
            self.dismiss(animated: false)
        }
        animateLowerModuleOut()
        animateBottomSectionIn()
    }
}

//fake tab bar animation
extension MaxPlayerController {
    
    func configureBottomSection() {
        if let image = tabBarImage {
            bottomSectionImageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
//            bottomSectionHeight.constant = image.size.height
            bottomSectionImageView.image = image
        } else {
//            bottomSectionHeight.constant = 0
            bottomSectionImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        view.layoutIfNeeded()
    }
    
    func animateBottomSectionOut() {
        if let image = tabBarImage {
            UIView.animate(withDuration: primaryDuration / 2.0) {
//                self.bottomSectionLowerConstraint.constant = -image.size.height
                self.bottomSectionImageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -image.size.height).isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func animateBottomSectionIn() {
        if tabBarImage != nil {
            UIView.animate(withDuration: primaryDuration / 2.0) {
//                self.bottomSectionLowerConstraint.constant = 0
                self.bottomSectionImageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
}

//background image animation
extension MaxPlayerController {
    
    private func configureBackingImageInPosition(presenting: Bool) {
        let edgeInset: CGFloat = presenting ? backingImageEdgeInset: 0
        let dimmerAlpha: CGFloat = presenting ? 0.3: 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius: 0
        
//        backingImageLeadingInset.constant = edgeInset
        backingImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInset).isActive = true
//        backingImageTrailingInset.constant = edgeInset
        backingImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInset).isActive = true
        let aspectRatio = backingImageView.frame.height / backingImageView.frame.width
//        backingImageTopInset.constant = edgeInset * aspectRatio
        backingImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: edgeInset * aspectRatio).isActive = true
//        backingImageBottomInset.constant = edgeInset * aspectRatio
        backingImageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: edgeInset * aspectRatio).isActive = true
        
        dimmerLayer.alpha = dimmerAlpha
        
        backingImageView.layer.cornerRadius = cornerRadius
    }
    
    private func animateBackingImage(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration) {
            self.configureBackingImageInPosition(presenting: presenting)
            self.view.layoutIfNeeded() //IMPORTANT!
        }
    }
    
    func animateBackingImageIn() {
        animateBackingImage(presenting: true)
    }
    
    func animateBackingImageOut() {
        animateBackingImage(presenting: false)
    }
}

//Image Container animation.
extension MaxPlayerController {
    
    private var startColor: UIColor {
        return UIColor.white.withAlphaComponent(0.3)
    }
    
    private var endColor: UIColor {
        return .white
    }
    
    private var imageLayerInsetForOutPosition: CGFloat {
        let imageFrame = view.convert(sourceView.originatingFrameInWindow, to: view)
        let inset = imageFrame.minY - backingImageEdgeInset
        return inset
    }
    
    func configureImageLayerInStartPosition() {
        coverImageContainer.backgroundColor = startColor
        let startInset = imageLayerInsetForOutPosition
//        dismissChevron.alpha = 0
        dismissMaxPlayerButton.alpha = 0
        coverImageContainer.layer.cornerRadius = 0
//        coverImageContainerTopInset.constant = startInset
        coverImageContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: startInset).isActive = true
        view.layoutIfNeeded()
    }
    
    func animateImageLayerIn() {
        UIView.animate(withDuration: primaryDuration / 4.0) {
            self.coverImageContainer.backgroundColor = self.endColor
        }
        
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseIn], animations: {
//            self.coverImageContainerTopInset.constant = 0
            self.coverImageContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
//            self.dismissChevron.alpha = 1
            self.dismissMaxPlayerButton.alpha = 1
            self.coverImageContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    func animateImageLayerOut(completion: @escaping ((Bool) -> Void)) {
        let endInset = imageLayerInsetForOutPosition
        
        UIView.animate(withDuration: primaryDuration / 4.0, delay: primaryDuration , options: [.curveEaseOut], animations: {
            self.coverImageContainer.backgroundColor = self.startColor
        }, completion: { finished in
            completion(finished)
        })
        
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseOut], animations: {
//            self.coverImageContainerTopInset.constant = endInset
            self.coverImageContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: endInset).isActive = true
//            self.dismissChevron.alpha = 0
            self.dismissMaxPlayerButton.alpha = 0
            self.coverImageContainer.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        })
    }
}

//cover image animation
extension MaxPlayerController {
    
    func configureCoverImageInStartPosition() {
        let originatingImageFrame = sourceView.originatingCoverImageView.frame
//        coverImageHeight.constant = originatingImageFrame.height
//        coverImageLeading.constant = originatingImageFrame.minX
//        coverImageTop.constant = originatingImageFrame.minY
//        coverImageBottom.constant = originatingImageFrame.minY
        coverArtImage.heightAnchor.constraint(equalToConstant: originatingImageFrame.height).isActive = true
        coverArtImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: originatingImageFrame.minX).isActive = true
        coverArtImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: originatingImageFrame.minY).isActive = true
        coverArtImage.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: originatingImageFrame.minY).isActive = true
    }
    
    func animateCoverImageIn() {
        let coverImageEdgeContraint: CGFloat = 30
        let endHeight = coverImageContainer.bounds.width - coverImageEdgeContraint * 2
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseIn], animations: {
//            self.coverImageHeight.constant = endHeight
//            self.coverImageLeading.constant = coverImageEdgeContraint
//            self.coverImageTop.constant = coverImageEdgeContraint
//            self.coverImageBottom.constant = coverImageEdgeContraint
            self.coverArtImage.heightAnchor.constraint(equalToConstant: endHeight).isActive = true
            self.coverArtImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: coverImageEdgeContraint).isActive = true
            self.coverArtImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: coverImageEdgeContraint).isActive = true
            self.coverArtImage.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: coverImageEdgeContraint).isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    func animateCoverImageOut() {
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.configureCoverImageInStartPosition()
            self.view.layoutIfNeeded()
        })
    }
}

//lower module animation
extension MaxPlayerController {
    
    private var lowerModuleInsetForOutPosition: CGFloat {
        let bounds = view.bounds
        return bounds.height - bounds.width
    }
    
    func configureLowerModuleInStartPosition() {
//        lowerModuleTopConstraint.constant = lowerModuleInsetForOutPosition
        coverImageContainer.bottomAnchor.constraint(equalTo: self.containerView.topAnchor, constant: lowerModuleInsetForOutPosition).isActive = true
    }
    
    func animateLowerModule(isPresenting: Bool) {
        let topInset = isPresenting ? 0 : lowerModuleInsetForOutPosition
        UIView.animate(withDuration: primaryDuration , delay: 0 , options: [.curveEaseIn], animations: {
//            self.lowerModuleTopConstraint.constant = topInset
            self.coverImageContainer.bottomAnchor.constraint(equalTo: self.containerView.topAnchor, constant: topInset).isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    func animateLowerModuleOut() {
        animateLowerModule(isPresenting: false)
    }
    
    func animateLowerModuleIn() {
        animateLowerModule(isPresenting: true)
    }
}
