//
//  CycleScrollView.swift
//  hunbian
//
//  Created by 浩浩 on 16/7/13.
//  Copyright © 2016年 浩浩. All rights reserved.
//

import UIKit

/**
 数据源：获取总的page个数
 **/
typealias TotalPagesCountBlock  = (totalPgaesCount: NSInteger) -> Void
/**
 数据源：获取第pageIndex个位置的contentView
 **/
typealias ContentViewAtIndex = (pageIndex: NSInteger) -> UIView
/**
 当点击的时候，执行的block
 **/
typealias ActionBlock = (pageIndex: NSInteger) -> Void
class CycleScrollView: UIView, UIScrollViewDelegate {
    //存放加载图片的网址
    var imageURLArray = Array<String>()
    var imageViewCopy : UIImageView?
    
    var scrollView : UIScrollView?
//    var getTotalPagesCountBlock = TotalPagesCountBlock?()
    var fetchContentViewAtIndex = ContentViewAtIndex?()
    var tapActionBlock = ActionBlock?()
    var pageControl : UIPageControl?
    var currentPageIndex = NSInteger()
    
    var contentViews = NSMutableArray()
    var animationTimer : NSTimer?
    var animationDuration = NSTimeInterval()
    
    var _totalPageCount : NSInteger?
    var totalPageCount : NSInteger? {
        set{
            _totalPageCount = newValue
            if _totalPageCount > 0 {
                
                if _totalPageCount > 1 {
                    self.scrollView?.scrollEnabled = true
                    self.startTimer()
                    if _totalPageCount == 2 {
                        self.imageViewCopy = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 200))
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
    init(frame: CGRect, animationDuration: NSTimeInterval) {
        super.init(frame: frame)
        self.animationDuration = animationDuration
        self.autoresizesSubviews = true
        let scrollViewFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), frame.size.height)
        self.scrollView = UIScrollView.init(frame: scrollViewFrame)
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentMode = .Center
        self.scrollView?.scrollEnabled = false
        self.scrollView?.contentSize = CGSizeMake(3 * CGRectGetWidth(scrollViewFrame), CGRectGetHeight(scrollViewFrame))
        self.scrollView?.delegate = self
        self.scrollView?.pagingEnabled = true
        self.addSubview(self.scrollView!)
        self.pageControl = UIPageControl.init(frame: CGRectMake((scrollViewFrame.size.width/2 - 20), (scrollViewFrame.size.height - 20), 40, 30))
        self.pageControl?.currentPage = 0
        self.addSubview(self.pageControl!)
        self.currentPageIndex = 0
    }
    func startTimer() {
        if self.animationTimer != nil {
            self.animationTimer?.invalidate()
            self.animationTimer = nil
        }
        self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(animationDuration, target: self, selector: #selector(CycleScrollView.animationTimerDidFired), userInfo:nil, repeats: true)
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
            view.userInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(CycleScrollView.contentViewTapAction(_:)))
            view.addGestureRecognizer(tap)
            var rightRect = view.frame
            
            rightRect.origin = CGPointMake(CGRectGetWidth(UIScreen.mainScreen().bounds) * counter, 0)
            counter += 1
            view.frame = rightRect
            self.scrollView?.addSubview(view)
        }
        
        if _totalPageCount == 1 {
            self.scrollView?.contentOffset = CGPointMake(0, 0)
        }else{
            self.scrollView?.contentOffset = CGPointMake(self.scrollView!.frame.size.width, 0)
        }
    }
    func setScrollViewContentDataSource() {
        let previousPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
        let rearPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
        self.contentViews.removeAllObjects()
        if self.fetchContentViewAtIndex != nil {
            if _totalPageCount == 1 {
                self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: 0))
            }else{
                if _totalPageCount == 2 {
                    //如果当前是0的话，就copy1
                    if self.currentPageIndex == 0 {
                        self.imageViewCopy?.sd_setImageWithURL(NSURL(string: self.imageURLArray[1]))
                        self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: previousPageIndex))
                        self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: self.currentPageIndex))
                        self.contentViews.addObject(self.imageViewCopy!)
                        
                    }else{//如果当前是1的话，就copy0
                        self.imageViewCopy?.sd_setImageWithURL(NSURL(string: self.imageURLArray[0]))
                        self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: previousPageIndex))
                        self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: self.currentPageIndex))
                        self.contentViews.addObject(self.imageViewCopy!)
                    }
                }else{
                    self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: previousPageIndex))
                    self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: self.currentPageIndex))
                    self.contentViews.addObject(self.fetchContentViewAtIndex!(pageIndex: rearPageIndex))
                }
            }
        }
    }
    
    func getValidNextPageIndexWithPageIndex(currentPageIndex: NSInteger) -> NSInteger {
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
        let totalCount = round(self.scrollView!.contentOffset.x) / CGRectGetWidth(UIScreen.mainScreen().bounds)
        let newOffSet = CGPointMake((totalCount + 1) * CGRectGetWidth(UIScreen.mainScreen().bounds), self.scrollView!.contentOffset.y)
        if self.pageControl!.currentPage + 1 > (_totalPageCount! - 1) {
            self.pageControl?.currentPage = 0
        }else{
            self.pageControl?.currentPage = (self.pageControl?.currentPage)! + 1
        }
        self.scrollView?.setContentOffset(newOffSet, animated: true)
    }
    
    //MARK: UIScrollViewDelegate的协议方法
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
       self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if _totalPageCount > 1 {
          self.startTimer()
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if contentOffsetX >= (2 * CGRectGetWidth(UIScreen.mainScreen().bounds)) {
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

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        scrollView.setContentOffset(CGPointMake(CGRectGetWidth(UIScreen.mainScreen().bounds), 0), animated: true)
    }

    /**
     *  点击事件
     */
    func contentViewTapAction(tap: UITapGestureRecognizer) {
        if self.tapActionBlock != nil {
            self.tapActionBlock!(pageIndex:self.currentPageIndex)
        }
    }


    
}


























































