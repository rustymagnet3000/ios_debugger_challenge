import UIKit

class YD_Thread_Chomper_CVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private let reuseIdentifier = "fishCell"
    private var caughtFish: NSMutableArray = []
    var bgImage: UIImageView = UIImageView()
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        caughtFish = yd_start_chomper()     // called on each Tab open
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInsets
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let myCollectionView:UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        myCollectionView.backgroundColor = UIColor.white
        self.view.addSubview(myCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caughtFish.count
    }

    
    private func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        print("User tapped on item \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        

        guard let fish: String = caughtFish[indexPath.item] as? String else {
            print("Bug 🦂 ")
            exit(88)
        }
        
        switch fish {
        case "Lemon Shark":
            if let image: UIImage = UIImage(named: "airplane_mode_on"){
                bgImage = UIImageView(image: image)
            }
        default:
            if let image: UIImage = UIImage(named: "car"){
                bgImage = UIImageView(image: image)
            }
        }
        
        myCell.backgroundColor = UIColor.yellow
        bgImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        myCell.contentView.addSubview(bgImage)
        return myCell
    }
    
}
