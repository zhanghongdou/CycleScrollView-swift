//
//  CycleScrollView.swift
//  hunbian
//
//  Created by 浩浩 on 16/7/13.
//  Copyright © 2016年 浩浩. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/**
 数据源：获取总的page个数
 **/
typealias TotalPagesCountBlock  = (_ totalPgaesCount: NSInteger) -> Void
/**
 数据源：获取第pageIndex个位置的contentView
 **/
typealias ContentViewAtIndex = (_ pageIndex: NSInteger) -> UIView
/**
 当点击的时候，执行的block
 **/
typealias ActionBlock = (_ pageIndex: NSInteger) -> Void
class CycleScrollView: UIView, UIScrollViewDelegate {
    //存放加载图片的网址
    var imageURLArray = Array<String>()
    var imageViewCopy : UIImageView?
    
    var scrollView : UIScrollView?
//    var getTotalPagesCountBlock = TotalPagesCountBlock?()
    var fetchContentViewAtIndex : ContentViewAtIndex?
    var tapActionBlock : ActionBlock?
    var pageControl : UIPageControl?
    var currentPageIndex = NSInteger()
    
    var contentViews = NSMutableArray()
    var animationTimer : Timer?
    var animationDuration = TimeInterval()
    
    var _totalPageCount : NSInteger?
    var totalPageCount : NSInteger? {
        set{
            _totalPageCount = newValue
            if _totalPageCount > 0 {
                
                if _totalPageCount > 1 {
                    self.scrollView?.isScrollEnabled = true
                    self.startTimer()
                    if _totalPageCount == 2 {
                        self.imageViewCopy = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 200))
                    }
                }
                self.configContentViews()
            }
        }
        get{
            return _totalPageCount
        }
    }

    /**
     如果直接就是init的话，就需要加override
     */
    init(frame: CGRect, animationDuration: TimeInterval) {
        super.init(frame: frame)
        self.animationDuration = animationDuration
        self.autoresizesSubviews = true
        let scrollViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.size.height)
        self.scrollView = UIScrollView.init(frame: scrollViewFrame)
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentMode = .center
        self.scrollView?.isScrollEnabled = false
        self.scrollView?.contentSize = CGSize(width: 3 * scrollViewFrame.width, height: scrollViewFrame.height)
        self.scrollView?.delegate = self
        self.scrollView?.isPagingEnabled = true
        self.addSubview(self.scrollView!)
        self.pageControl = UIPageControl.init(frame: CGRect(x: (scrollViewFrame.size.width/2 - 20), y: (scrollViewFrame.size.height - 20), width: 40, height: 30))
        self.pageControl?.currentPage = 0
        self.addSubview(self.pageControl!)
        self.currentPageIndex = 0
    }
    func startTimer() {
        if self.animationTimer != nil {
            self.animationTimer?.invalidate()
            self.animationTimer = nil
        }
        self.animationTimer = Timer.scheduledTimer(timeInterval: animationDuration, target: self, selector: #selector(CycleScrollView.animationTimerDidFired), userInfo:nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configContentViews() {
        for subView in self.scrollView!.subviews {
            subView.removeFromSuperview()
        }
        self.setScrollViewContentDataSource()
        var counter : CGFloat = 0
        for contentView in self.contentViews {
            let view = contentView as! UIView
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(CycleScrollView.contentViewTapAction(_:)))
            view.addGestureRecognizer(tap)
            var rightRect = view.frame
            
            rightRect.origin = CGPoint(x: UIScreen.main.bounds.width * counter, y: 0)
            counter += 1
            view.frame = rightRect
            self.scrollView?.addSubview(view)
        }
        
        if _totalPageCount == 1 {
            self.scrollView?.contentOffset = CGPoint(x: 0, y: 0)
        }else{
            self.scrollView?.contentOffset = CGPoint(x: self.scrollView!.frame.size.width, y: 0)
        }
    }
    func setScrollViewContentDataSource() {
        let previousPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
        let rearPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
        self.contentViews.removeAllObjects()
        if self.fetchContentViewAtIndex != nil {
            if _totalPageCount == 1 {
                self.contentViews.add(self.fetchContentViewAtIndex!(0))
            }else{
                if _totalPageCount == 2
                
                
                {
                    //如果当前是0的话，就copy1
                    if self.currentPageIndex == 0 {
                        self.imageViewCopy?.sd_setImage(with: URL(string: self.imageURLArray[1]))
                        self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                        self.contentViews.add(self.fetchContentViewAtIndex!(self.currentPageIndex))
                        self.contentViews.add(self.imageViewCopy!)
                        
                    }else{//如果当前是1的话，就copy0
                        self.imageViewCopy?.sd_setImage(with: URL(string: self.imageURLArray[0]))
                        self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                        self.contentViews.add(self.fetchContentViewAtIndex!(self.currentPageIndex))
                        self.contentViews.add(self.imageViewCopy!)
                    }
                }else{
                    self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                    self.contentViews.add(self.fetchContentViewAtIndex!(self.currentPageIndex))
                    self.contentViews.add(self.fetchContentViewAtIndex!(rearPageIndex))
                }
            }
        }
    }
    
    
    func getValidNextPageIndexWithPageIndex(_ currentPageIndex: NSInteger) -> NSInteger {
        if currentPageIndex == -1 {
            return _totalPageCount! - 1
        }else{
            if currentPageIndex == _totalPageCount {
                return 0
            }else{
                return currentPageIndex
            }
        }
    }
    
    func animationTimerDidFired() {
        let totalCount = round(self.scrollView!.contentOffset.x) / UIScreen.main.bounds.width
        let newOffSet = CGPoint(x: (totalCount + 1) * UIScreen.main.bounds.width, y: self.scrollView!.contentOffset.y)
        if self.pageControl!.currentPage + 1 > (_totalPageCount! - 1) {
            self.pageControl?.currentPage = 0
        }else{
            self.pageControl?.currentPage = (self.pageControl?.currentPage)! + 1
        }
        self.scrollView?.setContentOffset(newOffSet, animated: true)
    }
    
    //MARK: UIScrollViewDelegate的协议方法
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if _totalPageCount > 1 {
          self.startTimer()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if contentOffsetX >= (2 * UIScreen.main.bounds.width) {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
            self.pageControl?.currentPage = self.currentPageIndex
            self.configContentViews()
        }
        if contentOffsetX <= 0 {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
            self.pageControl?.currentPage = self.currentPageIndex
            self.configContentViews()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        scrollView.setContentOffset(CGPointMake(CGRectGetWidth(UIScreen.mainScreen().bounds), 0), animated: true)
    }

    /**
     *  点击事件
     */
    func contentViewTapAction(_ tap: UITapGestureRecognizer) {
        if self.tapActionBlock != nil {
            self.tapActionBlock!(self.currentPageIndex)
        }
    }


    
}


























































