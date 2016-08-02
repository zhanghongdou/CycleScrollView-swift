//
//  ViewController.swift
//  图片轮播
//
//  Created by 浩浩 on 16/7/14.
//  Copyright © 2016年 浩浩. All rights reserved.
//

import UIKit
import SDWebImage
class ViewController: UIViewController {

    
    var imageViewArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        let cycleView = CycleScrollView.init(frame: CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 200), animationDuration: 3.0)
        cycleView.backgroundColor = UIColor.orangeColor()
        self.view.addSubview(cycleView)
        
        let dataArray = ["http://img04.sogoucdn.com/app/a/100520020/50c11a6a4b7a4da664e93a9cf4c061ce",
                         "http://img04.sogoucdn.com/app/a/100520024/1f9163519dac6b2138c7d96b5598467e",
                         "http://img01.sogoucdn.com/app/a/100520024/e2f057ede9d3cafabed15418bad2ee17",
                         "http://img01.sogoucdn.com/app/a/100520020/2001859ba6fca0a525728c7568782d89",
                         "http://img04.sogoucdn.com/app/a/100520024/f4d580ab0d9f5d514c9471b23bba0561",
                         "http://img03.sogoucdn.com/app/a/100520024/30e8009fb8710f519b565b1cd17df7ec",
                         "http://img02.sogoucdn.com/app/a/100520020/992e6ea334d3d1c34abfa5ea1ec0978a"]
        
        for index in 0..<dataArray.count {
            let imageView = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200))
            imageView.sd_setImageWithURL(NSURL(string: dataArray[index]))
            self.imageViewArray.addObject(imageView)
        }
        cycleView.fetchContentViewAtIndex = {(pageIndex: NSInteger) in
            return (self.imageViewArray[pageIndex] as! UIView)
        }
        cycleView.totalPageCount = self.imageViewArray.count
        
        cycleView.pageControl?.numberOfPages = self.imageViewArray.count
        
        cycleView.tapActionBlock = { (pageIndex: NSInteger) in
            print(pageIndex)
        }
        
    }
    
}

