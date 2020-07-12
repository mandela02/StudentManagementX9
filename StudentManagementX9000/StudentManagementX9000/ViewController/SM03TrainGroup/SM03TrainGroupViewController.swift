//
//  SM03TrainGroupViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/19/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SM03TrainGroupViewController: BaseViewController {

    let reuseIdentifier = "StudenCell"

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var addPersonButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    private let disposeBag = DisposeBag()

    private let viewModel = SM03TrainGroupViewModel()

    override func configureView() {
        configureCollectionView()
    }

    override func configureObservers() {
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
    }

    @IBAction func addPersonButtonPressed(_ sender: Any) {
        let newPersonViewCOntroller = SM04NewPersonViewController.instantiateFromStoryboard()
        pushViewController(newPersonViewCOntroller)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        ProgressHelper.shared.show()
        FaceApiHelper.shared.trainGroup().subscribe(onNext: { () in
            ProgressHelper.shared.hide()
        }, onError: { error in
            ProgressHelper.shared.hide()
        }).disposed(by: disposeBag)
    }

    private func configureCollectionView() {
        groupCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        let datasource = RxCollectionViewSectionedReloadDataSource<StudentSectionModel>(configureCell: { [weak self] (_, collectionView, indexPath, person) -> UICollectionViewCell in
            guard let self = self else { return UICollectionViewCell() }
            if let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier,
                                     for: indexPath) as? SM03TrainGroupCollectionViewCell {
                cell.configureCell(with: person)
                return cell
            }
            return UICollectionViewCell()
        })

        viewModel.studensList
            .bind(to: groupCollectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        groupCollectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let newPersonViewController = SM04NewPersonViewController.instantiateFromStoryboard()
            newPersonViewController.viewModel.student.accept(self.viewModel.students.value[indexPath.item].person)
            newPersonViewController.viewModel.mode.accept(.update)
            self.pushViewController(newPersonViewController)
        }).disposed(by: disposeBag)
    }
}

extension SM03TrainGroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = CollectionView.sectionInsets.left
            + CollectionView.sectionInsets.right
            + (CollectionView.sectionInsets.left * (CollectionView.numberOfCellinRow - 1))
        let size = Int((UIScreen.main.bounds.width - padding - 40) / CollectionView.numberOfCellinRow)
        return CGSize(width: size, height: size * 3/2)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionView.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionView.sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionView.sectionInsets.bottom
    }
}
